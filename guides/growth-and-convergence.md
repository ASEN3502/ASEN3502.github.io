---
title: Function Growth and Convergence
parent: Guides
grand_parent: Materials
nav_order: 1
---

# Function Growth and Convergence

Big-O notation appears in two places in this course:

- **Growth**: a problem size $$n$$ gets *large*, and we ask how fast the cost
  of an algorithm grows.
- **Convergence**: a step size $$h$$ gets *small*, and we ask how fast the
  error of an approximation shrinks.

The definition is the same. Only the limit changes, and that flips which terms
matter.

## Growth: $$n \to \infty$$

### Definition

> $$f(n) = O(g(n))$$ **as $$n \to \infty$$** if there exist positive constants
> $$c$$ and $$n_0$$ such that
>
> $$0 \le f(n) \le c\,g(n) \quad \text{for all } n \ge n_0$$

Past some $$n_0$$, a constant multiple of $$g$$ stays above $$f$$. Play with
$$c$$ and $$n_0$$ in the
[Big-O Definition demo]({{ "/demos/big-o-definition.html" | relative_url }}).

The "$$=$$" is not an equality: $$O(g(n))$$ is a *set* of functions, and
$$f(n) = O(g(n))$$ means $$f$$ belongs to it. That is why
$$\tfrac{2}{3}n^3 + O(n^2)$$ makes sense. Chapra reads $$O(m^n)$$ more loosely
as "terms of order $$m^n$$ and lower."

### Useful Rules

- $$c f(n) = O(f(n))$$ for any constant $$c > 0$$.
- If $$f_1(n) = O(n^a)$$ and $$f_2(n) = O(n^b)$$, then
  $$f_1(n) + f_2(n) = O\left(n^{\max(a,b)}\right)$$.
- If $$f_1(n) = O(n^a)$$ and $$f_2(n) = O(n^b)$$, then
  $$f_1(n) \cdot f_2(n) = O\left(n^{a+b}\right)$$.
- If $$\lvert f(n) \rvert$$ is bounded, then $$f(n) = O(1)$$.

**Example.** Gaussian elimination takes $$\tfrac{2}{3}n^3 + O(n^2)$$ flops,
so it is $$O(n^3)$$.

### Hierarchy

$$O(1) \subsetneq O(\log \log n) \subsetneq O(\log n) \subsetneq O(n) \subsetneq O(n^2) \subsetneq O(n^3) \subsetneq O(n^k) \subsetneq O(a^n) \subsetneq O(n!)$$

for $$k > 3$$ and $$a > 1$$.

|  | $$O(1)$$ | $$O(\log\log n)$$ | $$O(\log n)$$ | $$O(n)$$ | $$O(n^2)$$ | $$O(n^3)$$ | $$O(n^k)$$ | $$O(a^n)$$ | $$O(n!)$$ |
|---|---|---|---|---|---|---|---|---|---|
| **Flops to solve $$[A]\{x\} = \{b\}$$**, $$[A]$$ is $$n \times n$$ | | | | Gaussian elimination specialized to a banded (e.g. tridiagonal) $$[A]$$ | Triangular solve: $$[L]\{d\} = \{b\}$$ or $$[U]\{x\} = \{d\}$$ | Gaussian elimination | | | Cramer's rule |
| **$$f$$ calls to solve $$f(x) = 0$$** with bracket width $$\Delta x$$ and tolerance $$E_s$$, $$n = \Delta x / E_s$$ | | Newton-Raphson (near the root) | Bisection | Naive incremental search | | | | | |

In the second row, $$n$$ is the number of $$E_s$$-wide cells in the bracket.
Incremental search visits every cell. Bisection halves the bracket each call.
Newton-Raphson squares the error each call, doubling the number of correct
digits.

## Convergence: $$h \to 0$$

### Definition

> $$E(h) = O(g(h))$$ **as $$h \to 0$$** if there exist positive constants $$c$$ and
> $$h_0$$ such that
>
> $$\lvert E(h) \rvert \le c\,g(h) \quad \text{for all } 0 < h \le h_0$$

Usually $$g(h) = h^p$$, and $$p$$ is the **order of accuracy**: halving $$h$$
divides the error by about $$2^p$$.

Since $$h \to 0$$, $$h^3 \ll h^2 \ll h$$, so the **smallest** exponent
dominates and higher powers are discarded. Taylor series are the usual source:

$$f(x + h) = f(x) + h f'(x) + \frac{h^2}{2} f''(x) + O(h^3)$$

The forward difference $$\frac{f(x+h) - f(x)}{h}$$ has error $$O(h)$$; the
central difference $$\frac{f(x+h) - f(x-h)}{2h}$$ has error $$O(h^2)$$.
Euler's method has global error $$O(h)$$; see the
[Euler's Method demo]({{ "/demos/euler.html" | relative_url }}).

### Useful Rules

Same as for growth, with $$\max$$ replaced by $$\min$$.

- $$c\,h^p = O(h^p)$$ for any constant $$c > 0$$.
- If $$E_1(h) = O(h^a)$$ and $$E_2(h) = O(h^b)$$, then
  $$E_1(h) + E_2(h) = O\left(h^{\min(a,b)}\right)$$.
- If $$E_1(h) = O(h^a)$$ and $$E_2(h) = O(h^b)$$, then
  $$E_1(h) \cdot E_2(h) = O\left(h^{a+b}\right)$$.
- If $$E(h) = O(h^p)$$, a log-log plot of $$\lvert E \rvert$$ against $$h$$
  has slope $$p$$. From two step sizes,

  $$p \approx \frac{\log\left(E(h_1) / E(h_2)\right)}{\log\left(h_1 / h_2\right)}$$

- If $$E(h) = O(1)$$, the method does not converge.

### Hierarchy

$$O(h^p) \subsetneq O(h^4) \subsetneq O(h^3) \subsetneq O(h^2) \subsetneq O(h) \subsetneq O(1)$$

for $$p > 4$$. The direction is reversed from growth: the *smallest* class is
now on the left, and a method in a class to the left converges faster.

|  | $$O(h^4)$$ | $$O(h^3)$$ | $$O(h^2)$$ | $$O(h)$$ | $$O(1)$$ |
|---|---|---|---|---|---|
| **Global error of ODE solvers**, step size $$h$$ | Classical RK4 | | Heun's method, midpoint method (RK2) | Euler's method | |
| **Error of derivative approximations**, increment $$h$$ | | | Central difference | Forward or backward difference | |

**Don't confuse this with the order of an iteration.** Newton-Raphson's
$$E_{t,i+1} \approx C\,E_{t,i}^2$$ describes error from one iterate to the
next as $$i \to \infty$$; no $$h$$ is involved.
