# Newton-Raphson demo with automatic differentiation.
#
# This is a plain Julia script written so that Pluto can open it as a notebook
# (Pluto splits a plain .jl file into one cell per top-level expression):
#
#   julia> import Pluto; Pluto.run()          # then open this file in the UI
#
# A cell containing a `# hide` comment has its code folded in the export.
#
# The interactive figure at the bottom is a set of frames precomputed in Julia
# and a few lines of JS that pick which frame to show, so it still works in a
# static HTML export.

md"""
# Newton-Raphson

Newton-Raphson needs the derivative `f'(x)` at every step.  Zygote computes it
exactly from ordinary Julia code: after `using Zygote`, `f'` is the derivative of `f`.
"""

using Zygote

md"""
Each step follows the tangent line at `xᵢ` down to the axis:

$$x_{i+1} = x_i - \frac{f(x_i)}{f'(x_i)}$$
"""

function newton(f, x₀; n=10)
    xs = [x₀]
    x = x₀
    for i in 1:n
        x = x - f(x) / f'(x)
        push!(xs, x)
    end
    return xs
end;

md"""
Drag `x₀` to change the starting point and the iteration slider to step through.
The starting point decides which root is found, or whether one is found at all:
try `atan` from `x₀ = 1.5`, and `x³ − 2x + 2` from `x₀ = 0`, where the iterates
cycle 0, 1, 0, 1, … forever.
"""

