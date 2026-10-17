function __gwcd_parse_worktrees -d "Print worktree path, basename, and branch (tab-separated)"
    if not git rev-parse --git-dir &>/dev/null
        return 1
    end

    git worktree list | awk '{
        branch = $NF
        gsub(/[][]/, "", branch)
        name = $1
        sub(/.*\//, "", name)
        print $1 "\t" name "\t" branch
    }'
end
