# Newton-Raphson for a system of two equations, with automatic differentiation.
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
# Newton-Raphson for systems

For a system of equations `f(x) = 0`, where `x` and `f(x)` are both vectors,
the derivative becomes the **Jacobian** matrix `J`, with `J[i, j] = ∂fᵢ/∂xⱼ`.
ForwardDiff computes it exactly from ordinary Julia code.
"""

using ForwardDiff: jacobian

using LinearAlgebra

f(x) = [x[1]^2 + x[2]^2 - 4,      # a circle of radius 2
        x[2] - x[1]^2]             # a parabola

jacobian(f, [1.0, 1.0])

md"""
Each step replaces `f` by its linearization at `xᵢ` and solves that linear system.
Instead of dividing by the scalar derivative `f′(xᵢ)` as in one dimension, we solve `J Δx = −f(xᵢ)` for the step:

$$J(x_i)\,\Delta x = -f(x_i), \qquad x_{i+1} = x_i + \Delta x$$
"""

function newton(f, x₀; n=10)
    xs = [x₀]
    x = x₀
    for i in 1:n
        J = jacobian(f, x)
        x = x + J \ (-f(x))
        push!(xs, x)
    end
    return xs
end;

newton(f, [2.0, 2.0]; n=5)

md"""
The top two plots show the two components of `f` separately as contour maps, with the
bold curve where `f₁(x, y) = 0` (blue) and where `f₂(x, y) = 0` (orange).  At the current
iterate, row `j` of the Jacobian, `∇fⱼ`, defines the **tangent plane** to `fⱼ`.  Its
contours are the dashed straight lines, which match the true contours near the point,
and the bold dashed line is where the tangent plane is zero.

The bottom plot puts both zero curves together.  A solution is where they cross.  At
each iterate (red star), Newton-Raphson replaces each curve by the zero line of its
tangent plane (bold dashed); the next iterate is where those two lines cross, so the dashed
lines show where the algorithm is about to jump.  Solving the linear system
`J Δx = −f` is exactly finding that crossing.

