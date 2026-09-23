#!/usr/bin/env bash
# Step 00: does every skill load when a request needs it, and stay out of
# the way when it does not? expectations.json says which is which.
#
#   ./run.sh triage
#       The unchanged plugins on every scenario and every model, n=3.
#       Tells you which skills fail the rule and on which models.
#       6 scenarios x 3 models x 3 = 54 cells.
#
#   ./run.sh screen <skill> <model>...
#       Every arm in skills/<skill>/arms.json, on the models that failed
#       triage, n=2, over only the scenarios that judge that skill.
#
#   ./run.sh confirm <skill> <arm>...
#       The named arms plus the control, on every model, n=3, over the
#       scenarios that judge that skill.
#
# Run ./make-variants.py <skill> before screening a skill.
set -euo pipefail
cd "$(dirname "$0")"

ALL_MODELS=(claude-haiku-4-5 claude-sonnet-4-6 claude-opus-4-6)
SCORER=(--scorer-agent claude --scorer-model claude-opus-4-6)

# The scenarios that list <skill> under load or skip, copied with the
# codebase they install, because a run takes one scenarios directory.
scenarios_judging() {
  local skill=$1 out=".run/$1/scenarios"
  rm -rf "$out" && mkdir -p "$out"
  cp -R before/scenarios/repo "$out/"
  jq -r --arg s "$skill" '.scenarios | to_entries[]
      | select((.value.load + .value.skip) | index($s)) | .key' expectations.json |
    while read -r name; do cp -R "before/scenarios/$name" "$out/"; done
  echo "$out"
}

run() {  # run <scenarios> <arms-json> <model> <n> <label>
  tessl eval run "$1" --arms-json "$2" --agent claude --model "$3" \
    "${SCORER[@]}" -n "$4" --yes --label "$5"
}

case "${1:-}" in
  triage)
    for model in "${ALL_MODELS[@]}"; do
      run before/scenarios arms-control.json "$model" 3 "eval-demo-00-triage-${model}"
    done
    ;;
  screen)
    skill=${2:?skill}; shift 2
    [ $# -gt 0 ] || { echo "screen needs at least one model" >&2; exit 2; }
    dir=$(scenarios_judging "$skill")
    for model in "$@"; do
      run "$dir" "skills/$skill/arms.json" "$model" 2 "eval-demo-00-screen-${skill}-${model}"
    done
    ;;
  confirm)
    skill=${2:?skill}; shift 2
    [ $# -gt 0 ] || { echo "confirm needs at least one arm label" >&2; exit 2; }
    dir=$(scenarios_judging "$skill")
    keep=$(printf '%s\n' v00-control "$@" | jq -R . | jq -s .)
    arms=$(jq -c --argjson keep "$keep" 'map(select(.label as $l | $keep | index($l)))' "skills/$skill/arms.json")
    for model in "${ALL_MODELS[@]}"; do
      run "$dir" "$arms" "$model" 3 "eval-demo-00-confirm-${skill}-${model}"
    done
    ;;
  *)
    echo "usage: $0 triage | screen <skill> <model>... | confirm <skill> <arm>..." >&2
    exit 2
    ;;
esac
