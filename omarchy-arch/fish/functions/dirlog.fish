# dirlog — query directory-aware command history
#
# Usage:
#   dirlog            recent commands across all directories (last 20)
#   dirlog here       commands run in the current directory
#   dirlog ls         list all tracked directories (sorted by command count)
#   dirlog tail       live-tail the global log
#   dirlog path PATH  show commands for a specific path
#   dirlog stats      summary counts per directory

function dirlog --description 'Query directory-aware command history'
    set -l root $DIRLOG_ROOT

    if not test -d $root
        echo "No dirlog data yet. Commands will be logged as you use fish."
        return 0
    end

    switch (count $argv) # dispatch on subcommand
        case 0
            __dirlog_show $root/all.jsonl 20
        case '*'
            switch $argv[1]
                case '' recent
                    __dirlog_show $root/all.jsonl 20

                case here
                    set -l key (__dirlog_key $PWD)
                    set -l log $root/$key/log.jsonl
                    if not test -f $log
                        echo "No log for $PWD yet."
                        return 0
                    end
                    __dirlog_show $log 50

                case path
                    if not set -q argv[2]
                        echo "Usage: dirlog path <directory>"
                        return 1
                    end
                    set -l key (__dirlog_key $argv[2])
                    set -l log $root/$key/log.jsonl
                    if not test -f $log
                        echo "No log for $argv[2]"
                        return 1
                    end
                    __dirlog_show $log 50

                case ls list
                    # List dirs sorted by command count, descending
                    set -l entries
                    for path_file in $root/*/path
                        if not test -f $path_file
                            continue
                        end
                        set -l dir_path (cat $path_file)
                        set -l log (string replace '/path' '/log.jsonl' -- $path_file)
                        set -l count 0
                        if test -f $log
                            set count (wc -l < $log | string trim)
                        end
                        set -a entries (printf '%06d\t%s' $count $dir_path)
                    end
                    # Sort descending and pretty-print
                    printf '%s\n' $entries | sort -rn | while read -l line
                        set -l parts (string split \t -- $line)
                        printf '%5d  %s\n' (string trim -- $parts[1]) $parts[2]
                    end

                case tail
                    tail -f $root/all.jsonl

                case stats
                    set -l total 0
                    set -l dirs 0
                    for log in $root/*/log.jsonl
                        set -l n (wc -l < $log | string trim)
                        set total (math $total + $n)
                        set dirs (math $dirs + 1)
                    end
                    printf 'Tracked directories : %d\n' $dirs
                    printf 'Total commands      : %d\n' $total

                case serve
                    set -q DIRLOG_PORT; and set -l port $DIRLOG_PORT; or set -l port 7777
                    set -l server $root/server.py
                    if not test -f $server
                        echo "Server not found: $server"
                        return 1
                    end
                    DIRLOG_ROOT=$root DIRLOG_PORT=$port python3 $server

                case help -h --help
                    echo "Usage: dirlog [here|ls|tail|stats|serve|path <dir>]"

                case '*'
                    echo "Unknown subcommand: $argv[1]"
                    echo "Usage: dirlog [here|ls|tail|stats|path <dir>]"
                    return 1
            end
    end
end

function __dirlog_show --argument-names log_file limit
    if not test -f $log_file
        echo "Log not found: $log_file"
        return 1
    end

    tail -n $limit $log_file
end
