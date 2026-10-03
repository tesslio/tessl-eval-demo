# Step 01: variability

**The question:** if you run the same eval twice, with nothing changed, how much does the result move? And so, how many runs does a comparison need before a difference means something?

## The problem

An agent does not do the same thing twice. Give it the same task, the same skills and the same model, and one run writes the test first while the next writes the code first. A single run of a new skill version that scores 10 points higher may only be a lucky run.

Every later step compares versions: of a skill, of a model, of an agent. Each comparison needs to know how big the noise is, so this step comes before them.

## The approach

1. **Pick one skill and a few tasks it should handle.** Here: `test-driven-development`, and five small behavior changes to the linkbox codebase (two bug fixes, three features).
2. **Use one rubric for every task.** The same five items, so scores can be compared across tasks:
   - the test was seen failing before the production code changed (3 points);
   - the test checks the behavior that was asked for (2);
   - the behavior is correct (2);
   - the full suite passed after the last change (2);
   - the change is limited to what was asked (1).
3. **Make the evidence visible to the grader.** The grader sees the files and git history, not the conversation. The test command writes one line per run inside `.git`: exit code, and a hash of each source and test file. From that the grader can see whether a test failed before the source changed.
4. **Run one version many times.** One arm, five tasks, ten runs each: 50 cells, scored.
5. **Read the spread,** per task and overall, and work out how many runs a comparison needs.

## Results

All four plugins installed, as a user would have them, so the router decides when to hand work to `test-driven-development`. Claude Sonnet 4.6 as agent and grader.

| Task | Mean | Range | Skill loaded |
|---|---|---|---|
| status-json | 70.0 | 70 to 70 | 9 of 10 |
| fractional-ttl | 67.8 | 60 to 70 | 1 of 10 |
| status-unknown | 65.0 | 40 to 100 | 7 of 10 |
| remaining-command | 80.0 | 70 to 100 | 3 of 10 |
| resolve-namespace | 75.0 | 70 to 100 | 9 of 10 |
| **All** | **71.5** | standard deviation 12.0 | 29 of 50 |

- **The score is mostly one decision.** Nearly every run gets the behavior, the test and the final green run right, and scores 70. The runs that score 100 are the few (5 of 48) where the agent ran the new test and saw it fail before writing the code.
- **Loading varies as much as scores.** On `fractional-ttl` the skill loaded in 10 of 10 runs in a first run of this step, and in 1 of 10 in the second. Same arm, same task, one day apart.
- **The skill helps a little, when it loads.** Mean 73.4 with it loaded, 68.4 without.

### How many runs a comparison needs

With a standard deviation of 12 points per cell, two arms need about this many cells each (5% false-alarm rate, 80% chance to see a real difference):

| Difference to detect | Cells per arm |
|---|---|
| 30 points | 3 |
| 20 points | 6 |
| 15 points | 11 |
| 10 points | 23 |

Five tasks at three runs each (15 cells per arm) sees a difference of about 13 points. That is the size the next steps use.

## What went wrong on the way

The first run of this step used the same tasks, without two fixes, and its numbers could not be trusted:

- **Many agents ran `node --test` directly,** which skips the logging test command, so the grader had no log. The rubric said "at most half marks" in that case, and the grader gave 0, 1 or 1.5 for the same evidence. Part of the spread was the grader, not the agent.
- **The fixes:** the codebase README now says to run the suite with `npm test`, as a real project's README would, and the rubric gives a fixed score when the log is missing. In the second run the log was missing in 5 cells instead of most, and the grader scored every missing log the same way.

Write the grading rules for missing evidence before the first run. A rubric that leaves partial marks to the grader adds noise you then cannot separate from the agent's.

## What it costs

50 cells per run of this step. It took two runs here, 100 cells. Credits are described at https://tessl.io/pricing/.

## Run it yourself

The tasks are in [`tasks/`](tasks/), one directory each:

- **`task.md`:** what the user types, then one line asking for the reply in `REPLY.md`.
- **`setup.sh`:** builds the starting state: installs the logging test command, adds a "Tests" section to the README, and commits the codebase. It is the same in every task.
- **`criteria.json`:** the rubric. Its `context` tells the grader what it can see and records the starting hashes of every file, so it can tell a test run before the code change from one after.
- **`scenario.json`:** installs `tasks/linkbox/` as the codebase and runs `setup.sh`.

`tasks/linkbox/` is a copy of [`codebase/linkbox/`](../codebase/linkbox/), because `tessl eval run` reads a task's codebase only from inside the directory it runs.

To try a task's setup before spending a run on it:

```sh
cp -R 01-variability/tasks/linkbox /tmp/try && cp 01-variability/tasks/status-unknown/setup.sh /tmp/try/
cd /tmp/try && sh setup.sh && npm test && cat .git/test-runs.log
```

Then lint and run all five, ten times each:

```sh
tessl eval lint 01-variability/tasks
tessl eval run 01-variability/tasks \
  --variant-json 01-variability/arms.json \
  --agent claude --model claude-sonnet-4-6 \
  --scorer-agent claude --scorer-model claude-sonnet-4-6 \
  -n 10 -f --yes --label variability
```

Then read the scores per task:

```sh
tessl eval view <run-id> --json | jq -r '.data.attributes.scenarios[] | (.path | split("/") | last) as $s | [$s, ([.solutions[].runs[].score] | map(tostring) | join(" "))] | @tsv'
```

## What's next

The result points at the next step. The skill's central rule, watch the test fail before writing code, is followed in about 1 run in 10. Step 02, mutation, holds the tasks fixed and tries versions of the skill's instructions aimed at that rule.
