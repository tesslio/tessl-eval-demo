#!/usr/bin/env bash
# Step 00: does the agent do better when it works in a real codebase than
# when the ticket carries the code inline?
#
# One run per side, both with the arms in arms.json (skills vs no skills),
# so the result also shows whether the skill lift depends on the codebase.
#
#   RUNS=n   repetitions per cell (default 3). Each side is
#            3 scenarios x 2 arms x RUNS cells.
set -euo pipefail
cd "$(dirname "$0")"

MODEL="${MODEL:-claude-sonnet-4-6}"
RUNS="${RUNS:-3}"

for side in before after; do
  echo "== ${side}: $((3 * 2 * RUNS)) cells =="
  tessl eval run "${side}/scenarios" \
    --arms-json arms.json \
    --agent claude --model "$MODEL" \
    --scorer-agent claude --scorer-model claude-opus-4-6 \
    -n "$RUNS" \
    --label "eval-demo-00-${side}-${MODEL}"
done