Drag `x₀` and `y₀` to move the starting point and step through with the iteration
slider.  The map at the bottom colors every starting point by which solution it
finds (black if it does not find one).  In the circle-parabola system, try starting on
the `y` axis, where the Jacobian is singular, or anywhere below the `x` axis, where the
iterates never settle down: `y` heads for `(−1 − √17)/2 ≈ −2.56`, the other root of
`y² + y − 4 = 0`, which has no real `x`.
"""

# Everything below is display code: the figure, the basin map, the table, and
# the widget that switches between precomputed frames.
# hide
begin
    using Plots

    systems = [
        (name = "x² + y² = 4,  y = x²",
         fnames = ("x² + y² − 4", "y − x²"),
         f = x -> [x[1]^2 + x[2]^2 - 4, x[2] - x[1]^2],
         xlims = (-3.0, 3.0), ylims = (-3.0, 3.0),
         x₀s = -2.0:0.5:2.0, y₀s = -2.0:0.5:2.0),
        (name = "x² + xy = 10,  y + 3xy² = 57",
         fnames = ("x² + xy − 10", "y + 3xy² − 57"),
         f = x -> [x[1]^2 + x[1] * x[2] - 10, x[2] + 3x[1] * x[2]^2 - 57],
         xlims = (-1.0, 6.0), ylims = (-4.0, 5.0),
         x₀s = 0.5:0.5:4.5, y₀s = -1.0:0.5:3.0),
    ]

    nsteps = 6
    curvecolors = (:royalblue, :darkorange)
    sentinel = RGB(1 / 255, 2 / 255, 3 / 255)   # a line of this color separates the background from the layered elements

    # Newton's method that stops (rather than throwing) when the Jacobian is singular
    # or an iterate stops being finite.
    function newton_path(f, x₀; n=nsteps)
        xs = [x₀]
        x = x₀
        for i in 1:n
            x = try
                J = jacobian(f, x)
                x + J \ (-f(x))
            catch
                break
            end
            all(isfinite, x) || break
            push!(xs, x)
        end
        return xs
    end

    # Solutions of the system, found by running Newton from every grid start and
    # keeping the distinct converged points.
    function find_roots(sys)
        roots = Vector{Float64}[]
        for x₀ in sys.x₀s, y₀ in sys.y₀s
            xs = newton_path(sys.f, [x₀, y₀]; n=40)
            x = xs[end]
            norm(sys.f(x)) < 1e-8 || continue
            any(r -> norm(r - x) < 1e-4, roots) || push!(roots, x)
        end
        return sort(roots)
    end

    # Which root (index) Newton converges to from x₀, or 0 if none within n steps.
    function basin(sys, roots, x₀; n=30)
        xs = newton_path(sys.f, x₀; n)
        x = xs[end]
        i = findfirst(r -> norm(r - x) < 1e-6, roots)
        return i === nothing ? 0 : i
    end

    # Segment from p to q clipped to the box (xlims, ylims), or nothing if it misses the box.
    function clipped(p, q, xlims, ylims)
        t0, t1 = 0.0, 1.0
        for k in 1:2
            l, h = k == 1 ? xlims : ylims
            d = q[k] - p[k]
            if d == 0
                l <= p[k] <= h || (t0 = 1.0; t1 = 0.0)
            else
                ta, tb = minmax((l - p[k]) / d, (h - p[k]) / d)
                t0, t1 = max(t0, ta), min(t1, tb)
            end
        end
        t0 <= t1 || return nothing
        return (a = p + t0 * (q - p), b = p + t1 * (q - p))
    end

    # Like clipped, but a dot at the clamped start when the segment misses the box, so
    # that an element is always drawn.
    function clipped_or_dot(p, q, xlims, ylims)
        seg = clipped(p, q, xlims, ylims)
        seg === nothing || return seg
        c = [clamp(p[1], xlims...), clamp(p[2], ylims...)]
        return (a = c, b = c)
    end

    plot_segment!(plt, seg; kw...) = plot!(plt, [seg.a[1], seg.b[1]], [seg.a[2], seg.b[2]]; kw...)

    # The level-c contour of the tangent plane to fⱼ at x, i.e. the straight line
    # fⱼ(x) + ∇fⱼ(x)·(p − x) = c, as a long segment.  c = 0 is the tangent line to {fⱼ = 0}.
    function plane_line(f, x, j, c=0.0)
        fx = f(x); J = jacobian(f, x)
        g = J[j, :]
        p0 = x + (c - fx[j]) * g / dot(g, g)     # closest point on the line to x
        d = [-g[2], g[1]] / norm(g)
        all(isfinite, p0) && all(isfinite, d) || return nothing
        return p0 - 100d, p0 + 100d
    end

    # plane_line clipped to the box, or nothing.
    function plane_segment(f, x, j, c, box)
        line = plane_line(f, x, j, c)
        line === nothing && return nothing
        return clipped(line..., box...)
    end

    # About n evenly spaced "nice" contour levels, including 0, covering the values Z.
    function nice_levels(Z; n=7)
        lo, hi = extrema(Z)
        raw = (hi - lo) / n
        step = 10.0^floor(log10(raw))
        step *= raw / step < 1.5 ? 1 : raw / step < 3.5 ? 2 : raw / step < 7.5 ? 5 : 10
        return step .* (ceil(minimum(Z) / step):floor(maximum(Z) / step))
    end

    level_color(c, levels) = get(cgrad(:viridis), (c - levels[1]) / max(levels[end] - levels[1], eps()))

    # Marker for iterate i.  An iterate outside the plot is drawn hollow, where the step
    # that reached it leaves the plot, to show which way it went; the table has its
    # actual coordinates.
    function iterate_marker!(plt, xs, i, box; color, kw...)
        x = xs[i]
        c = [clamp(x[1], box[1]...), clamp(x[2], box[2]...)]
        inside = c == x
        if !inside && i > 1
            seg = clipped(xs[i-1], x, box...)
            seg === nothing || (c = seg.b)
        end
        scatter!(plt, [c[1]], [c[2]]; color=inside ? color : :white, markerstrokecolor=color,
                 markerstrokewidth=inside ? 1 : 1.5, kw...)
    end

    # Contour map of component j of f with the tangent plane at each iterate overlaid.
    function small_figure(sys, j, xs)
        xl, yl = sys.xlims, sys.ylims
        box = (xl[1] + 0.005(xl[2] - xl[1]), xl[2] - 0.005(xl[2] - xl[1])),
              (yl[1] + 0.005(yl[2] - yl[1]), yl[2] - 0.005(yl[2] - yl[1]))
        gx = range(xl...; length=100); gy = range(yl...; length=100)
        Z = [sys.f([x, y])[j] for y in gy, x in gx]
        levels = nice_levels(Z)
        plt = plot(; xlims=xl, ylims=yl, legend=false, aspect_ratio=1, size=(300, 300),
                   xlabel="x", ylabel="y", guidefontsize=8, tickfontsize=7,
                   title="f$('₀' + j)(x, y) = $(sys.fnames[j])", titlefontsize=10)
        for c in levels
            c == 0 && continue
            contour!(plt, gx, gy, Z; levels=[c], color=level_color(c, levels), lw=1, cbar=false)
        end
        contour!(plt, gx, gy, Z; levels=[0.0], color=curvecolors[j], lw=2.5, cbar=false)
        plot!(plt, [xl[1], xl[1]], [yl[1], yl[1]]; color=sentinel, lw=0.5)
        groups = Tuple{String,Int}[]
        for (i, x) in enumerate(xs)
            cnt = 0
            for c in levels
                seg = plane_segment(sys.f, x, j, c, box)
                seg === nothing && continue
                if c == 0
                    plot_segment!(plt, seg; color=curvecolors[j], ls=:dash, lw=3)
                else
                    plot_segment!(plt, seg; color=level_color(c, levels), ls=:dash, lw=1)
                end
                cnt += 1
            end
            push!(groups, ("<g class=\"nr-lin\" data-i=\"$(i-1)\">", cnt))
        end
        for k in eachindex(xs)
            iterate_marker!(plt, xs, k, box; color=:red, marker=:star5, ms=7)
            push!(groups, ("<g class=\"nr-star\" data-k=\"$(k-1)\">", 1))
        end
        return plt, groups
    end

    function newton_figure(sys, x₀)
        xs = newton_path(sys.f, x₀)
        xl, yl = sys.xlims, sys.ylims
        # GR drops elements entirely outside the axes, so runaway iterates are clamped
        # to just inside the edge and lines are clipped.
        box = (xl[1] + 0.005(xl[2] - xl[1]), xl[2] - 0.005(xl[2] - xl[1])),
              (yl[1] + 0.005(yl[2] - yl[1]), yl[2] - 0.005(yl[2] - yl[1]))
        gx = range(xl...; length=100); gy = range(yl...; length=100)
        plt = plot(; xlims=xl, ylims=yl, legend=false, aspect_ratio=1, size=(440, 440),
                   xlabel="x", ylabel="y", title=sys.name, titlefontsize=11)
        for j in 1:2
            contour!(plt, gx, gy, (x, y) -> sys.f([x, y])[j]; levels=[0.0], color=curvecolors[j], lw=2, cbar=false)
        end
        plot!(plt, [xl[1], xl[1]], [yl[1], yl[1]]; color=sentinel, lw=0.5)
        groups = Tuple{String,Int}[]
        for (i, x) in enumerate(xs)
            cnt = 0
            for j in 1:2      # the tangent lines at x, whose crossing is the next iterate
                seg = plane_segment(sys.f, x, j, 0.0, box)
                seg === nothing && continue
                plot_segment!(plt, seg; color=curvecolors[j], ls=:dash, lw=3); cnt += 1
            end
            push!(groups, ("<g class=\"nr-lin\" data-i=\"$(i-1)\">", cnt))
            if i < length(xs)      # the step from x to the next iterate
                plot_segment!(plt, clipped_or_dot(x, xs[i+1], box...); color=:black, lw=1.5)
                iterate_marker!(plt, xs, i, box; color=:black, ms=3)
                push!(groups, ("<g class=\"nr-step\" data-i=\"$(i-1)\">", 2))
            end
        end
        for k in eachindex(xs)
            iterate_marker!(plt, xs, k, box; color=:red, marker=:star5, ms=9)
            push!(groups, ("<g class=\"nr-star\" data-k=\"$(k-1)\">", 1))
        end
        return plt, groups, xs
    end

    # Split the SVG at the sentinel line: the head (everything up to and including the
    # sentinel), the elements after it, one per line, and the clip-path id of the plot area.
    function split_svg(plt)
        io = IOBuffer(); show(io, MIME"image/svg+xml"(), plt); s = String(take!(io))
        m = findfirst(r"<polyline[^\n]*#010203[^\n]*\n", s)
        m === nothing && error("sentinel line not found in svg")
        clip = match(r"url\(#(clip\d+)\)", s[m]).captures[1]
        head, tail = s[1:last(m)], s[last(m)+1:end]
        items = filter(l -> !isempty(strip(l)) && !occursin("</svg>", l), split(tail, '\n'))
        return head, items, clip
    end

    # Wrap consecutive elements in <g> tags.  `groups` is a list of (opening tag, count).
    # The elements' clip-path attributes are moved to the group and point at `clip`, so
    # the elements can be dropped into a different SVG (the shared background) than the
    # one they were rendered in.
    function grouped(items, groups; clip)
        length(items) == sum(last, groups) || error("unexpected svg structure: $(length(items)) elements, expected $(sum(last, groups))")
        out = IOBuffer(); k = 0
        for (tag, n) in groups
            print(out, replace(tag, "<g " => "<g clip-path=\"url(#$clip)\" "),
                  join(replace.(items[k+1:k+n], r" clip-path=\"url\(#clip\d+\)\"" => ""), "\n"), "</g>\n")
            k += n
        end
        return String(take!(out))
    end

    function basin_svg(sys, roots)
        xl, yl = sys.xlims, sys.ylims
        gx = range(xl...; length=160); gy = range(yl...; length=160)
        Z = [basin(sys, roots, [x, y]) for y in gy, x in gx]
        palette = [:gray15, :mediumseagreen, :mediumpurple, :goldenrod, :lightskyblue][1:length(roots)+1]
        plt = heatmap(gx, gy, Z; c=cgrad(palette, categorical=true), clims=(-0.5, length(roots) + 0.5), cbar=false,
                      legend=false, aspect_ratio=1, size=(380, 380), xlims=xl, ylims=yl,
                      xlabel="x₀", ylabel="y₀")
        for r in roots
            scatter!(plt, [r[1]], [r[2]]; color=:white, marker=:star5, ms=7)
        end
        plot!(plt, [xl[1], xl[1]], [yl[1], yl[1]]; color=sentinel, lw=0.5)
        pts = [(x₀, y₀) for x₀ in sys.x₀s for y₀ in sys.y₀s]
        scatter!(plt, first.(pts), last.(pts); color=:red, ms=4, markerstrokecolor=:white)
        groups = [("<g class=\"nr-start\" data-a=\"$(a-1)\" data-b=\"$(b-1)\">", 1)
                  for a in eachindex(sys.x₀s) for b in eachindex(sys.y₀s)]
        head, items, clip = split_svg(plt)
        return head * grouped(items, groups; clip) * "</svg>\n"
    end

    function newton_table(f, xs)
        rows = map(enumerate(xs)) do (i, x)
            r = norm(f(x))
            εa = i == 1 ? "" : norm(x) == 0 ? "—" : string(round(norm(x - xs[i-1]) / norm(x) * 100; sigdigits=3), " %")
            "<tr data-i=\"$(i-1)\"><td>$(i-1)</td><td>$(round(x[1]; sigdigits=7))</td><td>$(round(x[2]; sigdigits=7))</td><td>$(round(r; sigdigits=3))</td><td>$εa</td></tr>"
        end
        # pad to a fixed number of rows and always emit the note, so the widget's
        # height does not change with the sliders (JS toggles visibility, not display)
        blank = ["<tr data-i=\"$i\"><td>&nbsp;</td><td></td><td></td><td></td><td></td></tr>" for i in length(xs):nsteps]
        note = "<p class=\"nr-note\"><em>Stopped early: the Jacobian was singular (the tangent lines are parallel).</em></p>"
        """<table><thead><tr><th>i</th><th>x<sub>i</sub></th><th>y<sub>i</sub></th><th>‖f(x<sub>i</sub>)‖</th><th>ε<sub>a</sub></th></tr></thead>
        <tbody>$(join(rows))$(join(blank))</tbody></table>$note"""
    end

    # Every frame is computed here, in Julia, Jacobians included.  The browser
    # only chooses which frame to display, so the controls work in a static export.
    let
        # Each frame has three plots (p = 0, 1: the two contour maps; p = 2: both zero
        # curves).  The background of each (axes and contours) is the same for every
        # starting point, so it is emitted once per system with an empty
        # <g class="nr-overlay">, and each frame holds only the elements JS drops into it.
        frames = String[]
        basins = String[]
        backgrounds = String[]
        for (si, sys) in enumerate(systems)
            roots = find_roots(sys)
            push!(basins, "<div class=\"nr-basin\" data-s=\"$(si-1)\" hidden>$(basin_svg(sys, roots))</div>")
            bgclips = String[]
            for (a, x₀) in enumerate(sys.x₀s), (b, y₀) in enumerate(sys.y₀s)
                mainplt, maingroups, xs = newton_figure(sys, [x₀, y₀])
                plots = [small_figure(sys, 1, xs), small_figure(sys, 2, xs), (mainplt, maingroups)]
                overlays = String[]
                for (p, (plt, groups)) in enumerate(plots)
                    head, items, clip = split_svg(plt)
                    if length(bgclips) < p
                        push!(bgclips, clip)
                        push!(backgrounds, "<div class=\"nr-bg\" data-s=\"$(si-1)\" data-p=\"$(p-1)\" hidden>$head<g class=\"nr-overlay\"></g></svg></div>")
                    end
                    push!(overlays, "<svg data-p=\"$(p-1)\">$(grouped(items, groups; clip=bgclips[p]))</svg>")
                end
                push!(frames, """<div class="nr-frame" data-s="$(si-1)" data-a="$(a-1)" data-b="$(b-1)" data-n="$(length(xs)-1)" hidden>
                    <template>$(join(overlays))</template>$(newton_table(sys.f, xs))</div>""")
            end
        end
        options = join("<option value=\"$(i-1)\">$(sys.name)</option>" for (i, sys) in enumerate(systems))
        x0s = [collect(sys.x₀s) for sys in systems]
        y0s = [collect(sys.y₀s) for sys in systems]
        HTML("""
        <div class="nr-widget">
          <style>
            .nr-widget .nr-controls { display: flex; gap: 1.5em; flex-wrap: wrap; align-items: center; margin-bottom: .5em; }
            .nr-widget .nr-controls input[type=range] { width: 10em; vertical-align: middle; }
            .nr-widget .nr-row { display: flex; gap: 1em; flex-wrap: wrap; justify-content: center; align-items: flex-start; margin-bottom: .5em; }
            .nr-widget .nr-row .nr-bg { flex: 0 1 300px; }
            .nr-widget .nr-bg[data-p="2"] svg { display: block; margin: 0 auto; }
            .nr-widget .nr-basins { margin-top: 1.5em; }
            .nr-widget .nr-basin { max-width: 380px; }
            .nr-widget svg { max-width: 100%; height: auto; }
            .nr-widget table { border-collapse: separate; border-spacing: 0; margin-top: .5em; font-variant-numeric: tabular-nums; }
            .nr-widget td, .nr-widget th { padding: .15em .8em; text-align: right; border-bottom: 1px solid #ddd; }
          </style>
          <div class="nr-controls">
            <label>System <select class="nr-s">$options</select></label>
            <label>x₀ = <output class="nr-aval"></output>
              <input class="nr-a" type="range" min="0" max="$(length(systems[1].x₀s)-1)" value="$(length(systems[1].x₀s)-1)"></label>
            <label>y₀ = <output class="nr-bval"></output>
              <input class="nr-b" type="range" min="0" max="$(length(systems[1].y₀s)-1)" value="$(length(systems[1].y₀s)-1)"></label>
            <label>iteration <output class="nr-kval"></output>
              <input class="nr-k" type="range" min="0" max="$nsteps" value="$nsteps"></label>
            <label><input class="nr-tan" type="checkbox" checked> show tangent planes</label>
          </div>
          <div class="nr-row">$(join(filter(b -> !occursin("data-p=\"2\"", b), backgrounds)))</div>
          $(join(filter(b -> occursin("data-p=\"2\"", b), backgrounds)))
          $(join(frames))
          <div class="nr-basins">
            <p><strong>Which solution is found?</strong> Every point in the map is a starting
            guess, colored by the solution Newton-Raphson converges to (stars), black if it does
            not converge.  The red dot is the current starting point.</p>
            $(join(basins))
          </div>
        </div>
        <script>
          const root = currentScript.previousElementSibling;
          const sel = root.querySelector(".nr-s"), arng = root.querySelector(".nr-a"), brng = root.querySelector(".nr-b"),
                aout = root.querySelector(".nr-aval"), bout = root.querySelector(".nr-bval"),
                krng = root.querySelector(".nr-k"), kout = root.querySelector(".nr-kval"),
                tan = root.querySelector(".nr-tan");
          const x0s = $x0s, y0s = $y0s;
          function show() {
            const s = +sel.value;
            arng.max = x0s[s].length - 1; brng.max = y0s[s].length - 1;
            aout.value = x0s[s][arng.value].toFixed(1);
            bout.value = y0s[s][brng.value].toFixed(1);
            const k = +krng.value;
            kout.value = k;
            const overlays = {};
            for (const bg of root.querySelectorAll(".nr-bg")) {
              bg.hidden = bg.dataset.s !== sel.value;
              if (!bg.hidden) overlays[bg.dataset.p] = bg.querySelector(".nr-overlay");
            }
            for (const fr of root.querySelectorAll(".nr-frame")) {
              const key = fr.dataset.s + "," + fr.dataset.a + "," + fr.dataset.b;
              fr.hidden = key !== sel.value + "," + arng.value + "," + brng.value;
              if (fr.hidden) continue;
              const n = +fr.dataset.n, kk = Math.min(k, n);   // n = steps actually taken
              // The template holds one <svg data-p> per plot; the <svg> wrapper makes the
              // parser treat the fragment as SVG (self-closing tags, namespace).
              for (const svg of fr.querySelector("template").content.children) {
                const overlay = overlays[svg.dataset.p];
                if (overlay.dataset.frame !== key) {
                  overlay.replaceChildren(...[...svg.children].map(c => c.cloneNode(true)));
                  overlay.dataset.frame = key;
                }
                for (const g of overlay.querySelectorAll(".nr-step")) g.style.display = +g.dataset.i < kk ? "" : "none";
                for (const g of overlay.querySelectorAll(".nr-lin")) g.style.display = (tan.checked && +g.dataset.i === kk) ? "" : "none";
                for (const g of overlay.querySelectorAll(".nr-star")) g.style.display = +g.dataset.k === kk ? "" : "none";
              }
              for (const tr of fr.querySelectorAll("tr[data-i]")) tr.style.visibility = +tr.dataset.i <= kk ? "" : "hidden";
              fr.querySelector(".nr-note").style.visibility = (n < $nsteps && k >= n) ? "" : "hidden";
            }
            for (const bs of root.querySelectorAll(".nr-basin")) {
              bs.hidden = bs.dataset.s !== sel.value;
              if (bs.hidden) continue;
              for (const g of bs.querySelectorAll(".nr-start"))
                g.style.display = (g.dataset.a === arng.value && g.dataset.b === brng.value) ? "" : "none";
            }
          }
          for (const el of [sel, arng, brng, krng, tan]) el.addEventListener("input", show);
          show();
        </script>
        """)
    end
end

md"""
As in one dimension, the iterates converge quadratically once they are close to a
solution, but the starting point decides *which* solution is found, and the pattern
of starting points that lead to each solution can be surprisingly intricate.
"""