# Everything below is display code: the figure, the table, and the widget that
# switches between precomputed frames.  It is one cell so the export shows a
# single folded block whose output is the widget.
# hide
begin
    using Plots;

    functions = [
        (name = "f(x) = eˣ − 4√x",    f = x -> x < 0 ? NaN * x : exp(x) - 4sqrt(x),  xlims = (0.0, 3.0)),
        (name = "f(x) = atan(x)",     f = x -> atan(x),            xlims = (-3.0, 3.0)),
        (name = "f(x) = x³ − 2x + 2", f = x -> x^3 - 2x + 2,       xlims = (-2.5, 2.0)),
    ];

    x₀s = -2.0:0.25:3.0;

    nsteps = 6;

    function newton_figure(fn, x₀; n=nsteps)
        f = fn.f
        xs = newton(f, x₀; n)
        bad = findfirst(!isfinite, xs)          # left the domain of f or hit a flat tangent
        bad === nothing || (xs = xs[1:bad-1])
        lo, hi = fn.xlims
        lo = min(lo, minimum(xs) - 0.2); hi = max(hi, maximum(xs) + 0.2)
        lo, hi = max(lo, -6.0), min(hi, 6.0)      # keep runaway iterates on the page
        grid = range(lo, hi; length=200)
        fgrid = [try f(x) catch; NaN end for x in grid]
        yl = maximum(abs, filter(isfinite, fgrid)) * 1.1
        plt = plot(grid, fgrid; lw=2, color=:black, legend=false, title=fn.name, titlefontsize=11,
                   xlabel="x", ylabel="f(x)", xlims=(lo, hi), ylims=(-yl, yl), size=(640, 400))
        hline!(plt, [0]; color=:gray)
        # Each step adds exactly three SVG elements (tangent, dashed drop, marker) and
        # each iterate one star; layered_svg below relies on this order.  GR drops
        # elements that fall entirely outside the axes, so runaway iterates are
        # clamped to just inside the edge of the plot and lines are clipped to it.
        box = (lo + 0.005(hi - lo), hi - 0.005(hi - lo), -0.99yl, 0.99yl)
        cx(x) = clamp(x, box[1], box[2]); cy(y) = clamp(y, box[3], box[4])
        function clipped(x1, y1, x2, y2)   # segment ∩ box, or a dot at the clamped start if empty
            t0, t1 = 0.0, 1.0
            for (p, d, l, h) in ((x1, x2 - x1, box[1], box[2]), (y1, y2 - y1, box[3], box[4]))
                if d == 0
                    l <= p <= h || (t0 = 1.0; t1 = 0.0)
                else
                    ta, tb = minmax((l - p) / d, (h - p) / d)
                    t0, t1 = max(t0, ta), min(t1, tb)
                end
            end
            t0 <= t1 || return [cx(x1), cx(x1)], [cy(y1), cy(y1)]
            return [x1 + t0 * (x2 - x1), x1 + t1 * (x2 - x1)], [y1 + t0 * (y2 - y1), y1 + t1 * (y2 - y1)]
        end
        for i in 1:length(xs)-1
            x, xnext = xs[i], xs[i+1]
            fx = f(x)
            plot!(plt, clipped(x, fx, xnext, 0.0)...; color=i, lw=1.5)   # tangent from (x, f(x)) to its zero
            plot!(plt, clipped(x, 0.0, x, fx)...; color=i, ls=:dash)
            scatter!(plt, [cx(x)], [cy(fx)]; color=i, ms=5)
        end
        for x in xs
            scatter!(plt, [cx(x)], [0]; color=:red, marker=:star5, ms=9)
        end
        return plt, xs
    end;

    # Render the figure to SVG and wrap the elements of step i in <g data-i=i> and
    # the star for iterate k in <g data-k=k>, so JS can reveal one step at a time.
    function layered_svg(plt, xs)
        io = IOBuffer(); show(io, MIME"image/svg+xml"(), plt); s = String(take!(io))
        m = findfirst(r"<polyline[^\n]*#808080[^\n]*\n", s)      # the gray zero line
        m === nothing && error("zero line not found in svg")
        head, tail = s[1:last(m)], s[last(m)+1:end]
        items = filter(l -> !isempty(strip(l)) && !occursin("</svg>", l), split(tail, '\n'))
        n = length(xs) - 1
        length(items) == 3n + length(xs) || error("unexpected svg structure: $(length(items)) elements for $n steps")
        out = IOBuffer(); print(out, head)
        for i in 1:n
            print(out, "<g class=\"nr-step\" data-i=\"$(i-1)\">", join(items[3i-2:3i], "\n"), "</g>\n")
        end
        for k in 0:n
            print(out, "<g class=\"nr-star\" data-k=\"$k\">", items[3n+k+1], "</g>\n")
        end
        print(out, "</svg>\n")
        return String(take!(out))
    end;

    function newton_table(f, xs)
        rows = map(enumerate(xs)) do (i, x)
            fx  = try f(x)  catch; NaN end
            dfx = try f'(x) catch; NaN end
            εa = i == 1 ? "" : x == 0 ? "—" : string(round(abs((x - xs[i-1]) / x) * 100; sigdigits=3), " %")
            "<tr data-i=\"$(i-1)\"><td>$(i-1)</td><td>$(round(x; sigdigits=8))</td><td>$(round(fx; sigdigits=4))</td><td>$(round(dfx; sigdigits=4))</td><td>$εa</td></tr>"
        end
        # pad to a fixed number of rows and always emit the note, so the widget's
        # height does not change with the sliders (JS toggles visibility, not display)
        blank = ["<tr data-i=\"$i\"><td>&nbsp;</td><td></td><td></td><td></td><td></td></tr>" for i in length(xs):nsteps]
        note = "<p class=\"nr-note\"><em>Stopped early: the iterate left the domain of f or the tangent was flat.</em></p>"
        """<table><thead><tr><th>i</th><th>x<sub>i</sub></th><th>f(x<sub>i</sub>)</th><th>f′(x<sub>i</sub>)</th><th>ε<sub>a</sub></th></tr></thead>
        <tbody>$(join(rows))$(join(blank))</tbody></table>$note"""
    end;

    # Every frame is computed here, in Julia, derivatives included.  The browser
    # only chooses which frame to display, so the controls work in a static export.
    let
        frames = String[]
        for (fi, fn) in enumerate(functions), (xi, x₀) in enumerate(x₀s)
            plt, xs = newton_figure(fn, x₀)
            push!(frames, """<div class="nr-frame" data-f="$(fi-1)" data-x="$(xi-1)" data-n="$(length(xs)-1)" hidden>
                $(layered_svg(plt, xs))$(newton_table(fn.f, xs))</div>""")
        end
        options = join("<option value=\"$(i-1)\">$(fn.name)</option>" for (i, fn) in enumerate(functions))
        default_x = something(findfirst(==(2.0), x₀s), 1) - 1
        HTML("""
        <div class="nr-widget">
          <style>
            .nr-widget .nr-controls { display: flex; gap: 1.5em; flex-wrap: wrap; align-items: center; margin-bottom: .5em; }
            .nr-widget .nr-controls input[type=range] { width: 16em; vertical-align: middle; }
            .nr-widget svg { max-width: 100%; height: auto; }
            .nr-widget table { border-collapse: separate; border-spacing: 0; margin-top: .5em; font-variant-numeric: tabular-nums; }
            .nr-widget td, .nr-widget th { padding: .15em .8em; text-align: right; border-bottom: 1px solid #ddd; }
          </style>
          <div class="nr-controls">
            <label>Function <select class="nr-f">$options</select></label>
            <label>x₀ = <output class="nr-xval"></output>
              <input class="nr-x" type="range" min="0" max="$(length(x₀s)-1)" value="$default_x"></label>
            <label>iteration <output class="nr-kval"></output>
              <input class="nr-k" type="range" min="0" max="$nsteps" value="$nsteps"></label>
          </div>
          $(join(frames))
        </div>
        <script>
          const root = currentScript.previousElementSibling;
          const sel = root.querySelector(".nr-f"), rng = root.querySelector(".nr-x"),
                out = root.querySelector(".nr-xval"), krng = root.querySelector(".nr-k"),
                kout = root.querySelector(".nr-kval");
          const x0s = $(collect(x₀s));
          function show() {
            out.value = x0s[rng.value].toFixed(1);
            const k = +krng.value;
            kout.value = k;
            for (const fr of root.querySelectorAll(".nr-frame")) {
              fr.hidden = !(fr.dataset.f === sel.value && fr.dataset.x === rng.value);
              if (fr.hidden) continue;
              const n = +fr.dataset.n, kk = Math.min(k, n);   // n = steps actually taken
              for (const g of fr.querySelectorAll(".nr-step")) g.style.display = +g.dataset.i < kk ? "" : "none";
              for (const g of fr.querySelectorAll(".nr-star")) g.style.display = +g.dataset.k === kk ? "" : "none";
              for (const tr of fr.querySelectorAll("tr[data-i]")) tr.style.visibility = +tr.dataset.i <= kk ? "" : "hidden";
              fr.querySelector(".nr-note").style.visibility = (n < $nsteps && k >= n) ? "" : "hidden";
            }
          }
          for (const el of [sel, rng, krng]) el.addEventListener("input", show);
          show();
        </script>
        """)
    end
end

md"""
Near a root the number of correct digits roughly **doubles** each step, versus
one binary digit per step for bisection.
"""
