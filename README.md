# My Dotfiles

This repository holds the real content of my dotfiles. `$HOME` and
`~/.config` get symbolic links pointing into this repo — the repo is the
source of truth, not the other way around.

## Setup and Management

The symbolic links are managed by the script in `scripts/manage_symlinks.sh`.

To (re)create the symlinks on a machine, run from the root of this repository:

```bash
./scripts/manage_symlinks.sh
```

The script will prompt you for any conflicts or decisions that need to be made.

### Managed dotfiles (`$HOME`)

| Repo file | Symlink |
| :--- | :--- |
| `.aerospace.toml` | `~/.aerospace.toml` |
| `.bash_profile` | `~/.bash_profile` |
| `.bashrc` | `~/.bashrc` |
| `.gitconfig` | `~/.gitconfig` |
| `.gitconfig-work` | `~/.gitconfig-work` |
| `.gitconfig.backup` | `~/.gitconfig.backup` |
| `.ideavimrc` | `~/.ideavimrc` |
| `.profile` | `~/.profile` |
| `.tmux.conf` | `~/.tmux.conf` |
| `.vimrc` | `~/.vimrc` |
| `.zshrc` | `~/.zshrc` |
| `personal.gitconfig` | `~/personal/.gitconfig` |

### Managed app config (`~/.config`)

| Repo dir | Symlink |
| :--- | :--- |
| `PureRef` | `~/.config/PureRef` |
| `alacritty` | `~/.config/alacritty` |
| `cmux` | `~/.config/cmux` |
| `fish` | `~/.config/fish` |
| `flipper` | `~/.config/flipper` |
| `gh` | `~/.config/gh` |
| `ghostty` | `~/.config/ghostty` |
| `git` | `~/.config/git` |
| `iterm2` | `~/.config/iterm2` |
| `jgit` | `~/.config/jgit` |
| `karabiner` | `~/.config/karabiner` |
| `lf` | `~/.config/lf` |
| `nvim` | `~/.config/nvim` (excl. `nvim/pack/`, see `.gitignore`) |
| `sketchybar` | `~/.config/sketchybar` |
| `sketchybar.bak` | `~/.config/sketchybar.bak` |
| `uv` | `~/.config/uv` |
| `waveterm` | `~/.config/waveterm` |
| `zed` | `~/.config/zed` |
| `zellij` | `~/.config/zellij` |

### Pointers into other repos/secret files (never materialized here)

These stay as symlinks pointing *out* of this repo on purpose — the nvm
ones belong to nvm's own git checkout, and `personal.env` is a real `.env`
file that must never land in this repo's history.

| Repo entry | Points to |
| :--- | :--- |
| `nvm.dockerignore` / `nvm.editorconfig` / `nvm.gitattributes` / `nvm.gitignore` / `nvm.mailmap` / `nvm.travis.yml` | files inside `~/.nvm` |
| `personal.env` | `~/personal/.env` |

### Intentionally NOT managed

The symlinks for these still exist locally (pointing at `~/.config/<name>`)
so `manage_symlinks.sh`'s intent is documented, but their content is
excluded via `.gitignore` and never committed:

| Dir | Why excluded |
| :--- | :--- |
| `glab-cli` | `config.yml` has a plaintext GitLab access token + refresh token |
| `github-copilot` | `oauth.json` / `auth.db` hold live Copilot session credentials |
| `raycast` | `config.json` has a live Raycast API token; ~100MB of extension/AI cache |
| `joplin-desktop` | Personal notes database + `ipc_secret_key.txt` |
| `coc` | coc.nvim extension installs + cache (~35MB), regenerates on demand |
| `configstore` / `simple-update-notifier` | npm/yarn update-notifier timestamps, no dotfile value |

## Cheatsheets

`cheatsheets/` holds topic-based markdown cheatsheets (`fish.md`, `git.md`,
…) for quick recall in the terminal — see `cheat -l` / `cheat <topic>` /
`cheat -e <topic>` (defined in `fish/functions/cheat.fish`). Feel free to
have an AI coding assistant keep these current as workflows change.

- [fish](cheatsheets/fish.md)
- [git](cheatsheets/git.md)
- [_template](cheatsheets/_template.md) — scaffold for a new topic
