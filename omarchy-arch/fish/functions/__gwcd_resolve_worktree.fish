function __gwcd_resolve_worktree -d "Resolve a worktree name/path/branch to its root path"
    set -l query $argv[1]

    if test -z "$query"
        return 1
    end

    set -l exact_path ""
    set -l exact_name ""
    set -l exact_branch ""
    set -l partial_matches

    for entry in (__gwcd_parse_worktrees)
        set -l parts (string split \t $entry)
        set -l path $parts[1]
        set -l name $parts[2]
        set -l branch $parts[3]

        if test "$query" = "$path"
            echo $path
            return 0
        end

        if test "$query" = "$name"
            if test -n "$exact_name"
                echo "Error: ambiguous worktree name: $query" >&2
                return 1
            end
            set exact_name $path
        end

        if test "$query" = "$branch"
            if test -n "$exact_branch"
                echo "Error: ambiguous worktree branch: $query" >&2
                return 1
            end
            set exact_branch $path
        end

        if string match -q "*$query*" $name; or string match -q "*$query*" $branch
            set partial_matches $partial_matches $path
        end
    end

    if test -n "$exact_name"
        echo $exact_name
        return 0
    end

    if test -n "$exact_branch"
        echo $exact_branch
        return 0
    end

    set -l unique_partials (printf '%s\n' $partial_matches | sort -u)
    if test (count $unique_partials) -eq 1
        echo $unique_partials[1]
        return 0
    end

    return 1
end
