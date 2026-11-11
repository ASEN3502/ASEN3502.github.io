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

## Regression / ML notation

Use these conventions for any regression, nonlinear regression, or machine
learning material.

- Data: `n` samples, `d` input features, `k` outputs.
  - Single input: column vector `\vec{x}_i \in \mathbb{R}^d`. Single target:
    `\vec{y}_i \in \mathbb{R}^k`.
  - Dataset stacked one sample per row: `X \in \mathbb{R}^{n \times d}`
    (row `i` is `\vec{x}_i^T`), `Y \in \mathbb{R}^{n \times k}` (row `i` is
    `\vec{y}_i^T`). This matches scikit-learn, PyTorch, and MATLAB's
    `trainnet`/`fitlm`. MATLAB's older `train`/`fitnet` use the transpose
    (one column per sample); call this out whenever those functions appear.

- Model: `\hat{\vec{y}} = m(\vec{x}; \theta)`.
  - Hat = prediction; no hat = measured target. Residual
    `\vec{r}_i = \vec{y}_i - \hat{\vec{y}}_i`.
  - Argument before the semicolon is the input; after it are the parameters.
  - `\theta` (no arrow, always) is the full collection of model parameters. It
    may be a vector (linear regression) or a set of matrices/vectors (neural
    net); treat it as one long vector when convenient. Hyperparameters
    (learning rate, `\lambda`, polynomial degree, epochs) are NOT part of
    `\theta`.

- Features (basis functions): `\phi_j` is the function, `z_j = \phi_j(\vec{x})`
  is its value (Chapra's `z_j`).
  - General linear least squares indexes from 1: `\phi_1, \dots, \phi_m`,
    `\vec{a} = (a_1, \dots, a_m)`, `Z` is `n \times m`, and `\theta = \vec{a}`.
    Polynomial regression keeps Chapra's `a_0, \dots, a_m`.
  - Stacked: `\vec{z} = \vec{\phi}(\vec{x})`. Model linear in the parameters:
    `\hat{y} = \vec{\phi}(\vec{x})^T \theta`.
  - The design matrix keeps Chapra's name, `Z_{ij} = \phi_j(\vec{x}_i)`; do not
    use Bishop's `\Phi`.

- Loss:
  - Per-sample: `\ell(\hat{\vec{y}}, \vec{y})`, a scalar.
  - Total cost:
    `J(\theta) = \frac{1}{n} \sum_{i=1}^n \ell\big( m(\vec{x}_i; \theta), \vec{y}_i \big)`.
    Write `J(\theta; X, Y)` only when the dataset dependence matters (e.g.
    `J_\text{train}` vs `J_\text{test}`).
  - Regularized: `J_\text{reg}(\theta) = J(\theta) + \lambda R(\theta)`, with
    default `R(\theta) = \|\theta\|^2`.
  - Never use lowercase `l` or capital `L` for loss.

- Training:
  - Problem: minimize `J(\theta)` over `\theta`. Solution:
    `\theta^* = \underset{\theta}{\operatorname{argmin}}\, J(\theta)`.
    Use both forms; `\theta^*` names the answer.

## Demos

Demos are demos, NOT explanations. A little explanatory text is fine, but a
demo does not need to explain everything; the lecture and handouts do that.
