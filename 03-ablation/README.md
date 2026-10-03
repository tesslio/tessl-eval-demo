# Step 03: ablation

**The question:** starting from a skill that works, which parts of it does the agent need? Remove one part at a time and measure what drops.

## The problem

Step 02 cut `test-driven-development` from 328 lines to 29 and the score went up. Most of the original did nothing measurable, or got in the way. The 29 lines are now the skill, but nobody has shown that each of them earns its place. A part that does nothing still costs the reader time and the agent context, and it makes the next edit harder to judge.

## The approach

1. **Split the skill into parts.** The short version has four: a one-line summary, the five-step cycle, a list of rules (with a link to a reference on writing tests), and a "before you say it is done" list.
2. **Write one version per part removed,** and two that test larger cuts. Keep the name and description the same in every arm, so loading is equal and only the body differs:
   - **full:** the skill as it is now, as the control.
   - **no cycle:** the five steps removed.
   - **no rules:** the rules removed, with the link to the reference.
   - **no done check:** the final list removed.
   - **cycle only:** only the five steps kept.
   - **description only:** no body at all.
3. **Run every version on the step 01 tasks and rubric,** 3 runs each: 6 arms, 5 tasks, 90 cells, scored.
4. **Repeat the arms that decide the result** in a second run: full, cycle only and description only, 45 cells.

The skill says "watch the test fail first" in five places: the description, the summary line, the cycle, the rules and the done list. Removing one part at a time may show no drop because another part repeats the rule. The two larger cuts test that.

## Results

Claude Sonnet 4.6 as agent and grader. All four plugins installed in every arm.

| Version | First run | Second run | Test seen failing first (of 15, per run) |
|---|---|---|---|
| full | 91.3 | 90.0 | 11, 10 |
| cycle only | 94.0 | 85.3 | 12, 8 |
| no done check | 85.3 | not rerun | 8 |
| no rules | 82.7 | not rerun | 8 |
| no cycle | 78.7 | not rerun | 5 |
| description only | 76.0 | 76.0 | 3, 4 |

- **The cycle is the part that matters.** Every version without it scored 76 to 79, about 14 points below the full skill. The agent still wrote good tests and correct code, but it rarely ran the new test and saw it fail first. The description says "watch it fail" too, and that alone was not enough.
- **The cycle alone did about as well as the full skill.** Cycle only led by 3 points in the first run and trailed by 5 in the second. Over 30 runs each the two are within a point. These tasks show no gain from the rules or the done list, and no loss either.
- **Lower scores for no rules and no done check came from loading.** In those arms the skill loaded in 10 of 15 runs, against 13 for the full skill. In the runs where it loaded they scored 90 and 94. The description is the same in every arm, so this is the loading noise from step 01, not an effect of the body.
- **Repetition hides what each part does.** Removing the rules or the done list one at a time leaves the red-first rule in the cycle. Only removing the cycle showed a drop.

The skill in [`skills/`](../skills/) is unchanged. Thirty runs per arm cannot tell a difference of a few points, and the rules cover cases these five tasks do not test, such as a test that is hard to write. A larger task set would be needed before cutting them.

## What it costs

90 cells for the comparison and 45 for the repeat: 135 in all. Credits are described at https://tessl.io/pricing/.

## Run it yourself

Each version is in [`versions/`](versions/), as a full copy of the `sdlc-implementation` plugin. Only `skills/test-driven-development/SKILL.md` differs between them. [`arms.json`](arms.json) has one arm per version, and installs the other three plugins from [`skills/`](../skills/). To remove a different part, copy `versions/full`, delete the part from its `SKILL.md`, and add an arm for it.

```sh
tessl eval run 01-variability/tasks \
  --variant-json 03-ablation/arms.json \
  --agent claude --model claude-sonnet-4-6 \
  --scorer-agent claude --scorer-model claude-sonnet-4-6 \
  -n 3 -f --yes --label ablation
```

To repeat the deciding arms, run the same command with `--variant-json 03-ablation/arms-confirm.json`.

Then compare the arms:

```sh
tessl eval view <run-id> --json | jq -r '.data.attributes.scenarios[].solutions[] | [.variant, ([.runs[].score] | map(tostring) | join(" "))] | @tsv' | sort
```

## What's next

Step 04, in situ, runs the skill in a real codebase as well as in the small one used so far, to see whether the gain holds where the work is real.
