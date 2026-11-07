# sim-daemon-blocker

Keeps chosen background daemons from running inside Xcode simulators.

The motivating case is `mediaanalysisd`. A simulator can stay booted for hours, often the hidden one Xcode keeps for SwiftUI Previews, and inside it `mediaanalysisd` can use several CPU cores. It gets killed with `SIGKILL`, launchd restarts it right away, and the loop continues. Previews simulators don't show up in `xcrun simctl list` or in Simulator.app, so it's hard to tell where the load comes from.

Simulator runtimes are sealed, read-only disk images, so you can't edit the daemon's launchd plist once for every simulator. Instead, a LaunchAgent checks once a minute for the listed daemons running in any simulator. When it finds one, it disables that daemon in that simulator's own launchd and stops it. The setting is per device and persists across simulator reboots, so each device is handled once. Devices that are new or erased get covered the first time the daemon shows up.

## Install

```sh
git clone https://github.com/dankinsoid/sim-daemon-blocker.git
cd sim-daemon-blocker
./install.sh                      # blocks mediaanalysisd
./install.sh mediaanalysisd photoanalysisd   # or any list of daemon binary names
```

Running `install.sh` again replaces the list.

What gets installed:

- `~/.local/bin/sim-daemon-blocker`
- `~/Library/LaunchAgents/io.github.dankinsoid.sim-daemon-blocker.plist`
- log: `~/Library/Logs/sim-daemon-blocker.log` (one line per blocked daemon)

The script can also be run by hand: `sim-daemon-blocker mediaanalysisd`.

## Uninstall

```sh
./uninstall.sh
```

Daemons that were already disabled stay disabled inside those simulators. To turn one back on:

```sh
# Regular simulators: ~/Library/Developer/CoreSimulator/Devices
# SwiftUI Previews:   ~/Library/Developer/Xcode/UserData/Previews/Simulator Devices
xcrun simctl --set "<device set>" spawn <UDID> launchctl enable user/foreground/com.apple.mediaanalysisd
xcrun simctl --set "<device set>" spawn <UDID> launchctl enable system/com.apple.mediaanalysisd
```

You can also just erase the device: `xcrun simctl --set "<device set>" erase <UDID>`.

## License

MIT
