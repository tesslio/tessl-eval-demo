#!/usr/bin/env bash
# Publish the four SDLC plugins from source to the tessleng workspace.
#
# The plugins in plugins/ are the ones arms.json evaluates. Editing a skill
# here, bumping its version, republishing, and re-running the evals is the
# improvement loop this demo exists to show.
#
# Bump the version in the plugin's .tessl-plugin/plugin.json before
# republishing — the registry rejects a re-publish of an existing version.
set -euo pipefail

for plugin in sdlc-planning sdlc-implementation sdlc-assurance sdlc-router; do
  echo "== $plugin =="
  tessl plugin lint "plugins/$plugin"
  tessl plugin publish "plugins/$plugin"
done
