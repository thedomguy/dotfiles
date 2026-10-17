function brow -d "Set or toggle the default browser in Finicky"
    set -l finicky_config "/Users/rahul.bhatt/.config/finicky.js"
    set -l new_browser

    if test -z "$argv[1]"
        # No argument, toggle behavior
        if grep -q 'defaultBrowser: "Arc"' $finicky_config
            set new_browser "Brave Browser"
        else
            set new_browser "Arc"
        end
        sed -i '' "s/^\(\s*defaultBrowser:\s*\)".*"/\1"$new_browser","/" "$finicky_config"
        echo "Default browser switched to: $new_browser"
    else
        # Argument provided, set to that browser
        set new_browser $argv[1]
        sed -i '' "s/^\(\s*defaultBrowser:\s*\)".*"/\1"$new_browser","/" "$finicky_config"
        echo "Default browser set to: $new_browser"
    end
end
