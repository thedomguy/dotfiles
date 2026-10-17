function __cheat_topics
    set -l dir $CHEATSHEET_DIR
    if not set -q dir[1]
        set dir ~/personal/dotfiles/cheatsheets
    end
    find $dir -name '*.md' ! -name '_template.md' -exec basename {} .md \; 2>/dev/null
end

complete -c cheat -f -a "(__cheat_topics)" -d "cheatsheet"
complete -c cheat -s l -l list -d "list topics"
complete -c cheat -s e -l edit -d "edit (or create) a topic" -a "(__cheat_topics)"
complete -c cheat -s n -l new -d "create a new topic"
