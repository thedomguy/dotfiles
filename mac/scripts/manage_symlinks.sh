#!/bin/bash

# Creates symlinks in ~ pointing to files in this dotfiles repo.
# Source of truth lives in the repo; home directory gets symlinks.

DOTFILES_DIR="/Users/rahul.bhatt/personal/dotfiles"

symlink_file() {
  local source_file="$1"  # file in dotfiles repo
  local dest_file="$2"    # symlink location in home

  mkdir -p "$(dirname "$dest_file")"

  if [ -e "$dest_file" ] || [ -L "$dest_file" ]; then
    read -p "$(basename "$dest_file") already exists at $dest_file. Overwrite? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      ln -sf "$source_file" "$dest_file"
      echo "Overwrote symlink: $dest_file -> $source_file"
    else
      echo "Skipped: $dest_file"
    fi
  else
    ln -s "$source_file" "$dest_file"
    echo "Created symlink: $dest_file -> $source_file"
  fi
}

# Pairs: dotfiles repo file -> home destination
symlink_file "$DOTFILES_DIR/.aerospace.toml"    "/Users/rahul.bhatt/.aerospace.toml"
symlink_file "$DOTFILES_DIR/.bash_profile"      "/Users/rahul.bhatt/.bash_profile"
symlink_file "$DOTFILES_DIR/.bashrc"            "/Users/rahul.bhatt/.bashrc"
symlink_file "$DOTFILES_DIR/.cmux.conf"         "/Users/rahul.bhatt/.cmux.conf"
symlink_file "$DOTFILES_DIR/.gitconfig"         "/Users/rahul.bhatt/.gitconfig"
symlink_file "$DOTFILES_DIR/.gitconfig-iom-prima" "/Users/rahul.bhatt/.gitconfig-iom-prima"
symlink_file "$DOTFILES_DIR/.gitconfig-work"    "/Users/rahul.bhatt/.gitconfig-work"
symlink_file "$DOTFILES_DIR/.gitconfig.backup"  "/Users/rahul.bhatt/.gitconfig.backup"
symlink_file "$DOTFILES_DIR/.ideavimrc"         "/Users/rahul.bhatt/.ideavimrc"
symlink_file "$DOTFILES_DIR/.profile"           "/Users/rahul.bhatt/.profile"
symlink_file "$DOTFILES_DIR/.tmux.conf"         "/Users/rahul.bhatt/.tmux.conf"
symlink_file "$DOTFILES_DIR/.tool-versions"     "/Users/rahul.bhatt/.tool-versions"
symlink_file "$DOTFILES_DIR/.vimrc"             "/Users/rahul.bhatt/.vimrc"
symlink_file "$DOTFILES_DIR/.zprofile"          "/Users/rahul.bhatt/.zprofile"
symlink_file "$DOTFILES_DIR/.zshenv"            "/Users/rahul.bhatt/.zshenv"
symlink_file "$DOTFILES_DIR/.zshrc"             "/Users/rahul.bhatt/.zshrc"
symlink_file "$DOTFILES_DIR/personal.gitconfig" "/Users/rahul.bhatt/personal/.gitconfig"

# Single files inside app dirs that also hold state/credentials we don't track
symlink_file "$DOTFILES_DIR/hammerspoon/init.lua" "/Users/rahul.bhatt/.hammerspoon/init.lua"
symlink_file "$DOTFILES_DIR/gemini/GEMINI.md"     "/Users/rahul.bhatt/.gemini/GEMINI.md"

# Pairs: dotfiles repo dir -> ~/.config destination
CONFIG_DIR="/Users/rahul.bhatt/.config"
for name in PureRef alacritty cmux fish flipper gh ghostty git iterm2 jarvis-voice \
            jgit karabiner lf nvim sketchybar sketchybar.bak uv waveterm zed zellij; do
  symlink_file "$DOTFILES_DIR/$name" "$CONFIG_DIR/$name"
done

# LaunchAgents: dotfiles repo plist -> ~/Library/LaunchAgents
# (load once with: launchctl bootstrap gui/$(id -u) <dest>)
symlink_file "$DOTFILES_DIR/launchd/dev.domguy.display-auto-mirror.plist" "/Users/rahul.bhatt/Library/LaunchAgents/dev.domguy.display-auto-mirror.plist"

# Not managed here (see .gitignore / README for why): coc, configstore,
# github-copilot, glab-cli, joplin-desktop, raycast, simple-update-notifier
# — either hold secrets or are pure regenerable cache. Also ~/.ssh/config,
# ~/.aws/config and ~/.codex/config.toml (private hosts/accounts/projects).

# Packages: brew bundle --file="$DOTFILES_DIR/Brewfile"

echo "Done."
