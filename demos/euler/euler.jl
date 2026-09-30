# Euler's method: convergence and stability.
#
# This is a plain Julia script written so that Pluto can open it as a notebook
# (Pluto splits a plain .jl file into one cell per top-level expression):
#
#   julia> import Pluto; Pluto.run()          # then open this file in the UI
#
# A cell containing a `# hide` comment has its code folded in the export.
#
# The interactive figures are frames precomputed in Julia plus a few lines of
# JS that pick which frame to show, so they still work in a static HTML export.

md"""
# Euler's Method: Convergence and Stability

Euler's method integrates $\dot{x} = f(t, x)$ by stepping along the slope at the
start of each step:

$$x_{i+1} = x_i + h\, f(t_i, x_i)$$

The function below has the same inputs and outputs as MATLAB's `ode45`: it takes
`f`, a time span `(t0, t_f)`, and the initial condition `x0`, and returns the
vectors `t` and `x`.
"""

function euler(f, tspan, x0, h)
    t0, tf = tspan
    t = collect(t0:h:tf)
    x = zeros(length(t))
    x[1] = x0
    for i in 1:length(t)-1
        x[i+1] = x[i] + h * f(t[i], x[i])
    end
    return t, x
end;

md"""
## Convergence

Test problem: $\dot{x} = -x + \sin t$ with $x(0) = 1$ on $t \in [0, 6]$, which has the
exact solution

$$x(t) = \tfrac{3}{2} e^{-t} + \tfrac{1}{2}(\sin t - \cos t).$$
"""

f(t, x) = -x + sin(t);

x_exact(t) = 1.5exp(-t) + 0.5(sin(t) - cos(t));

x_general(C, t) = C * exp(-t) + 0.5(sin(t) - cos(t));

tspan = (0.0, 6.0);

x0 = 1.0;

md"""
Drag the slider to change the step size `h`.  The red bar marks the **global error**
at the final time, $|x_N - x(t_f)|$.
"""

# hide
using Printf

# Time-series frames, one per h, plus the widget that picks a frame.
# hide
begin
    using Plots

    hs = [1.0, 0.5, 0.25, 0.1, 0.05, 0.025, 0.01, 0.005]

    global_error(h) = abs(euler(f, tspan, x0, h)[2][end] - x_exact(tspan[2]))

    function euler_figure(h)
        t, x = euler(f, tspan, x0, h)
        tt = range(tspan...; length=400)
        plt = plot(; xlabel="t", ylabel="x", ylims=(-1.0, 1.4), size=(640, 380), legend=:topright,
                   title=@sprintf("h = %.3f,  N = %4d steps", h, length(t)-1), titlefontsize=11)
        for (k, C) in enumerate(-1.0:0.25:2.5)        # other solutions of the same ODE
            plot!(plt, tt, x_general.(C, tt); lw=1, color=:gray, alpha=0.35,
                  label=(k == 1 ? "other solutions" : ""))
        end
        plot!(plt, tt, x_exact.(tt); lw=2.5, color=:black, label="exact")
        plot!(plt, t, x; lw=1.5, marker=:circle, ms=3, color=:dodgerblue, label="Euler")
        plot!(plt, [t[end], t[end]], [x_exact(t[end]), x[end]]; lw=4, color=:red,
              label=@sprintf("global error = %.4f", global_error(h)))
        return plt
    end

    svg(plt) = (io = IOBuffer(); show(io, MIME"image/svg+xml"(), plt); String(take!(io)))

    let
        frames = join("""<div class="eu-frame" data-h="$(i-1)" hidden>$(svg(euler_figure(h)))</div>"""
                      for (i, h) in enumerate(hs))
        HTML("""
        <div class="eu-widget">
          <style>
            .eu-widget input[type=range] { width: 18em; vertical-align: middle; }
            .eu-widget svg { max-width: 100%; height: auto; }
          </style>
          <label>h = <output class="eu-hval"></output>
            <input class="eu-h" type="range" min="0" max="$(length(hs)-1)" value="2"></label>
          $frames
        </div>
        <script>
          const root = currentScript.previousElementSibling;
          const rng = root.querySelector(".eu-h"), out = root.querySelector(".eu-hval");
          const hs = $hs;
          function show() {
            out.value = hs[rng.value];
            for (const fr of root.querySelectorAll(".eu-frame")) fr.hidden = fr.dataset.h !== rng.value;
          }
          rng.addEventListener("input", show);
          show();
        </script>
        """)
    end
end

md"""
Plotting the global error at $t_f$ against `h` on log-log axes shows a straight line of
slope 1: halving `h` halves the error.  Euler's method is **first order**, the
global error is $O(h)$.
"""

