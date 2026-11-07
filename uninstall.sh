#!/bin/bash
# @ai-generated(solo)
set -euo pipefail

label=io.github.dankinsoid.sim-daemon-blocker

launchctl bootout "gui/$(id -u)/$label" 2>/dev/null || true
rm -f "$HOME/Library/LaunchAgents/$label.plist" "$HOME/.local/bin/sim-daemon-blocker"

echo "uninstalled; daemons already disabled inside simulators stay disabled (see README)"
