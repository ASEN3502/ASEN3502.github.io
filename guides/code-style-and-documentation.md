---
title: Code Style and Documentation
parent: Guides
grand_parent: Materials
nav_order: 3
---

# Code Style and Documentation

Code is meant to be read by two entities. The first is by far the easiest to communicate with: the computer. The second, and usually most important and most difficult, is other humans who will need to use and help maintain your code.

I used to have a lot of bad ideas that I generated myself or picked up from engineering professors.
During my PhD, I started writing software with other people and began asking myself "What is the best way to do this? How can I decide whether my colleague's way of writing the code or my way is right?"
Two things helped me immensely:

1. I worked at Google for a summer and saw how code was developed by a leading software company (test every line!).
2. I decided to pick up books by people who do this for a living and have the wisdom to make the right calls. In particular, the book I go to first is [Clean Code](https://www.oreilly.com/library/view/clean-code-a/9780136083238/) by [Robert C. Martin](https://en.wikipedia.org/wiki/Robert_C._Martin).

[![Clean Code book cover](https://www.oreilly.com/covers/urn:orm:book:9780136083238/296w/?format=webp)](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)

This helped me understand where bad smells are coming from and that there *are* right answers for how to write code in many cases. This page holds a few high-level thoughts and pointers to other resources. Learning to write good code that is readable by humans is a lifelong endeavor.

## Structure

In my opinion, the most important part of writing good code is structuring it well.
The best metaphor I have is Legos.
You should be able to take small pieces of code and put them together to build beautiful things.
One expression of this in *Clean Code* is "Functions should do one thing." (unfortunately MATLAB makes this very hard - more on this in other guides later).
It is also very important to think about interfaces (the little studs and other features on Legos) - will your code fit well with the code that others write?

## Style

All programming languages allow programmers to do the same thing in multiple ways.
The set of choices among multiple technically correct ways to do things is known as "style".
This can include everything from indentation and capitalization to whether or not to use a language feature (e.g. using anonymous functions or passing arguments through bigger functions in MATLAB).

The most important principle is to **follow the style of the surrounding code**. For example, if the code you are working with capitalizes function names, keep capitalizing function names. This will make the overall code much easier to understand. Software companies and open source communities have style guides for this purpose, for example [Python's PEP 8](https://peps.python.org/pep-0008/#naming-conventions), the [Google Python style guide](https://google.github.io/styleguide/pyguide.html), or [Richard Johnson's MATLAB style guidelines](https://www.mathworks.com/matlabcentral/fileexchange/46056-matlab-style-guidelines-2-0/files/MatlabStyle2%20book.pdf).

### Naming

One very important aspect of style is naming things (variables, functions, files, etc.). Naming is one of the hardest problems in computer science. *Clean Code* has an entire chapter on the subject: Meaningful Names.
Some of the most useful points from this chapter are:

- Use intention-revealing (descriptive) names: e.g. `earth_relative_velocity` or `vE` instead of `vector`
- The length of a name should correspond to its scope: `r` is good if it is in a 5-line for loop `for r = rows`; if it is returned by a function, it should be `row` or something longer (row of what?).
- Use pronounceable (and memorable) names: e.g. `fmincon` instead of `fminconstr`
- Pick one word per concept: e.g. `numel` means total number of elements; `size` is the size of all dimensions in an array

It is also very important to know your audience. Every aerospace engineer will know that `flaps` refers to movable surfaces designed to increase lift at low speed, but a computer scientist may think the term includes things like ailerons or elevators.

## Comments

You have heard that it was said "Comment your code", but I tell you "Comments do not make up for bad code".

(By "I tell you", I really mean this is repeated from *Clean Code*.)

The problem with comments is that bad comments mislead, and worse comments lie.

Usually, this is because the code around the comment changes. Tests can be used to verify that code is correct after changes, but tests do nothing to make sure comments are correct. For example, imagine some code originally said
```
% kinetic energy
energy = 0.5*m*v^2
```
but two months later, your colleague makes a change:
```
% kinetic energy
energy = 0.5*m*v^2 + m*9.81*h
```
This comment is now a lie, and anyone reading it will have to spend time thinking about which thing is a lie. The solution is better variable naming that will be more difficult for your colleague to mess up:
```
kinetic_energy = 0.5*m*v^2
```
or, if it appears in a small scope,
```
ke = 0.5*m*v^2
```

*Clean Code* offers a long list of types of comments to avoid, and a shorter list of cases where comments are helpful.

One thing that differs between educational environments and research or industry environments is that in research or industry, you should **never keep commented-out code** or multiple versions. Commenting out code is useful in development when you want to try removing something. But once you have settled on a correct implementation, you should remove the clutter. Never keep it around as a switch for someone else to uncomment - it can easily become stale or incorrect. Old code will be saved in your version control system (e.g. git) if you need it.

## Documentation

Instead of comments, write documentation.

Sometimes it is easier to say something to a computer in one way and a human in another. The part written in a way for a human to understand is documentation. It is useful to think about [four types of documentation](https://diataxis.fr/): tutorials, how-tos, explanation, and reference, which should all be written in distinct styles and rarely mixed. In this class, we will only focus on *reference* documentation.

Documentation should occur at the interface where someone else will use the code. For the purposes of this course, that means providing *help text*, also known as "docstrings", for your MATLAB functions as demonstrated [here](https://www.mathworks.com/help/matlab/matlab_prog/add-help-for-your-program.html). Help text should clearly describe the inputs and outputs of the function and any information about the internal workings that might be necessary to use the function, e.g. "returns a local minimum that may not be the global minimum".

*Clean Code* suggests that you should document only public interfaces, but in engineering, a much larger percentage of the code will be maintained and modified by others, so we typically document more of it.
An extremely important practice in documentation is "Don't Repeat Yourself" (DRY). Documentation that is not DRY is hard to maintain, because, if someone makes a change, they have to make it everywhere it is repeated.
The main strategy to keep things DRY is to maintain an easy-to-access source of truth and link to it, as I did with help text above.