# hide
let
    errs = global_error.(hs)
    function loglog_figure(sel)
        plt = plot(hs, errs; xscale=:log10, yscale=:log10, marker=:circle, lw=2, color=:dodgerblue,
                   xlabel="h", ylabel="global error", label="Euler", legend=:topleft, size=(640, 380),
                   grid=true, gridalpha=0.25, minorgrid=true, minorgridalpha=0.1)
        plot!(plt, hs, errs[end] .* hs ./ hs[end]; ls=:dash, color=:gray, label="slope 1 reference")
        scatter!(plt, [hs[sel]], [errs[sel]]; color=:red, ms=7,
                 label=@sprintf("h = %.3f, error = %.4f", hs[sel], errs[sel]))
        return plt
    end
    frames = join("""<div class="ll-frame" data-h="$(i-1)" hidden>$(svg(loglog_figure(i)))</div>"""
                  for i in eachindex(hs))
    # This widget follows the h slider in the widget above (same document, different cell).
    HTML("""
    <div class="ll-widget"><style>.ll-widget svg { max-width: 100%; height: auto; }</style>$frames</div>
    <script>
      const root = currentScript.previousElementSibling;
      function show() {
        const rng = document.querySelector(".eu-h"), v = rng ? rng.value : "2";
        for (const fr of root.querySelectorAll(".ll-frame")) fr.hidden = fr.dataset.h !== v;
      }
      document.addEventListener("input", e => { if (e.target.classList.contains("eu-h")) show(); });
      show();
    </script>
    """)
end

md"""
## Stability

Now the test problem is $\dot{x} = -a x$ with $x(0) = 1$, whose exact solution
$x(t) = e^{-at}$ decays to zero for any $a > 0$.  Euler's method gives

$$x_{i+1} = x_i - h\,a\,x_i = (1 - ah)\,x_i, \qquad\text{so}\qquad x_i = (1 - ah)^i.$$

The numerical solution decays only if $|1 - ah| < 1$, that is, if $h < 2/a$.
For $1/a < h < 2/a$ it still decays, but with the wrong sign every other step.
For $h > 2/a$ it **grows** without bound, no matter how small the true solution is.
Drag the sliders past $h = 1/a$ and then $h = 2/a$.
"""

# hide
begin
    as = [1.0, 2.0, 4.0, 8.0]
    hs2 = [0.05, 0.1, 0.125, 0.2, 0.25, 0.3, 0.4, 0.5, 0.6, 0.8, 1.0, 1.2, 1.5, 2.0, 2.5]
    tspan2 = (0.0, 10.0)

    function stability_figure(a, h)
        t, x = euler((t, x) -> -a * x, tspan2, 1.0, h)
        tt = range(tspan2...; length=120)
        g = 1 - a * h
        regime = abs(g) < 1 ? (g < 0 ? "stable, oscillating" : "stable") : abs(g) == 1 ? "marginal" : "unstable"
        plt = plot(; xlabel="t", ylabel="x", ylims=(-2, 2), size=(640, 380), legend=:topright,
                   title=@sprintf("a = %.0f,  h = %.3f,  1 − ah = %5.2f:  %s", a, h, g, regime), titlefontsize=11)
        Cs = [s * 3.0 * 10.0^k for k in 0:4 for s in (-1, 1)]   # other solutions, log-spaced so some are still on the axes after one big step
        for (k, C) in enumerate(Cs)
            plot!(plt, tt, C .* exp.(-a .* tt); lw=1, color=:gray, alpha=0.35,
                  label=(k == 1 ? "other solutions" : ""))
        end
        plot!(plt, tt, exp.(-a .* tt); lw=2.5, color=:black, label="exact")
        plot!(plt, t, x; lw=1.5, marker=:circle, ms=3, color=:dodgerblue, label="Euler")
        return plt
    end

    let
        frames = join("""<div class="st-frame" data-a="$(ai-1)" data-h="$(hi-1)" hidden>$(svg(stability_figure(a, h)))</div>"""
                      for (ai, a) in enumerate(as), (hi, h) in enumerate(hs2))
        HTML("""
        <div class="st-widget">
          <style>
            .st-widget .st-controls { display: flex; gap: 1.5em; flex-wrap: wrap; align-items: center; margin-bottom: .5em; }
            .st-widget input[type=range] { width: 14em; vertical-align: middle; }
            .st-widget svg { max-width: 100%; height: auto; }
          </style>
          <div class="st-controls">
            <label>a = <output class="st-aval"></output>
              <input class="st-a" type="range" min="0" max="$(length(as)-1)" value="0"></label>
            <label>h = <output class="st-hval"></output>
              <input class="st-h" type="range" min="0" max="$(length(hs2)-1)" value="4"></label>
          </div>
          $frames
        </div>
        <script>
          const root = currentScript.previousElementSibling;
          const arng = root.querySelector(".st-a"), aout = root.querySelector(".st-aval"),
                hrng = root.querySelector(".st-h"), hout = root.querySelector(".st-hval");
          const as = $as, hs = $hs2;
          function show() {
            aout.value = as[arng.value]; hout.value = hs[hrng.value].toFixed(1);
            for (const fr of root.querySelectorAll(".st-frame"))
              fr.hidden = !(fr.dataset.a === arng.value && fr.dataset.h === hrng.value);
          }
          for (const el of [arng, hrng]) el.addEventListener("input", show);
          show();
        </script>
        """)
    end
end

md"""
The size of the amplification factor $|1 - ah|$ tells the whole story: it must be
below 1 for the numerical solution to decay.
"""

# hide
let
    ah = range(0, 3; length=300)
    plt = plot(ah, abs.(1 .- ah); lw=2.5, color=:dodgerblue, label="|1 − ah|",
               xlabel="ah", ylabel="amplification factor per step", ylims=(0, 2.2), size=(640, 300),
               legend=:topleft, grid=true, gridalpha=0.25)
    hline!(plt, [1]; color=:red, ls=:dash, label="growth threshold")
    vspan!(plt, [0, 2]; color=:green, alpha=0.1, label="stable: h < 2/a")
    plt
end
