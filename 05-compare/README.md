# Step 05: model, agent and judge comparison

**The question:** with the skill and the tasks held fixed, which models and coding agents get the most out of the skill? And does the model that grades change the verdict?

## The problem

A skill is written once and then used with whatever model and coding agent people have. A skill that helps one model a lot can do nothing for another: the model may never load it, or may already do what it asks. The grader is a model too, and a different grader can score the same work differently.

## The approach

1. **Keep the tasks and rubric from step 01,** and the skills from [`skills/`](../skills/).
2. **Run each setup with and without the skills,** and compare the gain, not only the score with skills. A strong model can score well without any skill.
   - **Models,** with the `claude` agent: Claude Sonnet 4.6 (the model in every step so far), Claude Opus 5, Claude Haiku 4.5.
   - **Agents:** the `tessl` agent with Sonnet 4.6, against the `claude` agent with the same model. The `codex` agent with `gpt-6-sol`, which differs in both agent and model.
   - 5 setups, 2 arms each, 5 tasks, 3 runs: 150 cells, scored by Sonnet 4.6.
3. **Change the grader.** Run the Sonnet 4.6 setup with skills again, graded by Opus 5 and by Haiku 4.5, 15 cells each.

Each variant in [`arms.json`](arms.json) sets its own `agent` and `model`, so every setup runs in one eval run and the comparison is made inside it. The grader is set for the whole run, so each grader needs a run of its own.

## Results: models and agents

All graded by Sonnet 4.6.

| Setup | No skills | Skills | Gain | Test seen failing first, with skills (of 15) | Skill loaded, with skills (of 15) |
|---|---|---|---|---|---|
| claude, Opus 5 | 70.0 | 99.3 | +29 | 15 | 15 |
| codex, gpt-6-sol | 70.0 | 90.0 | +20 | 10 | not reported |
| claude, Sonnet 4.6 | 64.7 | 84.0 | +19 | 8 | 14 |
| tessl, Sonnet 4.6 | 66.0 | 77.3 | +11 | 5 | not reported |
| claude, Haiku 4.5 | 50.7 | 54.7 | +4 | 0 | 0 |

- **The stronger the model, the more it gets from the skill.** Opus 5 loaded the skill in every run and saw the test fail first in every run. Haiku 4.5 never loaded any skill, so for Haiku the skills changed nothing.
- **Without the skills, every setup scores about the same.** 65 to 70 for all but Haiku: the code is correct and tested, but no setup ran the test before writing the code. The rule the skill teaches is the difference.
- **The agent matters as well as the model.** With the same model, the `claude` agent gained 19 points and the `tessl` agent 11. The `codex` agent with its own model gained 20.
- **Not every agent reports which skills it loaded.** For `codex` and `tessl` the eval records scores, but not loading, so a low gain there cannot be split into "did not load" and "did not follow".
- **Cost goes up with the skill.** With the skills, Opus 5 cost about four and a half times as much per run as without, because it follows the whole workflow: in every run it also loaded the verification and both code review skills. Sonnet 4.6 cost about three times as much.

The Opus 5 arms ran in a separate eval run from the others. A first attempt with Opus 5.5 failed in every cell before the agent started. Step 01 showed that scores move between runs, so compare the Opus row to the others with that in mind.

## Results: judges

The Sonnet 4.6 setup with the skills, graded by three models:

| Grader | Mean | Test seen failing first (of 15) |
|---|---|---|
| Sonnet 4.6 | 84.0 | 8 |
| Opus 5 | 95.0 | 13 |
| Haiku 4.5 | 83.3 | 8 |

- **Each grader scored a different set of agent runs.** Changing the grader starts new agent runs: `tessl eval run` does not grade earlier work again. So these numbers mix the grader with the run-to-run spread of the agent, which step 01 measured.
- **The spread is inside what the agent alone produces.** The same setup, graded by Sonnet 4.6, has seen the test fail first in 8 to 14 of 15 runs across steps 02 to 06. Opus 5's 13 and Haiku 4.5's 8 are both inside that range.
- **Every grader based full marks on the evidence.** In all three runs, each full score for "test seen failing first" cites a failing line in the test log written before the code changed. No grader gave full marks without it.
- **A rubric with fixed scores leaves the grader little to decide.** Step 01 rewrote the rubric so that missing evidence gets a fixed score. Here the three graders applied that rule in the same way. A rubric that asks for judgment ("is this test good?") would give the grader more room, and the choice of grader would matter more.

To separate the grader from the agent, grade the same agent runs with each grader. That is not possible with `tessl eval run` today.

## What it costs

150 cells for the models and agents, 30 for the Opus 5 rerun, and 35 for the graders (a 5-cell test and two runs of 15). A failed attempt with Opus 5.5 took 60 more. Credits are described at https://tessl.io/pricing/.

## Run it yourself

[`arms.json`](arms.json) has the ten variants. To compare your own setups, edit the `agent` and `model` of each pair; `tessl eval run --list-agents` lists the ones you can use.

```sh
tessl eval run 01-variability/tasks \
  --variant-json 05-compare/arms.json \
  --agent claude --model claude-sonnet-4-6 \
  --scorer-agent claude --scorer-model claude-sonnet-4-6 \
  -n 3 -f --yes --label compare
```

To compare graders, run the Sonnet 4.6 arm once per grader:

```sh
tessl eval run 01-variability/tasks \
  --variant-json 05-compare/arms-judge.json \
  --agent claude --model claude-sonnet-4-6 \
  --scorer-agent claude --scorer-model <grader-model> \
  -n 3 -f --yes --label judge
```
