#!/bin/bash
# Linux (Omarchy/Arch) setup. Self-contained: everything is linked from this directory, not the repo root.
# Existing configs are moved to ~/.config-backup-<timestamp>/ before being replaced.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="$HOME/.config"
BACKUP="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"

link() { # link <source> <dest>
  local src="$1" dest="$2"
  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then return; fi
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    mkdir -p "$BACKUP"
    mv "$dest" "$BACKUP/$(basename "$dest")"
    echo "backed up $dest -> $BACKUP/"
  fi
  mkdir -p "$(dirname "$dest")"
  ln -s "$src" "$dest"
  echo "linked $dest -> $src"
}

# Packages (needs sudo; skipped if already installed)
missing=()
for p in fish lf ripgrep fzf neovim; do pacman -Q "$p" >/dev/null 2>&1 || missing+=("$p"); done
if [ ${#missing[@]} -gt 0 ]; then
  echo "Installing: ${missing[*]}"
  sudo pacman -S --needed --noconfirm "${missing[@]}"
fi

# Shell, editor, file manager
link "$HERE/fish" "$CONFIG/fish"
link "$HERE/lf" "$CONFIG/lf"
# LazyVim (Omarchy default) stays as `nvim`; this config runs as `NVIM_APPNAME=nvim-mine nvim`
link "$HERE/nvim" "$CONFIG/nvim-mine"
link "$HERE/.vimrc" "$HOME/.vimrc"
link "$HERE/.ideavimrc" "$HOME/.ideavimrc"
link "$HERE/git/ignore" "$CONFIG/git/ignore"

# macOS command shims (open, pbcopy, pbpaste)
for f in "$HERE"/bin/*; do link "$f" "$HOME/.local/bin/$(basename "$f")"; done

# Ghostty: pane keybinds, included from Omarchy's config
link "$HERE/ghostty/keybinds.conf" "$CONFIG/ghostty/keybinds.conf"
grep -qxF 'config-file = keybinds.conf' "$CONFIG/ghostty/config" \
  || printf '\n# Pane keybinds from dotfiles\nconfig-file = keybinds.conf\n' >> "$CONFIG/ghostty/config"

# Hyprland: ported AeroSpace shortcuts
link "$HERE/hypr/aerospace.lua" "$CONFIG/hypr/aerospace.lua"
if ! grep -q 'hypr.aerospace' "$CONFIG/hypr/bindings.lua"; then
  printf '\n-- AeroSpace shortcuts ported from macOS\nrequire("hypr.aerospace")\n' >> "$CONFIG/hypr/bindings.lua"
  echo "added require to hypr/bindings.lua"
fi

# Claude Code: block lid-close suspend on AC while a session runs (service + SessionStart/End hooks),
# and a SUPER+CTRL+D black-screen hotkey. The script itself is linked by the bin/ loop above.
link "$HERE/systemd/user/claude-lid-keepalive.service" "$HOME/.config/systemd/user/claude-lid-keepalive.service"
systemctl --user daemon-reload 2>/dev/null || true
link "$HERE/hypr/claude-blank.lua" "$CONFIG/hypr/claude-blank.lua"
if ! grep -q 'hypr.claude-blank' "$CONFIG/hypr/bindings.lua"; then
  printf '\n-- Black screen for overnight Claude sessions\nrequire("hypr.claude-blank")\n' >> "$CONFIG/hypr/bindings.lua"
  echo "added claude-blank require to hypr/bindings.lua"
fi
SETTINGS="$HOME/.claude/settings.json"
mkdir -p "$(dirname "$SETTINGS")"
[ -f "$SETTINGS" ] || echo '{}' > "$SETTINGS"
jq '
  def ensure(ev; cmd):
    .hooks[ev] = ((.hooks[ev] // []) | if any(.[]?.hooks[]?; .command == cmd) then . else . + [{hooks: [{type: "command", command: cmd}]}] end);
  ensure("SessionStart"; "$HOME/.local/bin/claude-lid-keepalive hook-start")
  | ensure("SessionEnd"; "$HOME/.local/bin/claude-lid-keepalive hook-end")
' "$SETTINGS" > "$SETTINGS.tmp" && mv "$SETTINGS.tmp" "$SETTINGS"

# Git: extra aliases on top of the Omarchy config
git config --global --get-all include.path | grep -qxF "$HERE/gitconfig-extra" \
  || git config --global --add include.path "$HERE/gitconfig-extra"

# Neovim plugins (pack/ is gitignored, so fetch them here)
START="$HERE/nvim/pack/plugins/start"
mkdir -p "$START"
plug() { # plug <name> <url> [rev]
  [ -d "$START/$1" ] || git clone --quiet "$2" "$START/$1"
  [ -z "${3:-}" ] || git -C "$START/$1" checkout --quiet "$3"
}
plug nvim-lspconfig       https://github.com/neovim/nvim-lspconfig e146efacbafed3789ac568abcc5a981c5decaa58
plug nvim-treesitter      https://github.com/nvim-treesitter/nvim-treesitter cf12346a3414fa1b06af75c79faebe7f76df080a
plug nvim-dap             https://github.com/mfussenegger/nvim-dap 9e848e09a697ee95302a3ef2dd43fd6eb709e570
plug render-markdown.nvim https://github.com/MeanderingProgrammer/render-markdown.nvim f422cb5c6855f150e2ddcfaf44e7157b98b34f6a
plug nvim-cmp             https://github.com/hrsh7th/nvim-cmp
plug cmp-nvim-lsp         https://github.com/hrsh7th/cmp-nvim-lsp
plug cmp-buffer           https://github.com/hrsh7th/cmp-buffer
plug cmp-path             https://github.com/hrsh7th/cmp-path
plug fzf                  https://github.com/junegunn/fzf
plug fzf.vim              https://github.com/junegunn/fzf.vim

# Fish plugins are vendored in fish/ (functions, conf.d), so fisher is not run.

echo "Done. Reload Hyprland (SUPER+SHIFT+R or 'hyprctl reload') to pick up the shortcuts."
