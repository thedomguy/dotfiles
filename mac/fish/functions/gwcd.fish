function gwcd -d "Change to another git worktree, preserving your relative path"
    if not git rev-parse --show-toplevel &>/dev/null
        echo "Error: not inside a git worktree." >&2
        return 1
    end

    set -l current_root (git rev-parse --show-toplevel)
    set -l rel_path (git rev-parse --show-prefix | string trim --right --chars=/)
    set -l target_root

    if test (count $argv) -ge 1
        # Argument given — resolve and go directly, no fzf.
        set target_root (__gwcd_resolve_worktree $argv[1])
        if test -z "$target_root"
            echo "Error: worktree not found: $argv[1]" >&2
            return 1
        end
    else
        # No argument — interactive fzf picker.
        if not type -q fzf
            echo "Usage: gwcd <worktree>" >&2
            echo "  Or run gwcd with no args (requires fzf)." >&2
            return 1
        end
        set target_root (git worktree list | fzf --height=40% --select-1 --exit-0 | awk '{print $1}')
        if test -z "$target_root"
            return 1
        end
    end

    if test "$target_root" = "$current_root"
        echo "Already in worktree: "(basename $target_root) >&2
        return 0
    end

    if test -n "$rel_path" -a -d "$target_root/$rel_path"
        cd "$target_root/$rel_path"
    else if test -n "$rel_path"
        echo "Note: $rel_path not found in target worktree; going to root." >&2
        cd "$target_root"
    else
        cd "$target_root"
    end
end
