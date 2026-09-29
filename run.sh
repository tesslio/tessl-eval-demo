#!/usr/bin/env bash
# Two eval runs, each answering one question.
#
#   ./run.sh          both
#   ./run.sh skills   only "do the skills help?"  arms.json
#   ./run.sh models   only "which model?"         arms-models.json
#
# Both run every scenario in scenarios/ against the toy codebase in
# scenarios/repo/.
#
#   RUNS=n   repetitions per cell (default 3)
#   MODEL=…  the model for the skills-vs-none sweep only. The model
#            comparison sets its model per arm in arms-models.json and
#            always runs all three, so MODEL does not apply to it.
#
# Cell counts, to size the spend before you start: the skills sweep is
# 3 scenarios x 2 arms x RUNS, the model sweep is 3 scenarios x 3 arms x
# RUNS. The cheapest useful thing to run first is:
#
#   RUNS=1 ./run.sh skills
set -euo pipefail

MODEL="${MODEL:-claude-sonnet-4-6}"
RUNS="${RUNS:-3}"
WHICH="${1:-both}"

run_skills() {
  echo "== do the skills help? (${MODEL}, n=${RUNS}, $((3 * 2 * RUNS)) cells) =="
  tessl eval run scenarios \
    --arms-json arms.json \
    --agent claude --model "$MODEL" \
    --scorer-agent claude --scorer-model claude-opus-4-6 \
    -n "$RUNS" \
    --label "eval-demo-skills-vs-none-${MODEL}"
}

run_models() {
  # No --model here: each arm in arms-models.json names its own.
  echo "== which model? (all arms with skills, n=${RUNS}, $((3 * 3 * RUNS)) cells) =="
  tessl eval run scenarios \
    --arms-json arms-models.json \
    --agent claude \
    --scorer-agent claude --scorer-model claude-opus-4-6 \
    -n "$RUNS" \
    --label "eval-demo-model-comparison"
}

case "$WHICH" in
  both)   run_skills; run_models ;;
  skills) run_skills ;;
  models) run_models ;;
  *) echo "usage: $0 [both|skills|models]" >&2; exit 2 ;;
esac
