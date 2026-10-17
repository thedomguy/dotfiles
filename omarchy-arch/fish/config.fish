############ Configuration for Fish Shell

# =====================
# General Navigation
# =====================

# Disable welcome message
set -U fish_greeting ""
set -gx GH_PAGER cat    # Set GitHub CLI pager to cat

# Default editor -> Neovim
set -gx EDITOR nvim     # Used by git, kubectl, less-edit, etc.
set -gx VISUAL nvim     # Full-screen editor preference
# Make plain `vi` / `vim` open Neovim too
# (vi, vim, ll moved to abbrs.fish)

function llgrep
    if test (count $argv) -eq 0
        echo "Usage: llgrep <pattern>"
        return 1
    end
    ll | grep -- (string join ' ' $argv)
end

# .., ..., c, h, src, git/node/docker/frontend/backend shortcuts, reload,
# ip, ang moved to conf.d/abbrs.fish as abbreviations (history-preserving).
# vi/vim/ll/code stay as aliases: llgrep/lls call `ll` and proj calls `code`
# internally, and abbreviations don't expand inside function bodies.

# =====================
# Common Utilities
# =====================
# code moved to abbrs.fish

# =====================
# Reusable Functions
# =====================
# Function to open a project directory and launch VS Code
function proj
    cd ~/projects/$argv
    code .
end

set -gx NVM_DIR $HOME/.nvm
function nvm
    bass source $NVM_DIR/nvm.sh --no-use ';' nvm $argv
end
function zz
    set folder_path (realpath $argv[1])  # Get the full path of the folder
    set folder_name (basename $folder_path)  # Extract the folder name
    set parent_dir (dirname $folder_path)  # Extract the parent directory
    cd $parent_dir  # Change to the folder's parent directory
    zip -r "$folder_name.zip" "$folder_name"  # Create the zip
end

# Function to quickly launch iTerm2
function iterm
    open -a iTerm
end

# Added by Windsurf
fish_add_path /Users/rahul.bhatt/.codeium/windsurf/bin

# Homebrew - use native ARM64 if available, fallback to x86_64
if test -f /opt/homebrew/bin/brew
    eval "$(/opt/homebrew/bin/brew shellenv)"
else if test -f /usr/local/bin/brew
    eval "$(/usr/local/bin/brew shellenv)"
end

function safe_add_path
    for path_item in $argv
        if test -d $path_item; and not contains $path_item $PATH
            set -gx PATH $path_item $PATH
        end
    end
end

function mkcd
    mkdir -p $argv[1] && cd $argv[1]
end

# Function to switch to Docker Desktop from Colima
function use-docker-desktop
    docker context use desktop-linux 2>/dev/null
    
    if docker info &>/dev/null
        echo "✓ Switched to Docker Desktop (running)"
        return 0
    else
        echo "Docker Desktop is not running."
        echo ""
        echo "To start Docker Desktop:"
        echo "  1. Open Docker Desktop from Applications or Spotlight"
        echo "  2. Or install it from: https://www.docker.com/products/docker-desktop"
        echo ""
        echo "Once Docker Desktop is running, run 'docker info' to verify."
        return 1
    end
end

set -e LF_ICONS
function cpy 
    cat $argv | tee /dev/tty | pbcopy
end

# Add Python to PATH
# safe_add_path /usr/local/opt/python@3.10/bin

# Python and pip aliases
# (python and pip moved to abbrs.fish)

# Project/directory jumps and warp_logs/warp_data/warp_db moved to
# conf.d/abbrs.fish as abbreviations.

# Android/Java env is centralized in conf.d/20-rn-android-env.fish
# =====================

# Warp Conversation Functions
function warp_conversations
    # List recent conversations with their first queries
    sqlite3 ~/Library/Application\ Support/dev.warp.Warp-Stable/warp.sqlite "SELECT conversation_id, MIN(start_ts) as first_message_time, (SELECT substr(input, 1, 100) FROM ai_queries aq2 WHERE aq2.conversation_id = aq1.conversation_id AND aq2.input LIKE '%Query%' ORDER BY start_ts LIMIT 1) as first_query FROM ai_queries aq1 WHERE conversation_id IN (SELECT conversation_id FROM agent_conversations ORDER BY last_modified_at DESC LIMIT 10) GROUP BY conversation_id ORDER BY first_message_time DESC;"
end

function warp_search
    # Search conversations by keyword
    set search_term $argv[1]
    if test -z "$search_term"
        echo "Usage: warp_search <keyword>"
        return 1
    end
    sqlite3 ~/Library/Application\ Support/dev.warp.Warp-Stable/warp.sqlite "SELECT conversation_id, start_ts, substr(input, 1, 200) FROM ai_queries WHERE input LIKE '%$search_term%' ORDER BY start_ts DESC LIMIT 10;"
