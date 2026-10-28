#!/usr/bin/env bash
# Collapse any AeroSpace workspace numbered above 9 back into 1..9.
#
# Logic: a stray workspace N (> 9) maps to ((N-1) % 9) + 1
#   e.g. 10 -> 1,  11 -> 2,  18 -> 9,  19 -> 1
#
# Every window on the stray workspace is moved *quietly* (focus is not
# pulled along, no --focus-follows-window) to the mapped workspace. Once a
# stray workspace is emptied it disappears on its own, since only "1".."9"
# are persistent. Bound to a shortcut in .aerospace.toml and run on every
# workspace change (exec-on-workspace-change) as a safety net.

set -euo pipefail

aerospace list-workspaces --all | while read -r ws; do
  # Only act on purely-numeric workspaces above 9.
  [[ "$ws" =~ ^[0-9]+$ ]] || continue
  (( ws > 9 )) || continue

  target=$(( (ws - 1) % 9 + 1 ))

  # Move each window on the stray workspace, quietly, to the target.
  aerospace list-windows --workspace "$ws" --format '%{window-id}' | while read -r wid; do
    [[ -n "$wid" ]] || continue
    aerospace move-node-to-workspace --window-id "$wid" "$target"
  done
done
