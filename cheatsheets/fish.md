# fish shell

Shortcuts and functions defined in `~/.config/fish`. Abbreviations expand to
the full command in the prompt buffer before you hit enter, so they show up
in full in `history` — aliases/functions only show the short name.

## Abbreviations (conf.d/abbrs.fish, conf.d/git_worktree.fish)

- `..` / `...` — `cd ..` / `cd ../..`
- `c` — `clear`
- `h` — `history`
- `src` — reload `config.fish`
- `ga` `gcm` `gst` `gl` `gpl` `gps` `gb` `gco` `gcb` `gcl` — git add/commit/status/log/pull/push/branch/checkout/checkout-b/clone
- `gwl` `gwa` `gwab` `gwr` `gwrf` `gwp` `gwmv` `gwlock` `gwunlock` — git worktree list/add/add-branch/remove/remove-force/prune/move/lock/unlock
- `nr` `ni` `nis` `nig` `nrd` `nrb` — npm run/install/install-save/install-global/run-dev/run-build
- `ys` `ya` `yad` — yarn start/add/add-dev
- `dps` `di` `dstop` `drm` `drmi` `dbuild` `dup` `ddown` — docker ps/images/stop-all/rm-all/rmi-all/build/compose-up/compose-down
- `serve` `ngrok` `preview` — npx serve / ngrok http 3000 / open localhost:3000
- `run` `migrate` `seed` `pyserv` — npm run start / django migrate / node seed.js / python http.server
- `reload` `ip` `ang` — exec fish / curl ifconfig.me / open Antigravity IDE
- `sisfront` `sisback` — z-jump into the SIS frontend/backend project dirs
- `warp_logs` `warp_data` `warp_db` — cd/inspect Warp's logs, app support dir, sqlite db
- `interval` — run `interval_executor.sh`

## Aliases/functions (kept as real functions, not abbr)

These are called *inside* other functions, and abbreviations don't expand
inside function bodies — so they have to stay real fish functions:

- `vi` / `vim` → `nvim` (used by `zhis`)
- `ll` → `ls -lAh` (used by `llgrep`, `lls`)
- `code` → open VS Code (used by `proj`)
- `python` / `pip` → `python3` / `pip3` (tide's prompt segment calls `python --version`)
- `lf` → `lfcd` (cd-on-exit wrapper around `lf`)

## Handy functions

- `llgrep <pattern>` — `ll` piped through grep
- `mkcd <dir>` — mkdir -p and cd into it
- `zz <dir>` — zip a folder from its parent dir
- `proj <name>` — cd into `~/projects/<name>` and open VS Code
- `gwcd [worktree]` — cd into another git worktree (fzf picker if no arg), preserving relative path
- `gwnew <path> [branch]` / `gwdel <path>` — add/remove a git worktree
- `use-docker-desktop` — switch Docker context from Colima to Docker Desktop
- `toggle_browser` — flip default browser between Arc and Brave
- `warp_conversations` / `warp_search <term>` — query Warp's local sqlite history
- `cheat <topic>` — this cheatsheet system, see `cheat -e cheat`

## Gotchas

- New `abbr` doesn't take effect in the current shell until you `src` or open a new tab.
- `abbr --list` shows what's registered; `type <name>` won't find abbreviations (that's normal, use `abbr --show`).
- Don't convert something to `abbr` if another function calls it by name — check with `grep -rn '\bname\b' ~/.config/fish/functions ~/.config/fish/conf.d` first.
