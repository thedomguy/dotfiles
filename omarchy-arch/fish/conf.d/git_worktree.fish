# Git Worktree Abbreviations
abbr -a gwl 'git worktree list'
abbr -a gwa 'git worktree add'
abbr -a gwab 'git worktree add -b'
abbr -a gwr 'git worktree remove'
abbr -a gwrf 'git worktree remove --force'
abbr -a gwp 'git worktree prune'
abbr -a gwmv 'git worktree move'
abbr -a gwlock 'git worktree lock'
abbr -a gwunlock 'git worktree unlock'

# Git Worktree Functions
function gwnew -d "Add a new git worktree and cd into it"
    git worktree add $argv && cd $argv[1]
end

function gwdel -d "Remove a git worktree and cd back to main root"
    set main (git worktree list | head -1 | awk '{print $1}')
    git worktree remove $argv[1]
    cd $main
end
