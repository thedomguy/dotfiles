# Word Smart Document servers. Script lives in iom-prima .local (not git).
# Reinstall: /Users/rahul.bhatt/work/iom-prima/.local/word-smart-doc/spawn.sh install-alias
set -gx IOM_WSD_SPAWN /Users/rahul.bhatt/work/iom-prima/.local/word-smart-doc/spawn.sh
set -g IOM_WSD_WORKTREES /Users/rahul.bhatt/work/iom-prima/.worktrees

function wsd --description 'Word Smart Document local servers (API, app, add-ins)'
    $IOM_WSD_SPAWN $argv
end

function _iom_wsd_sync_dir_aliases --on-variable PWD
    if test "$PWD" = "$IOM_WSD_WORKTREES"; or string match -q -- "$IOM_WSD_WORKTREES/*" "$PWD/"
        function wsd-up --description 'Start Word Smart Document servers'
            $IOM_WSD_SPAWN up $argv
        end
        function wsd-down --description 'Stop Word Smart Document servers'
            $IOM_WSD_SPAWN down $argv
        end
        function wsd-restart --description 'Restart Word Smart Document servers'
            $IOM_WSD_SPAWN restart $argv
        end
        function wsd-status --description 'Status of Word Smart Document servers'
            $IOM_WSD_SPAWN status $argv
        end
        function wsd-logs --description 'Live zellij log view'
            $IOM_WSD_SPAWN zj $argv
        end
    else
        functions -e wsd-up wsd-down wsd-restart wsd-status wsd-logs
    end
end

_iom_wsd_sync_dir_aliases

complete -c wsd -f
complete -c wsd -n '__fish_use_subcommand' -a up -d 'Start if not already listening'
complete -c wsd -n '__fish_use_subcommand' -a restart -d 'Stop then start'
complete -c wsd -n '__fish_use_subcommand' -a down -d 'Stop API, user-app, add-in'
complete -c wsd -n '__fish_use_subcommand' -a status -d 'Ports and PIDs'
complete -c wsd -n '__fish_use_subcommand' -a logs -d 'Live zellij logs, or tail api|app|addin'
complete -c wsd -n '__fish_use_subcommand' -a zj -d 'Live zellij: 3 vertical log splits'
complete -c wsd -n '__fish_use_subcommand' -a install-alias -d 'Reinstall this fish setup'
complete -c wsd -n '__fish_seen_subcommand_from up restart' -l word -d 'Refresh WEF manifests and open Word'
complete -c wsd -n '__fish_seen_subcommand_from up restart' -l kill-3000 -d 'Free port 3000 if something else is bound'
complete -c wsd -n '__fish_seen_subcommand_from logs' -a 'api app addin'
