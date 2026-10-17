############ Configuration for Fish Shell

# =====================
# General Navigation
# =====================

# Disable welcome message
set -U fish_greeting ""
set -gx GH_PAGER cat    # Set GitHub CLI pager to cat
alias ll 'ls -lAh'                 # List with details and human-readable sizes
alias .. 'cd ..'                   # Move up one directory
alias ... 'cd ../..'               # Move up two directories
alias c 'clear'                    # Clear terminal screen
alias h 'history'                  # View command history
alias src 'source ~/.config/fish/config.fish'  # Reload Fish config


# =====================
# Git Shortcuts
# =====================
alias ga 'git add .'               # Add all changes
alias gc 'git commit -m'           # Commit with a message
alias gst 'git status'             # Show Git status
alias gl 'git log --oneline --graph --decorate' # Compact Git log
alias gpl 'git pull'               # Pull latest changes
alias gps 'git push'               # Push changes
alias gb 'git branch'              # Show current branches
alias gco 'git checkout'           # Switch branches
alias gcb 'git checkout -b'        # Create and switch to a new branch
alias gcm 'git commit -m'          # Commit with a message
alias gcl 'git clone'              # Clone a repository

# =====================
# Node.js/NPM/Yarn
# =====================
alias nr 'npm run'                 # Shortcut for npm run scripts
alias ni 'npm install'             # Install dependencies
alias nis 'npm install --save'     # Install and save dependencies
alias nig 'npm install --global'   # Install global dependencies
alias nrd 'npm run dev'            # Start development server
alias nrb 'npm run build'          # Run build script
alias ys 'yarn start'              # Start Yarn server
alias ya 'yarn add'                # Add Yarn dependencies
alias yad 'yarn add --dev'         # Add dev dependencies

# =====================
# Docker
# =====================
alias dps 'docker ps'              # List running containers
alias di 'docker images'           # List Docker images
alias dstop 'docker stop (docker ps -q)' # Stop all running containers
alias drm 'docker rm (docker ps -aq)'   # Remove all containers
alias drmi 'docker rmi (docker images -q)' # Remove all images
alias dbuild 'docker build -t'     # Build Docker image
alias dup 'docker-compose up -d'   # Start Docker Compose in detached mode
alias ddown 'docker-compose down'  # Stop Docker Compose

# =====================
# Frontend Development
# =====================
alias serve 'npx serve'            # Quick static server
alias ngrok 'ngrok http 3000'      # Start ngrok tunnel (replace 3000 with your port)
alias preview 'open http://localhost:3000' # Preview local dev server

# =====================
# Backend Development
# =====================
alias pyserv 'python3 -m http.server' # Start Python HTTP server
alias run 'npm run start'            # Start backend server
alias migrate 'python manage.py migrate' # Django migrations
alias seed 'node seed.js'            # Run seed script

# =====================
# Common Utilities
# =====================
alias code 'open -a "Visual Studio Code"' # Open VS Code
alias vim 'nvim'                          # Shortcut for Neovim
alias reload 'exec fish'                  # Reload Fish shell
alias ip 'curl ifconfig.me'               # Get public IP

# =====================
# Reusable Functions
# =====================
# Function to open a project directory and launch VS Code
function proj
    cd ~/projects/$argv
    code .
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

eval "$(/usr/local/bin/brew shellenv)"

# Set DOCKER_HOST to use colima instead of docker desktop
set -x DOCKER_HOST unix://$HOME/.colima/default/docker.sock
set -gx PATH /Users/rahul.bhatt/.nvm/versions/node/v20.0.0/bin $PATH
function mkcd
    mkdir -p $argv[1] && cd $argv[1]
end

# Function to ensure Colima is running before executing SAM commands
function sam
    # Check if Colima is running
    if not colima status &>/dev/null
        echo "Colima is not running. Starting Colima..."
        colima start
    end

    # Execute the original sam command with all arguments
    command sam $argv
end
set -e LF_ICONS
function cpy 
    cat $argv | tee /dev/tty | pbcopy
end
set -g PATH /usr/local/opt/python@3.10/bin $PATH

# Python and pip aliases
alias python='python3'
alias pip='pip3'

# Project or Directory Jumping Aliases
alias sisfront='z /Users/rahul.bhatt/work/aca-project/sis-04-frontend-react'
alias sisback='z /Users/rahul.bhatt/work/aca-project/sis-03-backend'

# Android Development Environment
set -gx ANDROID_HOME $HOME/Library/Android/sdk
set -gx PATH $PATH $ANDROID_HOME/emulator
set -gx PATH $PATH $ANDROID_HOME/platform-tools
set -gx PATH $PATH $ANDROID_HOME/cmdline-tools/latest/bin

# Java Development Environment
set -gx JAVA_HOME /usr/local/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home
set -gx PATH $PATH $JAVA_HOME/bin
# =====================
# Warp Directory Shortcuts
alias warp_logs 'cd ~/Library/Logs && ls warp.log*'
alias warp_data 'cd ~/Library/Application\ Support/dev.warp.Warp-Stable && ls'

# Warp Database Alias
alias warp_db 'sqlite3 ~/Library/Application\ Support/dev.warp.Warp-Stable/warp.sqlite'

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

# Obsidian Vault Directories
# =====================
set -gx OBSIDIAN_PERSONAL_VAULT /Users/rahul.bhatt/personal/PERSONAL
set -gx OBSIDIAN_DATAMATICS_VAULT /Users/rahul.bhatt/Documents/datamatics
set -gx OBSIDIAN_PERSONAL_CONFIG /Users/rahul.bhatt/personal/PERSONAL/.obsidian
set -gx OBSIDIAN_DATAMATICS_CONFIG /Users/rahul.bhatt/Documents/datamatics/.obsidian
set -gx OBSIDIAN_APP_DATA "/Users/rahul.bhatt/Library/Application Support/obsidian"
