function __gwcd_complete_worktrees
    set -l token (commandline -ct)

    # Already typed a valid worktree — skip completion (avoids fzf re-prompt).
    if test -n "$token"
        set -l resolved (__gwcd_resolve_worktree $token 2>/dev/null)
        if test -n "$resolved"
            return
        end
    end

    set -l current (git rev-parse --show-toplevel 2>/dev/null)

    for entry in (__gwcd_parse_worktrees 2>/dev/null)
        set -l parts (string split \t $entry)
        set -l path $parts[1]
        set -l name $parts[2]
        set -l branch $parts[3]

        if test "$path" = "$current"
            continue
        end

        printf '%s\t%s (%s)\n' $name $path $branch
    end
end

complete -c gwcd -f -a '(__gwcd_complete_worktrees)'
