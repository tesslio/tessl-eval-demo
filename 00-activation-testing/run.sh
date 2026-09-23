#!/usr/bin/env bash
# Step 00: does every skill load when a request needs it, and stay out of
# the way when it does not? expectations.json says which is which.
#
# Everything runs on Sonnet. This step makes the skills work on one model;
# step 02 then tries other models on the skills this step produced.
#
#   ./run.sh triage
#       The unchanged plugins on every scenario, n=3. Tells you which
#       skills fail the rule. 6 scenarios x 3 = 18 cells.
#
#   ./run.sh baseline <dir>
#       The unchanged plugins on <dir>/scenarios, n=3. The starting point
#       a skill's variants are compared with.
#
#   ./run.sh screen <dir>
#       Every arm in <dir>/arms.json, n=2. For skills/<skill>, only the
#       scenarios that judge that skill; for a bundle-level experiment such
#       as entry-point, every scenario.
#
#   ./run.sh confirm <dir> <arm>...
#       The named arms plus the control (the first arm), n=3, over the
#       same scenarios.
#
# Run ./make-variants.py <dir> before screening.
set -euo pipefail
CALLER_DIR=$PWD
cd "$(dirname "$0")"
STEP_DIR=$PWD

# An experiment directory may be given relative to wherever run.sh was
# called from, or relative to this step. Resolve it to a path relative to
# this step, and stop if it does not exist, so a mistyped path can never
# fall back to running some other set of scenarios.
experiment_dir() {
  local given=${1%/} resolved
  if [ -d "$CALLER_DIR/$given" ]; then resolved=$(cd "$CALLER_DIR/$given" && pwd)
  elif [ -d "$STEP_DIR/$given" ]; then resolved=$(cd "$STEP_DIR/$given" && pwd)
  else echo "No experiment directory $given" >&2; exit 2
  fi
  case "$resolved" in
    "$STEP_DIR"/*) echo "${resolved#"$STEP_DIR"/}" ;;
    *) echo "$given is not inside $STEP_DIR" >&2; exit 2 ;;
  esac
}

MODEL=claude-sonnet-4-6
SCORER=(--scorer-agent claude --scorer-model claude-opus-4-6)

# The scenarios an experiment is judged on. For one skill, those that list
# it under load or skip, copied with the codebase they install, because a
# run takes one scenarios directory.
scenarios_for() {
  if [ -d "$1/scenarios" ]; then echo "$1/scenarios"; return; fi
  case "$1" in skills/*) scenarios_judging "${1#skills/}" ;; *) echo before/scenarios ;; esac
}

scenarios_judging() {
  local skill=$1 out=".run/$1/scenarios"
  rm -rf "$out" && mkdir -p "$out"
  cp -R before/scenarios/repo "$out/"
  jq -r --arg s "$skill" '.scenarios | to_entries[]
      | select((.value.load + .value.skip) | index($s)) | .key' expectations.json |
    while read -r name; do cp -R "before/scenarios/$name" "$out/"; done
  echo "$out"
}

run() {  # run <scenarios> <arms-json> <n> <label>
  tessl eval run "$1" --arms-json "$2" --agent claude --model "$MODEL" \
    "${SCORER[@]}" -n "$3" --yes --label "$4"
}

case "${1:-}" in
  triage)
    run before/scenarios arms-control.json 3 "eval-demo-00-triage"
    ;;
  baseline)
    # The unchanged plugins on one skill's own scenarios, n=3.
    dir=$(experiment_dir "${2:?experiment directory}")
    run "$(scenarios_for "$dir")" arms-control.json 3 "eval-demo-00-baseline-$(basename "$dir")"
    ;;
  screen)
    dir=$(experiment_dir "${2:?experiment directory}")
    run "$(scenarios_for "$dir")" "$dir/arms.json" 2 "eval-demo-00-screen-$(basename "$dir")"
    ;;
  confirm)
    dir=$(experiment_dir "${2:?experiment directory}"); shift 2
    [ $# -gt 0 ] || { echo "confirm needs at least one arm label" >&2; exit 2; }
    control=$(jq -r '.[0].label' "$dir/arms.json")
    keep=$(printf '%s\n' "$control" "$@" | jq -R . | jq -s .)
    arms=$(jq -c --argjson keep "$keep" 'map(select(.label as $l | $keep | index($l)))' "$dir/arms.json")
    run "$(scenarios_for "$dir")" "$arms" 3 "eval-demo-00-confirm-$(basename "$dir")"
    ;;
  *)
    echo "usage: $0 triage | baseline <dir> | screen <dir> | confirm <dir> <arm>..." >&2
    exit 2
    ;;
esac
