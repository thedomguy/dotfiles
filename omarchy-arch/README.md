# omarchy-arch

Self-contained Linux (Omarchy / Arch, Hyprland) copy of these dotfiles. Nothing here links back to the repo root or to the Mac files; changes for this machine are made only in this directory. Sync with the Mac copy by hand (diff and copy) when needed.

`./install.sh` links everything from this directory and backs up what it replaces to `~/.config-backup-<timestamp>/`.

| Piece | What happens |
| :--- | :--- |
| `fish/`, `lf/`, `nvim/`, `.vimrc`, `.ideavimrc`, `git/ignore` | Copied from the Mac files and symlinked into `~/.config` / `~`. Neovim is linked as `~/.config/nvim-mine` (run `NVIM_APPNAME=nvim-mine nvim`); Omarchy's LazyVim stays the default `nvim`. |
| `fish/conf.d/tide_config.fish` | Tide prompt settings exported from the Mac. |
| `bin/` | `open`, `pbcopy`, `pbpaste` shims (xdg-open, wl-copy, wl-paste) so the mac-flavoured configs work. |
| `hypr/aerospace.lua` | AeroSpace shortcuts as Hyprland bindings (alt-hjkl focus, alt-shift-hjkl move, alt-1..0 workspaces, alt-minus/equal resize, alt-tab back-and-forth, alt-b/g/f/o launchers). Omarchy's SUPER bindings stay. |
| `ghostty/keybinds.conf` | Pane keybinds from the Mac Ghostty config (ctrl+hjkl focus, super+d split), included from Ghostty config via `config-file`. |
| `bin/claude-lid-keepalive`, `systemd/user/claude-lid-keepalive.service`, `hypr/claude-blank.lua` | Keeps the laptop awake with the lid closed while a Claude Code session runs **on AC only** (a logind `handle-lid-switch` block, released on battery; suspends if you unplug with the lid shut). Claude `SessionStart`/`SessionEnd` hooks in `~/.claude/settings.json` (merged by `install.sh`) register sessions, and the service stops itself when none are left. `SUPER+CTRL+D` blacks the screen (DPMS off); any key or mouse movement wakes it, no password. Suspends Omarchy's idle lock/screensaver while active unless stay-awake is already on. `claude-lid-keepalive status` shows state. |
| `gitconfig-extra` | `sync`, `mr`, `local` aliases and `fetch.prune`, included from `~/.gitconfig`. |

Linux changes versus the Mac originals: `fish/config.fish` guards the Homebrew and `entire` lines, `fish/conf.d/rustup.fish` guards `~/.cargo/env.fish`.

Not copied: `.bashrc`/`.profile` (Omarchy owns bash), `.gitconfig-work` (needs the Datamatics key), `zellij`, `ghostty` (Omarchy's theme-aware config is kept, plus `command = /usr/bin/fish`; the login shell stays bash), and the mac-only AeroSpace features (monitor assignment, floating rules, borders, service mode).
