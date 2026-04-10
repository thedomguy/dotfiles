#!/bin/bash

# This script symlinks the dotfiles to the current directory.

TARGET_DIR="/Users/rahul.bhatt/personal/dotfiles"

# Function to create a symlink, asking for confirmation if it exists
symlink_file() {
  local source_file="$1"
  local dest_file="$2"

  if [ -e "$dest_file" ] || [ -L "$dest_file" ]; then
    read -p "Symlink for $(basename "$source_file") at $dest_file already exists. Overwrite? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      ln -sf "$source_file" "$dest_file"
      echo "Overwrote symlink: $dest_file -> $source_file"
    else
      echo "Skipped symlink: $dest_file"
    fi
  else
    ln -s "$source_file" "$dest_file"
    echo "Created symlink: $dest_file -> $source_file"
  fi
}

# List of files to symlink
source_files=(
  "/Users/rahul.bhatt/.aerospace.toml"
  "/Users/rahul.bhatt/.bash_profile"
  "/Users/rahul.bhatt/.bashrc"
  "/Users/rahul.bhatt/.gitconfig"
  "/Users/rahul.bhatt/.gitconfig-work"
  "/Users/rahul.bhatt/.gitconfig.backup"
  "/Users/rahul.bhatt/.ideavimrc"
  "/Users/rahul.bhatt/.profile"
  "/Users/rahul.bhatt/.tmux.conf"
  "/Users/rahul.bhatt/.vimrc"
  "/Users/rahul.bhatt/.zshrc"
  "/Users/rahul.bhatt/.nvm/.dockerignore"
  "/Users/rahul.bhatt/.nvm/.editorconfig"
  "/Users/rahul.bhatt/.nvm/.gitattributes"
  "/Users/rahul.bhatt/.nvm/.gitignore"
  "/Users/rahul.bhatt/.nvm/.mailmap"
  "/Users/rahul.bhatt/.nvm/.travis.yml"
  "/Users/rahul.bhatt/personal/.env"
  "/Users/rahul.bhatt/personal/.gitconfig"
)

dest_names=(
  ".aerospace.toml"
  ".bash_profile"
  ".bashrc"
  ".gitconfig"
  ".gitconfig-work"
  ".gitconfig.backup"
  ".ideavimrc"
  ".profile"
  ".tmux.conf"
  ".vimrc"
  ".zshrc"
  "nvm.dockerignore"
  "nvm.editorconfig"
  "nvm.gitattributes"
  "nvm.gitignore"
  "nvm.mailmap"
  "nvm.travis.yml"
  "personal.env"
  "personal.gitconfig"
)

for i in "${!source_files[@]}"; do
  source_file="${source_files[$i]}"
  dest_name="${dest_names[$i]}"
  symlink_file "$source_file" "$TARGET_DIR/$dest_name"
done

echo "Done."
