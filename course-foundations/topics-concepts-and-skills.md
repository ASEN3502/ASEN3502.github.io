---
title: Topics, Concepts, and Skills
parent: Course Foundations
nav_order: 2
---

# Topics, Concepts, and Skills

The scope of ASEN 3502, organized by [Course Learning Outcome](clos).

## Definitions

- A *topic* is a broad subject area or category of study within a course. It provides the context or "bucket" for learning.
- A *concept* is a fundamental idea, principle, or relationship that helps explain how things work within a topic. It builds understanding of the theory behind engineering phenomena.
- A *skill* is a practical ability to apply concepts to solve problems, analyze systems, or design solutions. It focuses on application — what a student can do with their knowledge attained in a class.

> **Note:** The concept definition seems to imply that concepts should be grouped by topic, but based on John's comments,[^issue-7] I have abandoned this hierarchy.

## CLO 1: Numerical Methods

### Topics

- Numerical solution of linear algebraic equations
- Numerical solution of nonlinear algebraic equations
- Numerical solution of ODEs (initial value problems and boundary value problems)
- Numerical optimization
- Regression
- Visualizing and interpreting computed results

> **Note:** A list of algorithms for these topics is maintained on the [List of Algorithms](algorithms) page.

### Concepts

- Computational problem classes (algebraic, differential, optimization, regression)
- Specific numerical methods for solving problems within each topic

### Skills

- Using a computer to solve problems in each topic

## CLO 2: Problem Formulation

### Topics

- Construction of a mathematical model
- Identifying key assumptions and neglected effects
- Qualitative understanding of well-posedness (existence, uniqueness, stability)
- Classification of mathematical models (algebraic, ODE, optimization)
- Domain of validity and physical interpretation

### Concepts

- Model hierarchy: physical -> mathematical -> computational -> computer
- Model simplification and fidelity
- Boundary/initial conditions and well-posedness
- Scaling, nondimensionalization, and conditioning
- Domain of validity and physical interpretation
- Interpretation of numerical results in physical and engineering context

### Skills

- Translating a concrete engineering problem into a computational problem

## CLO 3: Evaluation

### Topics

- Grid/time-step refinement and empirical order estimation
- Stability analysis, stiffness, and time-step limits
- Analysis of algorithms (computational complexity at the algorithm level)
- Verification (against benchmark or analytical solutions)
- Validation (against experimental data)
- Presenting and defending computational decisions with evidence

### Concepts

- Verification ("Did we solve the equations right?") and validation ("Did we solve the right equations?")
- Evaluation criteria: computational cost, accuracy, complexity, stability
- Error and uncertainty quantification
- Sensitivity and conditioning

### Skills

- Reasoning about an algorithm apart from implementation (i.e. with pseudocode)
    - Correctness
    - Complexity
    - Accuracy
- Communication of computational judgments
- Verification of algorithms with tests
- Validation of computational results with data

## CLO 4: Implementation

### Topics

- Scientific programming
    - History of programming
- Basic software engineering
- Program performance
- Documentation and sharing code
- AI use in programming!

### Concepts

- Software design principles: modularity, readability, maintainability
- Testing and reproducibility
- ~~Documentation and visualization~~
- ~~Computational ethics and professionalism~~
- Performance optimization
    - Memory (stack vs. heap)
    - Parallelism

### Skills

- Writing down numerical methods as algorithms (pseudocode)
- Implementing an algorithm as an efficient computer program
    - Profiling
- Using code written by others and writing code for others to use
- Profiling and optimizing code performance

## CLO 5: Self-Learning

### Topics

- Exploration of external aerospace-related libraries
- Adapting third-party algorithms or data sources
- Designing small experiments to test or verify new methods
- Summarizing and presenting self-directed work to peers

### Concepts

- Self-learning strategies for computational methods
- Reading and interpreting external documentation and literature
- Integrating new tools responsibly into an existing computational workflow
- Verification and benchmark of external code
- Reflection, communication, and documentation of independent learning

### Skills

- Finding and implementing an algorithm to solve an engineering problem without previous exposure to the algorithm

[^issue-7]: [Issue #7](https://github.com/zsunberg/CU-Computational-Methods-Planning/issues/7) in the CU-Computational-Methods-Planning repository.
