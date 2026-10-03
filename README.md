# Tessl eval demo: improving agent skills with evals

This repository shows the different kinds of eval run you can use to improve a set of agent skills, one step at a time, on one set of skills and one codebase.

A skill is a document that tells a coding agent how to do one job well: plan a feature, write tests first, debug from the root cause, finish a branch safely. You cannot tell by reading a skill whether it helps. An eval runs a real agent on real tasks, many times, with and without a change, and scores the results. It turns "I think this skill is better" into a number you can check.

## The steps

Each step answers one question about one kind of eval run. Most steps use one skill, `test-driven-development`, from end to end, so you can follow one skill through every kind of run. Each step has its own directory with a write-up, the scenarios, and the commands to run it yourself.

1. **[00: Activation](00-activation-testing/)**: does the agent use each skill when it should, and leave it alone when it should not?
   *Status:* method written up, with one worked example: the router now loads on 11 of 15 everyday and easy-to-miss requests, against 2 of 15 before, with no wrong loads.
2. **[01: Variability](01-variability/)**: run the same eval again with nothing changed. How much does the score move, and how many runs does a comparison need?
   *Status:* done. Scores move by 12 points per run; five tasks at three runs each sees a difference of about 13 points.
3. **[02: Mutation](02-mutation/)**: hold the tasks fixed and try versions of a skill's instructions. Which version does the job better?
   *Status:* done. A 29-line version of the skill beat the 328-line original in two runs, by 21 and 12 points; the agent runs the new test and sees it fail first in about two runs of three, against fewer than one in seven.
4. **[03: Ablation](03-ablation/)**: remove one part of a skill at a time and measure what drops. Which parts matter?
   *Status:* done. The five-step cycle carries the skill: without it the score drops by about 14 points, and the cycle alone scores within a point of the whole skill.
5. **[04: In situ](04-in-situ/)**: run the skill in an empty project and in a real codebase. Does it help more or less where the work is real?
   *Status:* done. The skills add about 31 points in the codebase and about 10 in an empty project. The skill works as well in both places when it loads, but in the empty project it loads in only a third of runs.
6. **[05: Model, agent and judge comparison](05-compare/)**: which models and coding agents get the most out of the skill, and does the grading model change the verdict?
   *Status:* done. Opus 5 gains 29 points from the skills, Sonnet 4.6 19, Haiku 4.5 4 (it never loads them). Three graders gave results inside the agent's own run-to-run spread.
7. **[06: Regression](06-regression/)**: a fixed set of tasks that catches a later change that makes the skill worse.
   *Status:* done. The set fails an edit that drops the cycle and passes a harmless rewording. An edit that lowers loading hides in the noise of the mean, but not in the count of runs that see the test fail first.

## How an eval works here

- **A task** is what a user would type, for example "Get rid of that experiment branch." A setup script builds the starting state first: git history, branches, a failing test.
- **A rubric** lists what a good result looks like, item by item. A second model scores each run against it.
- **A version** is one configuration of the skills, for example the old and the new text of one skill. Every version runs every task.
- **Repetition:** agents vary from run to run, so each task runs several times per version. Versions are compared only inside one run, because results also move from day to day.
- **What is recorded:** each run keeps the score, the rubric reasons, and which skills the agent loaded.

## What is in the repository

- **[`skills/`](skills/)**: the skills as they stand after every step so far, in four plugins: planning, implementation, assurance, and a router (`delivery-flow`) that carries a whole task and hands each stage to the right skill. They are derived from Superpowers (MIT); see `NOTICE`.
- **[`codebase/linkbox/`](codebase/linkbox/)**: a small multi-tenant URL shortener that every task works on. `tessl eval run` reads a task's codebase only from inside the directory it runs, so each set of tasks carries its own copy of it.
- **`00-activation-testing/` to `06-regression/`**: one per step, each with a README that gives the question, the method, the result, the cost, and the commands to run it on your own skills.

The eval run pages behind these results are private to the workspace that ran them, so each README states the numbers it reports.

## Getting started

You need the Tessl CLI and an account. Eval runs use credits; see https://tessl.io/pricing/. Each step's write-up says how many task runs it needs.

```bash
curl -fsSL https://install.tessl.io | sh
tessl login
tessl project create --workspace <your-workspace>
```

Then open a step's directory and follow its README.
