# Tessl eval demo: improving agent skills with evals

<!-- DRAFT. Open before publishing:
     1. Step status below is as of 2026-09-28. -->

This repository shows the different kinds of eval run you can use to improve a set of agent skills, one step at a time, on one set of skills and one codebase.

A skill is a document that tells a coding agent how to do one job well: plan a feature, write tests first, debug from the root cause, finish a branch safely. You cannot tell by reading a skill whether it helps. An eval runs a real agent on real tasks, many times, with and without a change, and scores the results. It turns "I think this skill is better" into a number you can check.

## The steps

Each step answers one question, and passes its improved skills to the next. Each has its own directory with the skills before and after, a write-up, and the instructions an agent follows to run it.

1. **[00: Activation](00-activation-testing/)**: does the agent use each skill when it should, and leave it alone when it should not?
   *Status:* in progress. The method is written up, with one worked example: the router now loads on 11 of 15 everyday and easy-to-miss requests, against 2 of 15 before, with no wrong loads. Three changes are applied so far; the remaining skills are next, one at a time.
2. **01: Mutation**: once a skill is loaded, which changes to its instructions make the agent do the job better?
   *Status:* not started.
3. **02: Model and agent comparison**: which models and coding agents get the most out of these skills?
   *Status:* not started. An early comparison of three models is in [METHOD.md](METHOD.md).
4. **03: Ablation**: which parts of each skill matter? Remove a part and measure what drops.
   *Status:* not started.
5. **04: Regression**: a fixed set of tasks that catches a later change that makes the skills worse.
   *Status:* not started. This step's output is the final, regression-tested skills.

A step starts only when the previous one is conclusive for every skill.

## How an eval works here

- **A task** is what a user would type, for example "Get rid of that experiment branch." A setup script builds the starting state first: git history, branches, a failing test.
- **A rubric** lists what a good result looks like, item by item. A second model scores each run against it.
- **A version** is one configuration of the skills, for example the old and the new text of one skill. Every version runs every task.
- **Repetition:** agents vary from run to run, so each task runs several times per version. Versions are compared only inside one run, because results also move from day to day.
- **What is recorded:** each run keeps the score, the rubric reasons, and which skills the agent loaded.

## What is in the repository

- **[`plugins/`](plugins/)**: the nine skills under test, in four plugins: planning, implementation, assurance, and a router (`delivery-flow`) that runs a whole task and hands each stage to the right skill. They are derived from Superpowers (MIT); see `NOTICE`.
- **[`scenarios/repo/`](scenarios/repo/)**: `linkbox`, a small multi-tenant URL shortener that every task works on.
- **`00-activation-testing/`, and later step directories**: one per step.
- **[`METHOD.md`](METHOD.md)**: the first version of this repository: runs with and without the skills, a three-model comparison, and notes on writing tasks that separate versions.

## Getting started

You need the Tessl CLI and an account. Eval runs use credits; see https://tessl.io/pricing/. Each step's write-up says how many task runs it needs.

```bash
curl -fsSL https://install.tessl.io | sh
tessl login
tessl project create --workspace <your-workspace>
```

Then open a step's directory and follow its README.
