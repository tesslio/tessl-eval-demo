#!/usr/bin/env bash
# Publish the four SDLC plugins from source to a Tessl workspace, then wait
# for the registry's publication checks to pass.
#
# You only need this if you want to CHANGE the skills. To just run the evals
# against the published ones, skip straight to ./run.sh — the plugins
# arms.json references are public.
#
# Publish into your own workspace:
#
#   WORKSPACE=my-workspace ./publish.sh
#
# then point both arms files at it:
#
#   sed -i '' 's|tessleng/sdlc-|my-workspace/sdlc-|g' arms.json arms-models.json
#
# Two things the registry will stop you on:
#
#   1. The version must not already exist. Bump it in the plugin's
#      .tessl-plugin/plugin.json first, and update both arms files to match.
#   2. Every skill must score at least 80 in the registry's quality review.
#      The gate is the MINIMUM across the plugin's skills. Check one skill
#      before publishing with:
#        tessl review run quality plugins/<plugin>/skills/<skill> --json -f
#      (-f forces a fresh review; results are cached. Scores vary a few
#      points between reviews of the same file, so leave margin rather than
#      landing on exactly 80.)
set -euo pipefail

WORKSPACE="${WORKSPACE:-tessleng}"
PLUGINS=(sdlc-planning sdlc-implementation sdlc-assurance sdlc-router)

for plugin in "${PLUGINS[@]}"; do
  echo "== publishing $plugin to $WORKSPACE =="
  tessl plugin lint "plugins/$plugin"
  tessl plugin publish "plugins/$plugin" --workspace "$WORKSPACE"
done

echo
echo "== waiting for publication checks =="
for plugin in "${PLUGINS[@]}"; do
  version=$(jq -r .version "plugins/$plugin/.tessl-plugin/plugin.json")
  ref="$WORKSPACE/$plugin@$version"
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
