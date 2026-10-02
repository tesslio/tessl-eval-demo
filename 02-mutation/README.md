# Step 02: mutation

**The question:** with the tasks held fixed, which version of a skill's instructions makes the agent do the job better?

## The problem

Step 01 found that `test-driven-development` loads, and the agent then writes good tests and correct code, but almost never runs the new test and sees it fail before changing the code. That is the rule the skill exists for, and the skill already marks it "MANDATORY. Never skip." This step tries other ways of writing the same rule and measures which one the agent follows.

## The approach

1. **Make the skill load every time first.** The skill's description told the agent not to load it unless the router sent it there, so it loaded in only 29 of 50 runs in step 01. A change to the instructions can only help in runs where the skill loads. Every arm here gets one new, shorter description without that clause (see the second example in [step 00](../00-activation-testing/)). With the body replaced by a stop line, the skill then loaded in 13 of 14 runs (15 cells).
2. **Write a few versions, each testing one idea about the broken rule.** Change only the body. Keep the name and description the same in every arm, so loading is equal and only the instructions differ:
   - **checklist first:** a three-step gate at the very top: write the test, run it and see it fail, only then open the production file.
   - **record red:** quote the failing output before editing, and again in the final reply under "Red:".
   - **short:** the same rules in 29 lines instead of 328, with the long tables of excuses and examples removed.
   - **action order:** "your first edit is a test file; your next command runs the tests".
3. **Run every version against the current body on the step 01 tasks and rubric,** 3 runs each: 5 arms, 5 tasks, 75 cells, scored. Step 01 showed that 15 cells per arm sees a difference of about 13 points.

## Results

Claude Sonnet 4.6 as agent and grader. All four plugins installed in every arm. Two runs, each comparing the versions inside the run:

| Version | First run | Second run | Test seen failing first (of 15, per run) |
|---|---|---|---|
| current body | 69.3 | 77.3 | 0, 4 |
| checklist first | 90.0 | 86.0 | 10, 9 |
| record red | 72.7 | not rerun | 1 |
| short | 90.7 | 89.3 | 11, 10 |
| action order | 74.0 | not rerun | 2 |

- **Two versions work, two do not.** Putting the cycle at the top (checklist first) and cutting the skill to its rules (short) both beat the current body in both runs. Asking for evidence (record red) and stating an order of actions (action order) stayed within noise in the first run, so the second run left them out.
- **The gain is in the one broken rule.** The other rubric items were already near full marks. The working versions moved "test seen failing first" from 0 or 4 of 15 to 9 to 11 of 15.
- **The size of the gain moves between runs.** The current body scored 69.3 in the first run and 77.3 in the second, so the short version's lead was 21 points and then 12. Both runs put it ahead, and over the 30 runs per arm it leads by about 17 points. Compare versions inside one run, and repeat a result before you trust its size.
- **Shorter did as well as longer.** The short version keeps the rules and drops 300 lines of tables, examples and warnings, and scores at least as well as the long version with a checklist added. A likely reason, not tested here: in the long version the red-first rule sits about 100 lines down among many others, and the agent acts on what it reads first.

The short version is now in [`skills/`](../skills/). Its full text is in [`versions/short`](versions/short/sdlc-implementation/skills/test-driven-development/SKILL.md).

## What it costs

15 cells to check loading, 75 for the first comparison and 45 for the second (three versions): 135 in all. Credits are described at https://tessl.io/pricing/.

## Run it yourself

Each version is in [`versions/`](versions/), as a full copy of the `sdlc-implementation` plugin. Only `skills/test-driven-development/SKILL.md` differs between them:

- **`current`:** the body as it was, with the new description.
- **`checklist-first`, `record-red`, `short`, `action-order`:** the same description, with the body changed as described above.
- **`current-stubbed`:** the body replaced by a stop line, for the loading check.

[`arms.json`](arms.json) has one arm per version. Each arm installs that version's `sdlc-implementation` and the other three plugins from `00-activation-testing/after/plugins/`, so the versions differ in one file only. To try a version of your own, copy `versions/current`, edit the body of its `SKILL.md`, and add an arm for it.

Check that the skill loads, then compare the versions on the step 01 tasks:

```sh
tessl eval run 01-variability/tasks \
  --variant-json 02-mutation/arms-activation.json \
  --agent claude --model claude-sonnet-4-6 \
  -n 3 --skip-scoring -f --yes --label mutation-activation
tessl eval run 01-variability/tasks \
  --variant-json 02-mutation/arms.json \
  --agent claude --model claude-sonnet-4-6 \
  --scorer-agent claude --scorer-model claude-sonnet-4-6 \
  -n 3 -f --yes --label mutation
```

Then compare the arms:

```sh
tessl eval view <run-id> --json | jq -r '.data.attributes.scenarios[].solutions[] | [.variant, ([.runs[].score] | map(tostring) | join(" "))] | @tsv' | sort
```

## What's next

Step 03, ablation, asks the opposite question: starting from a skill that works, which parts can go? The short version already suggests that most of the original did nothing measurable.
