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
#   ./run.sh screen <skill>
#       Every arm in skills/<skill>/arms.json, n=2, over only the
#       scenarios that judge that skill.
#
#   ./run.sh confirm <skill> <arm>...
#       The named arms plus the control, n=3, over the scenarios that
#       judge that skill.
#
# Run ./make-variants.py <skill> before screening a skill.
set -euo pipefail
cd "$(dirname "$0")"

MODEL=claude-sonnet-4-6
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

run() {  # run <scenarios> <arms-json> <n> <label>
  tessl eval run "$1" --arms-json "$2" --agent claude --model "$MODEL" \
    "${SCORER[@]}" -n "$3" --yes --label "$4"
}

case "${1:-}" in
  triage)
    run before/scenarios arms-control.json 3 "eval-demo-00-triage"
    ;;
  screen)
    skill=${2:?skill}
    run "$(scenarios_judging "$skill")" "skills/$skill/arms.json" 2 "eval-demo-00-screen-${skill}"
    ;;
  confirm)
    skill=${2:?skill}; shift 2
    [ $# -gt 0 ] || { echo "confirm needs at least one arm label" >&2; exit 2; }
    keep=$(printf '%s\n' v00-control "$@" | jq -R . | jq -s .)
    arms=$(jq -c --argjson keep "$keep" 'map(select(.label as $l | $keep | index($l)))' "skills/$skill/arms.json")
    run "$(scenarios_judging "$skill")" "$arms" 3 "eval-demo-00-confirm-${skill}"
    ;;
  *)
    echo "usage: $0 triage | screen <skill> | confirm <skill> <arm>..." >&2
    exit 2
    ;;
esac
