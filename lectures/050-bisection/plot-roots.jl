# The two plots for the bisection lecture: e^x and 4*sqrt(x) crossing (two
# intersections), and f(x) = e^x - 4*sqrt(x) against a bold zero line.
#
#   julia plot-roots.jl
using Plots

gr(size=(800, 500), dpi=200)
default(linewidth=3, legendfontsize=13, tickfontsize=11, guidefontsize=14,
        framestyle=:box, grid=true, gridalpha=0.25)

x = range(0, 2, length=600)

p1 = plot(x, exp.(x), label="e^x", color=:steelblue,
          xlabel="x", ylabel="y", legend=:topleft)
plot!(p1, x, 4 .* sqrt.(x), label="4*sqrt(x)", color=:darkorange)
savefig(p1, joinpath(@__DIR__, "exp-vs-sqrt.png"))

f(x) = exp(x) - 4 * sqrt(x)
p2 = plot(x, f.(x), label="f(x) = e^x - 4*sqrt(x)", color=:steelblue,
          xlabel="x", ylabel="f(x)", legend=:topleft)
hline!(p2, [0], label="", color=:black, linewidth=4)
savefig(p2, joinpath(@__DIR__, "f-with-zero.png"))

println("wrote exp-vs-sqrt.png and f-with-zero.png")
