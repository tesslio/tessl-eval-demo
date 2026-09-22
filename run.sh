#!/usr/bin/env bash
# Two eval runs, each answering one question.
#
#   1. Do the skills help?   arms.json        components vs no-components
#   2. Which model?          arms-models.json opus vs sonnet vs haiku
#
# Both run every scenario in scenarios/ against the toy codebase in
# scenarios/repo/, three times per cell.
set -euo pipefail

MODEL="${MODEL:-claude-sonnet-4-6}"
RUNS="${RUNS:-3}"

echo "== do the skills help? (${MODEL}, n=${RUNS}) =="
tessl eval run scenarios \
  --arms-json arms.json \
  --agent claude --model "$MODEL" \
  --scorer-agent claude --scorer-model claude-opus-4-6 \
  -n "$RUNS" \
  --label "eval-demo-skills-vs-none-${MODEL}"

echo "== which model? (all arms with skills, n=${RUNS}) =="
tessl eval run scenarios \
  --arms-json arms-models.json \
  --agent claude --model "$MODEL" \
  --scorer-agent claude --scorer-model claude-opus-4-6 \
  -n "$RUNS" \
  --label "eval-demo-model-comparison"
