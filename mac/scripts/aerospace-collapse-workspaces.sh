#!/usr/bin/env bash
# Collapse any AeroSpace workspace numbered above 10 back into 1..10.
#
# Logic: a stray workspace N (> 10) maps to ((N-1) % 10) + 1
#   e.g. 12 -> 2   (12 - 10 = 2)
#        11 -> 1,  20 -> 10,  21 -> 1
#
# Every window on the stray workspace is moved *quietly* (focus is not
# pulled along, no --focus-follows-window) to the mapped workspace. Once a
# stray workspace is emptied it disappears on its own, since only "1".."10"
# are persistent. Bound to a shortcut in .aerospace.toml.

set -euo pipefail

aerospace list-workspaces --all | while read -r ws; do
  # Only act on purely-numeric workspaces above 10.
  [[ "$ws" =~ ^[0-9]+$ ]] || continue
  (( ws > 10 )) || continue

  target=$(( (ws - 1) % 10 + 1 ))

  # Move each window on the stray workspace, quietly, to the target.
  aerospace list-windows --workspace "$ws" --format '%{window-id}' | while read -r wid; do
    [[ -n "$wid" ]] || continue
    aerospace move-node-to-workspace --window-id "$wid" "$target"
  done
done
