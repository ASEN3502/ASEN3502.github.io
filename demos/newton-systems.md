---
title: Newton-Raphson for Systems
parent: Demos
grand_parent: Materials
nav_order: 6
lecture: 070-nonlinear-systems
---

# Newton-Raphson for Systems

A [Pluto](https://plutojl.org) notebook in Julia, exported to a static page.
Newton-Raphson for two equations in two unknowns: each step replaces the two
curves by their tangent lines and jumps to where the lines cross.

[Open full page](newton-systems/newton-systems.html){: .btn .btn-primary }
[Download the notebook](newton-systems/newton-systems.jl){: .btn }

{::nomarkdown}
<iframe src="newton-systems/newton-systems.html" title="Newton-Raphson for systems notebook"
        style="width: 100%; height: 85vh; border: 1px solid #ddd; border-radius: 4px;"></iframe>
{:/}

To run it yourself, install Julia, then

```julia
import Pkg; Pkg.add("Pluto"); import Pluto; Pluto.run()
```

and open the downloaded `newton-systems.jl` from the Pluto start page.
