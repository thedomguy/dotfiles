#!/bin/bash

# Creates symlinks in ~ pointing to files in this dotfiles repo.
# Source of truth lives in the repo; home directory gets symlinks.

DOTFILES_DIR="/Users/rahul.bhatt/personal/dotfiles"

symlink_file() {
  local source_file="$1"  # file in dotfiles repo
  local dest_file="$2"    # symlink location in home

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
symlink_file "$DOTFILES_DIR/.gitconfig"         "/Users/rahul.bhatt/.gitconfig"
symlink_file "$DOTFILES_DIR/.gitconfig-work"    "/Users/rahul.bhatt/.gitconfig-work"
symlink_file "$DOTFILES_DIR/.gitconfig.backup"  "/Users/rahul.bhatt/.gitconfig.backup"
symlink_file "$DOTFILES_DIR/.ideavimrc"         "/Users/rahul.bhatt/.ideavimrc"
symlink_file "$DOTFILES_DIR/.profile"           "/Users/rahul.bhatt/.profile"
symlink_file "$DOTFILES_DIR/.tmux.conf"         "/Users/rahul.bhatt/.tmux.conf"
symlink_file "$DOTFILES_DIR/.vimrc"             "/Users/rahul.bhatt/.vimrc"
symlink_file "$DOTFILES_DIR/.zshrc"             "/Users/rahul.bhatt/.zshrc"
symlink_file "$DOTFILES_DIR/personal.gitconfig" "/Users/rahul.bhatt/personal/.gitconfig"

echo "Done."
