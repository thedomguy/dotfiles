# dirlog.fish — directory-aware command history with rich metadata
# Logs: ~/.local/share/fish/dirlogs/
#   all.jsonl              global log, every command
#   <encoded-path>/
#     path                 real path string
#     log.jsonl            commands run in this directory
#     visits               epoch timestamps of each cd into this dir

set -q DIRLOG_ROOT; or set -gx DIRLOG_ROOT $HOME/.local/share/fish/dirlogs

# ---------------------------------------------------------------------------
# Encode a path into a safe directory name
# /Users/rahul/foo/bar  →  ~__foo__bar
# ---------------------------------------------------------------------------
function __dirlog_key --argument-names path
    string replace --all '/' '__' -- (string replace -- $HOME '~' $path)
end

# ---------------------------------------------------------------------------
# Before a command runs: snapshot time and working directory
# ---------------------------------------------------------------------------
function __dirlog_preexec --on-event fish_preexec
    set -g __dirlog_t0  (date +%s)
    set -g __dirlog_pwd $PWD
end

# ---------------------------------------------------------------------------
# After a command finishes: write one JSON line to dir log + global log
# Uses Python for guaranteed-valid JSON serialization
# ---------------------------------------------------------------------------
function __dirlog_postexec --on-event fish_postexec
    set -l cmd       $argv[1]
    set -l exit_code $argv[2]

    set -l t1 (date +%s)
    set -l duration 0
    if set -q __dirlog_t0
        set duration (math $t1 - $__dirlog_t0)
        set -e __dirlog_t0
    end

    set -l run_pwd $PWD
    if set -q __dirlog_pwd
        set run_pwd $__dirlog_pwd
        set -e __dirlog_pwd
    end

    set -l dir_store $DIRLOG_ROOT/(__dirlog_key $run_pwd)

    if not test -d $dir_store
        mkdir -p $dir_store
        printf '%s\n' $run_pwd > $dir_store/path
    end

    # Python handles all escaping edge cases (quotes, backslashes, newlines, etc.)
    # Values are passed via env vars to avoid argv parsing issues
    set -l ts (date +%s)
    set -l entry (env __DL_CMD=$cmd __DL_PWD=$run_pwd python3 -c "
import json, os
print(json.dumps({'when':$ts,'cmd':os.environ['__DL_CMD'],'pwd':os.environ['__DL_PWD'],'duration_s':$duration,'exit':$exit_code}))
" 2>/dev/null)

    test -n "$entry"; or return

    printf '%s\n' $entry >> $dir_store/log.jsonl
    printf '%s\n' $entry >> $DIRLOG_ROOT/all.jsonl
end

# ---------------------------------------------------------------------------
# Track every directory change (cd, z, pushd, etc.)
# ---------------------------------------------------------------------------
function __dirlog_track_pwd --on-variable PWD
    set -l dir_store $DIRLOG_ROOT/(__dirlog_key $PWD)
    if not test -d $dir_store
        mkdir -p $dir_store
        printf '%s\n' $PWD > $dir_store/path
    end
    printf '%d\n' (date +%s) >> $dir_store/visits
end
