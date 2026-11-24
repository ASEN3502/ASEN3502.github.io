---
title: Lab Collaboration
parent: Guides
nav_order: 2
---

# Lab Collaboration

One of the key Course Learning Outcomes for ASEN 3502 is Teams and Communication.

Walking around the room, I often hear conversations like "You do 1.2 and I will do 1.3." For most labs, this is an understandable strategy, but it is often not the best way to work collaboratively. First, most labs have sequential steps that cannot be strictly parallelized. Second, the goal of the lab is for every student to understand every part.

An alternative strategy is *pair programming*.

## Pair or Ensemble Programming

*Pair programming* (or *ensemble programming*) is a technique for collaboration in writing code. There are two roles:

- One person takes the role of the **driver**. The driver is the only person typing code into the computer, but typing out code is only a small part of the team's work.
- All others serve as **navigators**. The key to pair programming is that, even though navigators don't type any code, **they do most of the work.** Navigators can look things up, highlight and summarize complex parts of the lab, and draft things on their own machines.

One common pitfall in pair programming is that the driver tries to code like a solo programmer and does all the work. Really, the driver should be focused on getting code into files, running tests, and fixing easy bugs. The navigators should have the next steps ready for the driver. This also means that the driver does NOT need to be the best programmer. Typing will require their focus. The purest version of this is expressed in *strong-style pairing*: if you are the driver and you have an idea, you have to switch and become a navigator and tell the new driver to type it.

> For an idea to go from your head into the computer it MUST go through someone else’s hands
>
> — [Llewellyn Falco](https://llewellynfalco.blogspot.com/2014/06/llewellyns-strong-style-pairing.html)
> {: .attribution }

A few final notes are in order:

- I would recommend that only navigators have the lab document open. They can relay instructions to the driver, and this will prevent the driver from losing focus on the code that they are writing.
- If you have multiple navigators and one needs to do some deep thinking/experimentation, they can go to another table or step outside for a moment.
- One thing that I have seen in this lab that I *love* is a 3 ft pointer that someone brought. This allows navigators to easily point to code for drivers to see.
- A final key is to **switch off roles regularly**. A driver should not drive for more than 10–20 minutes.

### Advantages

- Everyone learns.
- You get practice explaining things.
- No need to sync code.

### Challenges

- This is really hard to do. It feels very unnatural at first. Originally I hated it, but in the end I realized that it is better for everyone because it forces wider learning.

## Divide, Conquer, and Consolidate

Occasionally, labs do have sections that are meant to be done by individuals in parallel. In this case, you can either switch into smaller groups and pair program or go it alone.

### Sharing Code

A key challenge when dividing and conquering is sharing code.

- Git is best, but unfortunately it has a *very* steep learning curve. (Claude Code or Codex helps with this tremendously.)
- An alternative that I would suggest is **file discipline** on MATLAB Drive or Dropbox. Structure your code so that each person *owns* a file.
- Claude/ChatGPT can suggest alternatives such as VSCode Live Share, but I do not have experience with these.
