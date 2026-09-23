#!/usr/bin/env bash
# Step 01: which name, description or router rule makes the model load
# finishing-a-development-branch when a request needs it?
#
#   ./run.sh screen              every arm in arms.json, on Haiku, n=2
#   ./run.sh confirm v03 v07 ... the named arms plus v00-control, on Opus
#                                and Sonnet, n=3
#
# Screening is cheap and wide; confirmation is expensive and narrow. A
# variant earns confirmation by beating the control on activation in the
# screen, because activation is what this step is trying to move.
#
# Cells: screen is 11 arms x 3 scenarios x 2 = 66. Confirm is
# (arms + 1) x 3 scenarios x 3 per model.
#
# Run ./make-variants.py first if you edited variants.json.
set -euo pipefail
cd "$(dirname "$0")"

SCORER=(--scorer-agent claude --scorer-model claude-opus-4-6)

case "${1:-}" in
  screen)
    tessl eval run before/scenarios \
      --arms-json arms.json \
      --agent claude --model claude-haiku-4-5 \
      "${SCORER[@]}" -n 2 --yes \
      --label "eval-demo-01-screen-haiku"
    ;;
  confirm)
    shift
    [ $# -gt 0 ] || { echo "confirm needs at least one arm label" >&2; exit 2; }
    keep=$(printf '%s\n' v00-control "$@" | jq -R . | jq -s .)
    arms=$(jq -c --argjson keep "$keep" 'map(select(.label as $l | $keep | index($l)))' arms.json)
    for model in claude-opus-4-6 claude-sonnet-4-6; do
      tessl eval run before/scenarios \
        --arms-json "$arms" \
        --agent claude --model "$model" \
        "${SCORER[@]}" -n 3 --yes \
        --label "eval-demo-01-confirm-${model}"
    done
    ;;
  *)
    echo "usage: $0 screen | confirm <arm-label>..." >&2
    exit 2
    ;;
esac
