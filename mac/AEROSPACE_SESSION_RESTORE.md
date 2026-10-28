# AeroSpace session restore

At AeroSpace startup, a small dialog offers to restore the last saved workspace arrangement. Choose **Restore** to open missing apps, wait for the saved windows to appear, then place them into the saved workspaces and reapply the split widths. Choose **Skip** to leave the current session alone.

The same prompt is available with **Alt-Shift-R**. The implementation is `scripts/aerospace-session-restore.py` (`prompt`, `restore`, `save`).

## Saving

AeroSpace has no quit hook, and windows are already closing by the time a shutdown reaches it. Instead, the LaunchAgent `launchd/dev.domguy.aerospace-snapshot.plist` runs `aerospace-session-restore.py save` every 2 minutes. It records each workspace's tiled windows (app, title, left-to-right order, width share) and root layout to `~/.local/state/aerospace/session-snapshot.json`. This file is local to the machine and not tracked in git.

A save is skipped when nothing changed, when no tiled windows exist, or while the restore prompt is open. There is no save at load, so the previous session's layout survives until the restore prompt has been answered. Saves are logged to `~/Library/Logs/AeroSpace/session-restore.log`.

Install the agent with a symlink into `~/Library/LaunchAgents/` and `launchctl bootstrap gui/$(id -u) <plist>`.

## Matching on restore

Windows are matched by app bundle ID. A window whose exact title matches the saved title is used first; remaining saved windows take any unused window of the same app in saved order. Restore only aborts, with an alert, if an app has fewer windows than were saved. Ratios scale to the current main display width.
