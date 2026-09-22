#!/usr/bin/env bash
# Publish the four SDLC plugins from source to the tessleng workspace, then
# wait for the registry's publication checks to pass.
#
# Editing a skill here, bumping its version, republishing, and re-running the
# evals is the improvement loop this demo exists to show.
#
# Two things the registry will stop you on:
#
#   1. The version must not already exist. Bump it in the plugin's
#      .tessl-plugin/plugin.json first, and update both arms files to match.
#   2. Every skill must score at least 80 in the registry's quality review.
#      The gate is the MINIMUM across the plugin's skills. Check a single
#      skill before publishing with:
#        tessl review run quality plugins/<plugin>/skills/<skill> --json -f
#      (-f forces a fresh review; results are cached. The score is not
#      deterministic, so leave margin rather than landing on exactly 80.)
set -euo pipefail

PLUGINS=(sdlc-planning sdlc-implementation sdlc-assurance sdlc-router)

for plugin in "${PLUGINS[@]}"; do
  echo "== publishing $plugin =="
  tessl plugin lint "plugins/$plugin"
  tessl plugin publish "plugins/$plugin"
done

echo
echo "== waiting for publication checks =="
for plugin in "${PLUGINS[@]}"; do
  version=$(jq -r .version "plugins/$plugin/.tessl-plugin/plugin.json")
  ref="tessleng/$plugin@$version"
  while :; do
    status=$(tessl plugin info "$ref" --json 2>/dev/null \
      | jq -r '.version.moderationStatus // "pending"')
    case "$status" in
      pass) printf '%-24s pass\n' "$plugin"; break ;;
      fail)
        printf '%-24s FAIL\n' "$plugin"
        tessl plugin info "$ref" --json | jq -r '.version.moderationError'
        exit 1
        ;;
      *) sleep 15 ;;
    esac
  done
done

echo
echo "All published. Run ./run.sh to evaluate them."
