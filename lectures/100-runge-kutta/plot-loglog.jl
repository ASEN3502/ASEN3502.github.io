# Side-by-side comparison of polynomials on linear vs log-log axes for the
# Runge-Kutta lecture: on log-log axes, y = c*x^n is a straight line with
# slope n.
#
#   julia plot-loglog.jl
using Plots
using LaTeXStrings

gr(size=(1200, 500), dpi=200)
default(linewidth=3, legendfontsize=14, tickfontsize=11, guidefontsize=14,
        framestyle=:box, grid=true, gridalpha=0.25)

x = 10 .^ range(-1, 1, length=400)   # 0.1 to 10

polys = [(1, L"y = x",   :steelblue),
         (2, L"y = x^2", :darkorange),
         (3, L"y = x^3", :seagreen),
         (4, L"y = x^4", :firebrick)]

p1 = plot(xlabel="x", ylabel="y", title="Linear axes",
          legend=:topleft, xlims=(0, 3), ylims=(0, 20))
p2 = plot(xlabel="x", ylabel="y", title="Log-log axes",
          legend=false, xscale=:log10, yscale=:log10,
          xticks=10.0 .^ (-1:1), yticks=10.0 .^ (-4:4))

for (n, lab, c) in polys
    plot!(p1, x, x .^ n, label=lab, color=c)
    plot!(p2, x, x .^ n, label=lab, color=c)
end

# Non-polynomials for contrast: e^x and log10(x) (only where log10(x) > 0, so it
# can be shown on a log axis).
xl = 1 .+ 10 .^ range(-4, log10(9), length=400)  # log10(x) > 0 needed on a log axis
for pp in (p1, p2)
    plot!(pp, x, exp.(x), label=L"y = e^x", color=:mediumpurple,
          linestyle=:dash, linewidth=2)
    plot!(pp, xl, log10.(xl), label=L"y = \log_{10} x", color=:gray60,
          linestyle=:dash, linewidth=2)
end

p = plot(p1, p2, layout=(1, 2), margin=5Plots.mm)
savefig(p, joinpath(@__DIR__, "polynomials-linear-vs-loglog.png"))
println("wrote polynomials-linear-vs-loglog.png")
