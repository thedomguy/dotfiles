function envlist --description 'Print env files. Options: -r for recursive, -c to include envrc files'
    # Parse -r and -c flags (no long flags)
    argparse r c -- $argv
    or return 1

    set -l target_dir .
    if count $argv >/dev/null
        set target_dir $argv[1]
    end

    set -l find_opts
    if not set -q _flag_r
        set find_opts -maxdepth 1
    end

    set -l name_opts -name ".env*" -o -name "*.env"
    if set -q _flag_c
        set name_opts $name_opts -o -name "*envrc*"
    end

    find $target_dir $find_opts \( -name node_modules -o -name .git \) -prune -o -type f \( $name_opts \) ! -name "*example*" ! -name "*.swp" ! -name "*.swo" -exec tail -v -n +1 {} + | python3 ~/.config/fish/functions/envlist_formatter.py
end
