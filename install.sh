#!/bin/bash
# @ai-generated(solo)
set -euo pipefail

label=io.github.dankinsoid.sim-daemon-blocker
bin=$HOME/.local/bin/sim-daemon-blocker
plist=$HOME/Library/LaunchAgents/$label.plist
logfile=$HOME/Library/Logs/sim-daemon-blocker.log

[ $# -gt 0 ] || set -- mediaanalysisd

args=""
for daemon in "$@"; do
	# Names go into the plist unescaped.
	if ! [[ $daemon =~ ^[A-Za-z0-9._-]+$ ]]; then
		echo "invalid daemon name: $daemon" >&2
		exit 64
	fi
	args+="		<string>$daemon</string>
"
done

mkdir -p "${bin%/*}" "${plist%/*}" "${logfile%/*}"
install -m 755 "$(cd "$(dirname "$0")" && pwd)/sim-daemon-blocker" "$bin"

cat >"$plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>$label</string>
	<key>ProgramArguments</key>
	<array>
		<string>$bin</string>
$args	</array>
	<key>RunAtLoad</key>
	<true/>
	<key>StartInterval</key>
	<integer>60</integer>
	<key>ProcessType</key>
	<string>Background</string>
	<key>StandardOutPath</key>
	<string>$logfile</string>
	<key>StandardErrorPath</key>
	<string>$logfile</string>
</dict>
</plist>
EOF

domain=gui/$(id -u)
launchctl bootout "$domain/$label" 2>/dev/null || true
launchctl bootstrap "$domain" "$plist"

echo "installed: blocking $* in simulators every 60s"
echo "log: $logfile"
