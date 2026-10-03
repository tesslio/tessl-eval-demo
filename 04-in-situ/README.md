# Step 04: in situ

**The question:** does a skill help as much in an empty project as in a real codebase, or more, or less?

## The problem

A skill is often tried out in an empty directory: ask for a small function, see what the agent does. Users then run it in a codebase with code, tests and a README. The two can give different answers. An eval run only in an empty project can show a skill as weak when it works in real code, or the other way round.

## The approach

1. **Write matched tasks for two places.**
   - **In the codebase:** the five step 01 tasks on linkbox, unchanged.
   - **In an empty project:** the same five behaviors, asked for as new code. The project has only `package.json`, a README that says to run `npm test`, and the logging test command. For example, step 01 asks for `status` to print `unknown` for a code that was never registered; here the request is to write `status(expiryByCode, code, nowMs)` that returns `unknown` for a code that is not in the map.
2. **Use the same rubric in both places.** For the empty project, "red first" means a failing test run before the module exists, or before its final version.
3. **Run with and without the skills.** Two arms: the four plugins from [`skills/`](../skills/), and no plugins. 10 tasks, 2 arms, 3 runs each: 60 cells, scored.
4. **Compare the gain from the skills in each place,** not the raw scores: the tasks in the two places are not equally hard.
5. **Repeat the skills arm** in a second run, 30 cells, to check the result inside one run.

## Results

Claude Sonnet 4.6 as agent and grader.

| Place | No skills | Skills, first run | Skills, second run | Test seen failing first, with skills (of 15, per run) | `test-driven-development` loaded (of 15, per run) |
|---|---|---|---|---|---|
| linkbox | 62.7 | 89.3 | 98.0 | 10, 14 | 11, 14 |
| empty project | 59.3 | 71.3 | 66.7 | 5, 5 | 5, 5 |

- **The skills help much less in the empty project.** The gain is about 31 points in linkbox and about 10 in the empty project.
- **The cause is loading, not the skill.** When `test-driven-development` loaded in the empty project, all 10 of those runs scored 100, the same as in linkbox. It loaded in 10 of 30 empty-project runs and in 25 of 30 linkbox runs. In most empty-project runs no skill loaded at all.
- **On some empty-project tasks the agent wrote no test at all,** with or without the skills. A likely reason, not tested here: a request such as "Write `src/status.js` exporting `status(...)`" reads as a few lines to write, not as a change to a project.
- **Without skills, no run saw a test fail first,** in either place.

If you test a skill only in an empty project, the result can be much lower than what users see in a codebase.

The skill in [`skills/`](../skills/) is unchanged. The fix for this result belongs to activation (step 00): the description says to use the skill when "a change alters code behavior", and a request for a new module does not read as a change.

## What it costs

60 cells for the comparison and 30 for the repeat: 90 in all. Credits are described at https://tessl.io/pricing/.

## Run it yourself

The tasks are in [`tasks/`](tasks/):

- **`repo-*`:** copies of the step 01 tasks, on [`tasks/linkbox/`](tasks/linkbox/).
- **`empty-*`:** the same behaviors asked for as new code, on [`tasks/empty/`](tasks/empty/). Their `setup.sh` is the step 01 one, with one change: the test log skips `src/` while it has no files.

[`arms.json`](arms.json) has the two arms. [`arms-confirm.json`](arms-confirm.json) has the skills arm alone, for the repeat. To try your own codebase, add a copy of it under `tasks/`, write tasks on it that match the empty-project ones, and point their `scenario.json` at it.

```sh
tessl eval lint 04-in-situ/tasks
tessl eval run 04-in-situ/tasks \
  --variant-json 04-in-situ/arms.json \
  --agent claude --model claude-sonnet-4-6 \
  --scorer-agent claude --scorer-model claude-sonnet-4-6 \
  -n 3 -f --yes --label in-situ
```

Then compare each place and arm:

```sh
tessl eval view <run-id> --json | jq -r '.data.attributes.scenarios[] | (.path | split("/") | last) as $s | .solutions[] | [$s, .variant, ([.runs[].score] | map(tostring) | join(" "))] | @tsv' | sort
```

## What's next

Step 05 holds the skill and the tasks fixed and changes the model, the coding agent, and the model that grades.
