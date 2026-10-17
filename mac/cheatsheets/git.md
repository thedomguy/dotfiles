# git

Day-to-day git recall, beyond what's already covered by shell shortcuts
(see `cheat fish` for the `ga`/`gcm`/`gst`/`gw*` abbreviations).

## Worktrees

- `git worktree list` (`gwl`) — show all worktrees and their branches
- `git worktree add <path> [branch]` (`gwa`) — add a worktree at `<path>`
- `git worktree add -b <branch> <path>` (`gwab`) — new branch + new worktree
- `git worktree remove <path>` (`gwr`) — remove a worktree (must be clean)
- `git worktree remove --force <path>` (`gwrf`) — remove even if dirty
- `git worktree prune` (`gwp`) — clean up stale worktree admin files
- `gwcd [name]` — cd into a worktree by fuzzy name (fzf if no arg)
- `gwnew <path> [branch]` — add a worktree and cd into it in one step
- `gwdel <path>` — remove a worktree and cd back to the main root

## Undo / recover

- `git restore --staged <file>` — unstage a file, keep changes
- `git restore <file>` — discard unstaged changes to a file
- `git reset --soft HEAD~1` — undo last commit, keep changes staged
- `git reflog` — find a commit git "lost" (branch reset, rebase, etc.)
- `git stash -u` — stash including untracked files
- `git commit --amend --no-edit` — fix the last commit without changing the message

## Inspecting

- `git log --oneline --graph --decorate` (`gl`) — compact branch graph
- `git diff --staged` — see what's about to be committed
- `git blame -L 10,20 <file>` — who last touched lines 10-20
- `git log -p -- <file>` — full history of a single file
- `git show <commit>:<path>` — view a file as of a specific commit

## Branches

- `git branch -vv` — branches with tracking + last commit
- `git branch -d <branch>` / `-D` — delete merged / force-delete
- `git push -u origin <branch>` — push and set upstream in one go
- `git fetch --prune` — drop local refs to branches deleted on the remote

## Gotchas

- Never `git push --force` to `main`/`master` without asking first.
- `git clean -f` / `reset --hard` are destructive — `git status` before running them, stash `-u` if anything's there worth keeping.
- `--no-verify` skips hooks — only when explicitly asked to.
