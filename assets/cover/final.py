import numpy as np, matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.colors import LinearSegmentedColormap
from matplotlib.collections import LineCollection

GOLD, BLACK = "#cfb87c", "#0a0a0c"
A, B = 1.0, 100.0
f = lambda x, y: (A-x)**2 + B*(y-x*x)**2
g = lambda x, y: np.array([-2*(A-x) - 4*B*x*(y-x*x), 2*B*(y-x*x)])

def momentum(p0, a, beta, n, tol=1e-7):
    p, v, out = np.array(p0, float), np.zeros(2), []
    for _ in range(n):
        out.append(p.copy())
        if f(*p) < tol: break
        v = beta*v - a*g(*p); p = p + v
    return np.array(out)

P = momentum((-1.5, 1.55), 0.0009, 0.86, 4000)
print("steps", len(P), "f_end %.2e" % f(*P[-1]), "end", P[-1].round(4))

def render(name, xlim, ylim, W, light=False):
    ratio = (xlim[1]-xlim[0])/(ylim[1]-ylim[0])
    fig, ax = plt.subplots(figsize=(W/100, W/ratio/100), dpi=100)
    fig.subplots_adjust(0,0,1,1)
    X, Y = np.meshgrid(np.linspace(*xlim, 1400), np.linspace(*ylim, 1400))
    Z = np.log10(f(X, Y) + 1e-3)
    if light:
        cmap = LinearSegmentedColormap.from_list(
            "cul", ["#6b4c00", GOLD, "#e8dcbd", "#f7f3e8", "#ffffff", "#ffffff"])
        ax.contourf(X, Y, Z, levels=80, cmap=cmap)
        ax.contour(X, Y, Z, levels=24, colors="#8a7538", linewidths=0.5, alpha=0.35)
        path_c, edge, bg = (0.10,0.10,0.11), GOLD, "white"
    else:
        cmap = LinearSegmentedColormap.from_list(
            "cu", ["#fff6dd", GOLD, "#8a7538", "#2b2a26", BLACK, BLACK])
        ax.contourf(X, Y, Z, levels=80, cmap=cmap)
        ax.contour(X, Y, Z, levels=24, colors=GOLD, linewidths=0.5, alpha=0.30)
        path_c, edge, bg = (1,1,1), GOLD, BLACK

    seg = np.stack([P[:-1], P[1:]], axis=1)
    al = np.linspace(0.22, 1.0, len(seg))
    ax.add_collection(LineCollection(seg, colors=[path_c+(a*0.55,) for a in al],
                                     linewidths=5.5, capstyle="round", zorder=3))
    ax.add_collection(LineCollection(seg, colors=[path_c+(a,) for a in al],
                                     linewidths=2.0, capstyle="round", zorder=4))
    ax.plot(P[::5,0], P[::5,1], "o", color=path_c, ms=2.4, alpha=0.7, zorder=5)
    ax.plot(*P[0], "o", color=path_c, ms=10, mec=edge, mew=2, zorder=6)
    ax.plot(A, A, "*", color=path_c, ms=30, mec=edge, mew=1.8, zorder=7)
    ax.set_xlim(*xlim); ax.set_ylim(*ylim); ax.set_axis_off()
    fig.savefig(name, facecolor=bg); plt.close(fig)
    print("wrote", name)

render("hero-dark.png",   (-1.75, 1.95), (-0.35, 1.75), 1600)
render("hero-light.png",  (-1.75, 1.95), (-0.35, 1.75), 1600, light=True)
render("banner-dark.png", (-1.80, 2.35), (-0.30, 1.42), 1800)
