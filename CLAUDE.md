# ASEN 3502 course site

## Math notation

Typeset math (demos, pseudocode, handouts) follows, in order of precedence:

1. Chapra (the course textbook), e.g. stopping tolerances `E_s` when the
   compared quantity has units and `\varepsilon_s` for percent errors.
2. The instructor's handwritten notation where it differs from Chapra: vectors
   always carry an arrow, `\vec{x}`, not Chapra's `{x}` braces and never bold
   `\mathbf{x}`.
3. The MDO book (https://mdobook.github.io) for variable names Chapra does not
   define, e.g. multivariable optimization (step size `\alpha`, etc.).
4. Algorithms for Optimization (https://algorithmsbook.com/optimization/) for
   the machine-learning optimizers it covers and the MDO book does not, e.g.
   Adam (`\gamma_v`, `\gamma_s`), but keep the handouts' subscripted iterates
   `\vec{x}_k`, not that book's `\vec{x}^{(k)}`.
