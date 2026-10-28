# Repository notes

## AeroSpace

- User config: `~/.aerospace.toml`, symlinked to `mac/.aerospace.toml` in this repository.
- CLI executable: `/opt/homebrew/bin/aerospace`. It is a client for the running `AeroSpace.app` menu-bar process; commands such as `aerospace reload-config`, `list-monitors`, `list-workspaces`, and `workspace <name>` require that app/server to be running.
- Upstream project and command/config reference: https://github.com/nikitabobko/AeroSpace and https://nikitabobko.github.io/AeroSpace/commands
- Repo-specific monitor/workspace troubleshooting context: `mac/AEROSPACE_CONTEXT.md`.

When working on AeroSpace, inspect `mac/.aerospace.toml` and the context note before changing monitor/workspace behavior. Verify CLI syntax against the installed version or upstream docs because AeroSpace is beta and commands may change.
