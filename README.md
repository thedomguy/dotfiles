# My Dotfiles

This repository contains my personal dotfiles. They are managed using symbolic links from this directory to the home directory.

## Setup and Management

The symbolic links are managed by the script in `scripts/manage_symlinks.sh`.

To update or recreate the symlinks, run the following command from the root of this repository:

```bash
./scripts/manage_symlinks.sh
```

The script will prompt you for any conflicts or decisions that need to be made.

### Managed Dotfiles

The following dotfiles are currently managed by this repository:

| Source File | Symlink Name |
| :--- | :--- |
| `/Users/rahul.bhatt/.aerospace.toml` | `.aerospace.toml` |
| `/Users/rahul.bhatt/.bash_profile` | `.bash_profile` |
| `/Users/rahul.bhatt/.bashrc` | `.bashrc` |
| `/Users/rahul.bhatt/.gitconfig` | `.gitconfig` |
| `/Users/rahul.bhatt/.gitconfig-work` | `.gitconfig-work` |
| `/Users/rahul.bhatt/.gitconfig.backup` | `.gitconfig.backup` |
| `/Users/rahul.bhatt/.ideavimrc` | `.ideavimrc` |
| `/Users/rahul.bhatt/.profile` | `.profile` |
| `/Users/rahul.bhatt/.tmux.conf` | `.tmux.conf` |
| `/Users/rahul.bhatt/.vimrc` | `.vimrc` |
| `/Users/rahul.bhatt/.zshrc` | `.zshrc` |
| `/Users/rahul.bhatt/.nvm/.dockerignore` | `nvm.dockerignore` |
| `/Users/rahul.bhatt/.nvm/.editorconfig`| `nvm.editorconfig`|
| `/Users/rahul.bhatt/.nvm/.gitattributes`| `nvm.gitattributes` |
| `/Users/rahul.bhatt/.nvm/.gitignore` | `nvm.gitignore` |
| `/Users/rahul.bhatt/.nvm/.mailmap` | `nvm.mailmap` |
| `/Users/rahul.bhatt/.nvm/.travis.yml` | `nvm.travis.yml` |
| `/Users/rahul.bhatt/personal/.env` | `personal.env` |
| `/Users/rahul.bhatt/personal/.gitconfig` | `personal.gitconfig`|

