# Abbreviations expand to their full command in the buffer before you hit
# enter, so (unlike `alias`) the real command is what shows up in history.
# Kept separate from git_worktree.fish's gw* abbreviations for readability.

# Navigation
abbr -a .. 'cd ..'
abbr -a ... 'cd ../..'
abbr -a c 'clear'
abbr -a h 'history'
abbr -a src 'source ~/.config/fish/config.fish'

# Git
abbr -a ga 'git add .'
abbr -a gcm 'git commit -m'
abbr -a gst 'git status'
abbr -a gl 'git log --oneline --graph --decorate'
abbr -a gpl 'git pull'
abbr -a gps 'git push'
abbr -a gb 'git branch'
abbr -a gco 'git checkout'
abbr -a gcb 'git checkout -b'
abbr -a gcl 'git clone'

# Node/NPM/Yarn
abbr -a nr 'npm run'
abbr -a ni 'npm install'
abbr -a nis 'npm install --save'
abbr -a nig 'npm install --global'
abbr -a nrd 'npm run dev'
abbr -a nrb 'npm run build'
abbr -a ys 'yarn start'
abbr -a ya 'yarn add'
abbr -a yad 'yarn add --dev'

# Docker
abbr -a dps 'docker ps'
abbr -a di 'docker images'
abbr -a dstop 'docker stop (docker ps -q)'
abbr -a drm 'docker rm (docker ps -aq)'
abbr -a drmi 'docker rmi (docker images -q)'
abbr -a dbuild 'docker build -t'
abbr -a dup 'docker-compose up -d'
abbr -a ddown 'docker-compose down'

# Frontend/Backend dev
abbr -a serve 'npx serve'
abbr -a ngrok 'ngrok http 3000'
abbr -a preview 'open http://localhost:3000'
abbr -a pyserv 'python3 -m http.server'
abbr -a run 'npm run start'
abbr -a migrate 'python manage.py migrate'
abbr -a seed 'node seed.js'

# Utilities
abbr -a reload 'exec fish'
abbr -a ip 'curl ifconfig.me'
abbr -a ang 'open -a "Antigravity IDE"'

# Project/directory jumps
abbr -a sisfront 'z /Users/rahul.bhatt/work/aca-project/sis-04-frontend-react'
abbr -a sisback 'z /Users/rahul.bhatt/work/aca-project/sis-03-backend'

# Warp
abbr -a warp_logs 'cd ~/Library/Logs && ls warp.log*'
abbr -a warp_data 'cd ~/Library/Application\ Support/dev.warp.Warp-Stable && ls'
abbr -a warp_db 'sqlite3 ~/Library/Application\ Support/dev.warp.Warp-Stable/warp.sqlite'

# Misc
abbr -a interval '/Users/rahul.bhatt/personal/bash/interval_executor.sh'
abbr -a ch 'cheat'

# Display layout (see `display.fish` — extend/mirror/retina/status/log)
abbr -a de 'display extend'
abbr -a dm 'display mirror'

# --- Migrated from config.fish ---
abbr -a vi nvim
abbr -a vim nvim
abbr -a ll 'ls -lAh'
abbr -a code 'open -a "Visual Studio Code"'
abbr -a python python3
abbr -a pip pip3
abbr -a lf lfcd

# --- Migrated from functions/ ---
abbr -a awsfnh 'aws --profile fnh'
abbr -a boo 'ghostty +boo'
abbr -a brewup 'brew update && brew upgrade && brew cleanup'
abbr -a ccu 'claude -p "/usage"'
abbr -a chrome '"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"'
abbr -a ci 'glab ci status'
abbr -a clad claude
abbr -a cls clear
abbr -a e exit
abbr -a ec2sonar 'ssh -i ~/.ssh/aca-whitelabel/sonar-ec2.pem ubuntu@ec2-47-129-204-101.ap-southeast-1.compute.amazonaws.com'
abbr -a gca gemini
abbr -a gemup 'brew upgrade gemini-cli'
abbr -a ow 'docker start ollama && docker start open-webui'
abbr -a owe 'docker stop open-webui ollama'
abbr -a py python3
abbr -a pyvenv 'source .venv/bin/activate.fish'
abbr -a sb 'open -a "Sublime Text"'
abbr -a student_pipeline 'cd /Users/rahul.bhatt/work/aca-project/student-03-backend && npm run pipeline -- dq'
abbr -a swap_claude /Users/rahul.bhatt/swap_claude.sh
abbr -a tf terraform
abbr -a warp 'open -a Warp'
abbr -a wf 'open -a windsurf'
abbr -a ws 'open -a Webstorm .'
abbr -a zhis 'vi $Z_DATA'
abbr -a zj zellij
abbr -a zp 'cd ~/personal'
