# Step 06: regression

**The question:** when someone edits the skill later, will a fixed set of tasks catch an edit that makes it worse, without failing an edit that does no harm?

## The problem

Steps 01 to 05 made `test-driven-development` better and showed which parts of it matter. The next edit can undo that: someone shortens the description, or tidies the body and drops the part that does the work. A regression check runs before such an edit is merged. It is only useful if it fails the harmful edits and passes the harmless ones, and the noise from step 01 makes that harder than it sounds.

## The approach

1. **Use the step 01 tasks and rubric as the regression set.** They are small, they finish in a few minutes, and earlier steps give a history of results for the current skill.
2. **Write edits with a known effect,** and check that the set tells them apart from the current skill:
   - **baseline:** the skill as it is in [`skills/`](../skills/).
   - **reworded:** the same rules in new words: new headings, a rewritten summary line, two steps reworded. It should pass.
   - **old description:** the description from before step 02, which tells the agent not to load the skill unless the router sent it there. Steps 00 and 02 showed that this lowers loading. It should fail.
   - **no cycle:** the five-step cycle removed. Step 03 showed that this lowers the score by about 14 points. It should fail.
3. **Run all four in one run,** 3 runs per task: 60 cells, scored.
4. **Set the pass line from history,** not from one run: the results of the current skill with Sonnet 4.6 in steps 02 to 06.

## Results

Claude Sonnet 4.6 as agent and grader.

| Version | Mean | Test seen failing first (of 15) | Skill loaded (of 15) | Expected |
|---|---|---|---|---|
| baseline | 92.7 | 12 | 13 | pass |
| reworded | 91.3 | 11 | 12 | pass |
| old description | 84.0 | 7 | 10 | fail |
| no cycle | 77.3 | 4 | 15 | fail |

The same skill and model in earlier runs, 15 cells each:

- **mean score:** 84.0 to 98.0 over eight runs.
- **test seen failing first:** 8 to 14 of 15 over the same runs.

What this shows:

- **The large regression is easy to catch.** No cycle scored below every earlier run of the current skill, on both measures.
- **The small regression hides in the noise of the mean.** Old description scored 84.0, which is inside the range of the current skill. On the mean alone it would pass.
- **The rule-specific count separates better.** Old description saw the test fail first in 7 of 15, below every earlier run of the current skill. A pass line of "at least 8 of 15" fails both harmful edits and passes the harmless one. With only 15 cells, a result of 7 or 8 is close to the line, and one more run is needed before you trust it.
- **Check loading separately, and cheaply.** The old description did its harm through loading: the skill loaded in 10 of 15 runs, against 13. A loading check (step 00), with the body replaced by a stop line and no scoring, catches that kind of edit at much lower cost than scored tasks.

A useful regression check for a skill is two parts:

1. a loading check on the requests that should and should not load it;
2. a small scored set, judged by the item the skill exists for (here, the test seen failing first), with the pass line set from several earlier runs.

## What it costs

60 cells for this run. A check of one edit against the baseline is 30 cells: two versions, five tasks, three runs. Credits are described at https://tessl.io/pricing/.

## Run it yourself

The versions are in [`versions/`](versions/), as full copies of `sdlc-implementation`. [`arms.json`](arms.json) has one arm per version. To check an edit of your own, copy `versions/baseline`, make the edit, and add an arm for it next to the baseline.

```sh
tessl eval run 01-variability/tasks \
  --variant-json 06-regression/arms.json \
  --agent claude --model claude-sonnet-4-6 \
  --scorer-agent claude --scorer-model claude-sonnet-4-6 \
  -n 3 -f --yes --label regression
```

Then count, per version, the runs that saw the test fail first:

```sh
tessl eval view <run-id> --json | jq -r '.data.attributes.scenarios[].solutions[] | .variant as $v | .runs[] | [$v, ((.assessmentResults // [])[] | select(.name == "R1_red_first") | .score)] | @tsv' | sort | uniq -c
```

To run the check on every change to a skill, call the same command from CI with a path filter on the skill's directory, so it runs only when the skill changes.
