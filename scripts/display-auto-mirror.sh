#!/bin/bash
# Mirror the MacBook onto the main ultrawide and dim the built-in panel to 0.
# Run by display-watcher at login, on wake, and on display connect/disconnect.
# `display mirror` does nothing when the ultrawide isn't connected and skips
# the layout switch when it's already mirrored.

echo "[$(date '+%F %T')] ${1:-manual}"
/opt/homebrew/bin/fish -c 'display mirror'