end


# Browser Toggle
# =====================
function toggle_browser
    set current_handler (duti -l http | head -1)
    if test "$current_handler" = "com.brave.Browser"
        duti -s company.thebrowser.Browser http all
        duti -s company.thebrowser.Browser https all
        /System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister -kill -r -domain local -domain system -domain user >/dev/null 2>&1
        echo "Switched to Arc"
    else if test "$current_handler" = "company.thebrowser.Browser"
        duti -s com.brave.Browser http all
        duti -s com.brave.Browser https all
        /System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister -kill -r -domain local -domain system -domain user >/dev/null 2>&1
        echo "Switched to Brave"
    else
        echo "Unknown current browser: $current_handler"
        echo "Setting Arc as default..."
        duti -s company.thebrowser.Browser http all
        duti -s company.thebrowser.Browser https all
        /System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister -kill -r -domain local -domain system -domain user >/dev/null 2>&1
    end
end

# Cheatsheet system (see `cheat -l`, `cheat -e <topic>`)
# =====================
set -gx CHEATSHEET_DIR ~/personal/dotfiles/cheatsheets

# Obsidian Vault Directories
# =====================
set -gx OBSIDIAN_PERSONAL_VAULT /Users/rahul.bhatt/personal/PERSONAL
set -gx OBSIDIAN_DATAMATICS_VAULT /Users/rahul.bhatt/Documents/datamatics
set -gx OBSIDIAN_PERSONAL_CONFIG /Users/rahul.bhatt/personal/PERSONAL/.obsidian
set -gx OBSIDIAN_DATAMATICS_CONFIG /Users/rahul.bhatt/Documents/datamatics/.obsidian
set -gx OBSIDIAN_APP_DATA "/Users/rahul.bhatt/Library/Application Support/obsidian"

# Final PATH cleanup - Remove any duplicates that might have slipped through
# ========================================================================
set -l unique_paths
for path_item in (string split : $PATH)
    if not contains $path_item $unique_paths
        set -a unique_paths $path_item
    end
end
set -gx PATH (string join : $unique_paths)


# `interval` moved to conf.d/abbrs.fish as an abbreviation.

# Added by Antigravity
fish_add_path /Users/rahul.bhatt/.antigravity/antigravity/bin

# Added by Antigravity
fish_add_path /Users/rahul.bhatt/.antigravity/antigravity/bin
export PATH="$HOME/.local/bin:$PATH"

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH

function lls
    ll | grep $argv
end

# asdf shims should be first for project-local tool versions
if test -z "$ASDF_DATA_DIR"
    set -gx ASDF_DATA_DIR $HOME/.asdf
end
if test -d "$ASDF_DATA_DIR/shims"
    set -l cleaned_path (string match -v "$ASDF_DATA_DIR/shims" $PATH)
    set -gx PATH "$ASDF_DATA_DIR/shims" $cleaned_path
end

# lf (list files) configuration for cd on exit
function lfcd
    set tmp (mktemp)
    command lf -last-dir-path=$tmp $argv
    if test -f "$tmp"
        set dir (cat "$tmp")
        rm -f "$tmp"
        if test -d "$dir"
            if test "$dir" != (pwd)
                cd "$dir"
            end
        end
    end
end
# lf moved to abbrs.fish

function adb-reverse-physical
    set devices (adb devices | tail -n +2 | awk '{print $1}')

    for d in $devices
        if test -z "$d"
            continue
        end

        if string match -q "emulator-*" $d
            continue
        end

        echo "Applying reverse to $d"
        adb -s $d reverse tcp:8081 tcp:8081
    end
end


function cs2
    set target $argv
    if test (count $argv) -eq 0
        set target .
    end

    nohup /Applications/Cursor.app/Contents/MacOS/Cursor --user-data-dir=$HOME/.cursor-work $target > /dev/null 2>&1 & disown
end


function cs3
    set target $argv
    if test (count $argv) -eq 0
        set target .
    end

    nohup /Applications/Cursor.app/Contents/MacOS/Cursor --user-data-dir=$HOME/.cursor $target > /dev/null 2>&1 & disown
end

# Added by Antigravity
fish_add_path /Users/rahul.bhatt/.antigravity/antigravity/bin

# Entire CLI shell completion
type -q entire; and entire completion fish | source

# Added by Antigravity IDE
fish_add_path /Users/rahul.bhatt/.antigravity-ide/antigravity-ide/bin


# Added by Antigravity CLI installer
set -gx PATH "/Users/rahul.bhatt/.local/bin" $PATH

# kimi-code
fish_add_path -g "/Users/rahul.bhatt/.kimi-code/bin"
