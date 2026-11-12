# Renders multiple-linear-regression.png: data with two inputs (x_1, x_2), the
# least-squares plane ŷ = a_0 + a_1 x_1 + a_2 x_2, and the residuals. Points
# above the plane are filled; points below it are open with dashed residuals.
#
#   julia multiple-linear-regression.jl     (needs Plots and LaTeXStrings in the default environment)
#
# The 3D scene is drawn by hand with an oblique projection so the drawing order
# (below the plane, the plane, above the plane) is under our control.

using Plots, LaTeXStrings, LinearAlgebra

x1 = [0.30, 0.85, 0.75, 0.25, 0.55, 0.42, 0.90, 0.12]
x2 = [0.15, 0.25, 0.80, 0.75, 0.30, 0.55, 0.65, 0.30]
Z = [ones(length(x1)) x1 x2]

# Residuals are chosen by hand, then projected so they are orthogonal to the
# columns of Z. The least-squares fit then recovers the plane below exactly.
r = [0.18, 0.20, 0.16, 0.15, -0.15, -0.18, -0.14, -0.16]
r -= Z * (Z \ r)
y = Z * [0.60, 0.12, -0.20] + r

a = Z \ y                                   # least-squares coefficients (a_0, a_1, a_2)
plane(u, v) = a[1] + a[2] * u + a[3] * v
yhat = plane.(x1, x2)

k = 0.5                                     # oblique projection: x_2 points toward the viewer, down and to the left
px(u, v, w) = u - k * v
py(u, v, w) = w - k * v
P(pts) = (px.(first.(pts), getindex.(pts, 2), last.(pts)), py.(first.(pts), getindex.(pts, 2), last.(pts)))

blue, red, amb, grey = "#123f63", "#c02a2a", "#b06a00", "#888888"
fig = plot(; size=(1000, 700), legend=false, framestyle=:none, aspect_ratio=:equal,
           xlims=(-0.9, 1.85), ylims=(-0.85, 1.32))

# floor rectangle and the walls dropping from the plane's corners
corners = [(0.0, 0.0), (1.0, 0.0), (1.0, 1.0), (0.0, 1.0)]
plot!(fig, P([(u, v, 0.0) for (u, v) in [corners; corners[1]]])...; color=grey, lw=1, ls=:dot)
for (u, v) in corners
    plot!(fig, P([(u, v, 0.0), (u, v, plane(u, v))])...; color=grey, lw=1, ls=:dot)
end

# axes
for (tip, lbl, off) in [((1.3, 0.0, 0.0), L"x_1", (0.06, 0.0)), ((0.0, 1.45, 0.0), L"x_2", (-0.05, -0.04)),
                        ((0.0, 0.0, 1.2), L"y", (0.0, 0.06))]
    xs, ys = P([(0.0, 0.0, 0.0), tip])
    plot!(fig, xs, ys; color=:black, lw=1.5, arrow=true)
    annotate!(fig, xs[2] + off[1], ys[2] + off[2], text(lbl, 20))
end

below = findall(y .< yhat); above = findall(y .>= yhat)
seg(i) = P([(x1[i], x2[i], y[i]), (x1[i], x2[i], yhat[i])])
pt(i) = P([(x1[i], x2[i], y[i])])

# points below the plane, seen through it
for i in below
    plot!(fig, seg(i)...; color=red, lw=2, ls=:dash)
    scatter!(fig, pt(i)...; ms=9, color=:white, msc=blue, msw=2)
end

# the fitted plane
plot!(fig, P([(u, v, plane(u, v)) for (u, v) in [corners; corners[1]]])...;
      seriestype=:shape, fillcolor=amb, fillalpha=0.28, linecolor=amb, lw=2)

# points above the plane
for i in above
    plot!(fig, seg(i)...; color=red, lw=2)
    scatter!(fig, pt(i)...; ms=9, color=blue, msw=0)
end

annotate!(fig, px(1.0, 0.0, plane(1.0, 0.0)) + 0.04, py(1.0, 0.0, plane(1.0, 0.0)) + 0.03,
          text(L"\hat{y} = a_0 + a_1 x_1 + a_2 x_2", 18, amb, :left))

savefig(fig, joinpath(@__DIR__, "multiple-linear-regression.png"))
println("a = ", round.(a; digits=3), ";  above: ", length(above), ", below: ", length(below))
