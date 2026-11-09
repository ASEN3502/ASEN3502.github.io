# Renders datasaurus-dozen.png: the thirteen Datasaurus Dozen datasets
# (Matejka & Fitzmaurice, CHI 2017, after Alberto Cairo's Datasaurus), each
# with its least-squares line. Every panel has the same x̄, ȳ, s_x, s_y, r, and
# therefore the same fitted line, to two decimals.
#
#   julia datasaurus-dozen.jl          (needs Plots in the default environment)
#
# Data: DatasaurusDozen-Long.tsv from the R datasauRus package (MIT).

using Plots, Statistics, Printf, DelimitedFiles

dir = @__DIR__
raw = readdlm(joinpath(dir, "DatasaurusDozen-Long.tsv"), '\t'; skipstart=1)
names = String.(raw[:, 1]); xs = Float64.(raw[:, 2]); ys = Float64.(raw[:, 3])

order = ["dino", "away", "h_lines", "v_lines", "x_shape",
         "star", "high_lines", "dots", "circle", "bullseye",
         "slant_up", "slant_down", "wide_lines"]
label = Dict("dino" => "dino", "away" => "away", "h_lines" => "h lines", "v_lines" => "v lines",
             "x_shape" => "x shape", "star" => "star", "high_lines" => "high lines", "dots" => "dots",
             "circle" => "circle", "bullseye" => "bullseye", "slant_up" => "slant up",
             "slant_down" => "slant down", "wide_lines" => "wide lines")

function fitline(x, y)                     # a_1 = r s_y / s_x, a_0 = ȳ - a_1 x̄
    a1 = cor(x, y) * std(y) / std(x)
    return mean(y) - a1 * mean(x), a1
end

panels = []
for nm in order
    sel = names .== nm
    x, y = xs[sel], ys[sel]
    a0, a1 = fitline(x, y)
    p = scatter(x, y; ms=2.5, msw=0, color=:black, legend=false,
                xlims=(0, 100), ylims=(0, 100), ticks=0:50:100, tickfontsize=6,
                title=label[nm], titlefontsize=10, framestyle=:box, grid=false)
    plot!(p, [0, 100], [a0, a0 + 100a1]; color="#b06a00", lw=2)
    push!(panels, p)
    @printf("%-11s n=%d  x̄=%.2f ȳ=%.2f s_x=%.2f s_y=%.2f r=%.3f  ŷ = %.2f + %.3f x\n",
            nm, length(x), mean(x), mean(y), std(x), std(y), cor(x, y), a0, a1)
end

x, y = xs[names .== "dino"], ys[names .== "dino"]
a0, a1 = fitline(x, y)
stats = @sprintf("Every panel: n = %d,  x̄ = %.2f,  ȳ = %.2f,  s_x = %.2f,  s_y = %.2f,  r = %.2f,  least-squares line  ŷ = %.1f %s %.2f x",
                 length(x), mean(x), mean(y), std(x), std(y), cor(x, y), a0, a1 < 0 ? "−" : "+", abs(a1))
blank = plot(; framestyle=:none, legend=false)
push!(panels, blank, blank)

fig = plot(panels...; layout=(3, 5), size=(1500, 950), margin=3Plots.mm,
           plot_title=stats, plot_titlefontsize=13)
savefig(fig, joinpath(dir, "datasaurus-dozen.png"))
println("wrote datasaurus-dozen.png")
