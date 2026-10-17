function cheat -d "View, list, or edit cheatsheets in $CHEATSHEET_DIR"
    set -l dir $CHEATSHEET_DIR
    if not set -q dir[1]
        set dir ~/personal/dotfiles/cheatsheets
    end

    switch "$argv[1]"
        case '' -l --list
            if type -q fzf
                set -l pick (find $dir -name '*.md' ! -name '_template.md' -exec basename {} .md \; | sort \
                    | fzf --prompt='cheat> ' --preview "cat $dir/{}.md" --preview-window=right:65%)
                test -n "$pick"; and cat $dir/$pick.md
            else
                find $dir -name '*.md' ! -name '_template.md' -exec basename {} .md \; | sort
            end
        case -e --edit
            if test -z "$argv[2]"
                echo "Usage: cheat -e <topic>" >&2
                return 1
            end
            set -l file $dir/$argv[2].md
            if not test -f $file
                cp $dir/_template.md $file
                sed -i '' "s/<topic>/$argv[2]/" $file
            end
            $EDITOR $file
        case -n --new
            cheat -e $argv[2]
        case '*'
            set -l file $dir/$argv[1].md
            if test -f $file
                cat $file
            else
                echo "No cheatsheet for '$argv[1]'. Create one with: cheat -e $argv[1]" >&2
                return 1
            end
    end
end
