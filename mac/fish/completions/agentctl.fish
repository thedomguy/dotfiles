# fish completion for agentctl — dynamic values come from "agentctl __complete".

function __agentctl_values
    agentctl __complete $argv[1] fish 2>/dev/null
end

function __agentctl_needs_command
    set -l t (commandline -opc)
    test (count $t) -eq 1
end

function __agentctl_using --argument-names cmds
    set -l t (commandline -opc)
    test (count $t) -ge 2; or return 1
    contains -- $t[2] (string split ' ' -- $cmds)
end

# number of positional (non-flag) arguments after the subcommand
function __agentctl_argc
    set -l t (commandline -opc)
    set -l n 0
    for a in $t[3..-1]
        string match -qr -- '^-' $a; or set n (math $n + 1)
    end
    echo $n
end

function __agentctl_arg_is --argument-names cmds n
    __agentctl_using $cmds; and test (__agentctl_argc) -eq $n
end

function __agentctl_set_is --argument-names setting n
    __agentctl_using set; and test (count (commandline -opc)) -ge 3; and test (commandline -opc)[3] = $setting; and test (__agentctl_argc) -eq $n
end

complete -c agentctl -f

# commands
complete -c agentctl -n __agentctl_needs_command -a new -d 'start an agent in a folder and attach'
complete -c agentctl -n __agentctl_needs_command -a attach -d 'show an agent in this terminal (ctrl-q detaches)'
complete -c agentctl -n __agentctl_needs_command -a ls -d 'list agents'
complete -c agentctl -n __agentctl_needs_command -a rm -d 'stop and forget an agent'
complete -c agentctl -n __agentctl_needs_command -a move -d 'move an agent to another position'
complete -c agentctl -n __agentctl_needs_command -a sessions -d 'look up Claude sessions by words'
complete -c agentctl -n __agentctl_needs_command -a resume -d 'continue a Claude session or ended agent'
complete -c agentctl -n __agentctl_needs_command -a sim -d 'simulated agents for demos'
complete -c agentctl -n __agentctl_needs_command -a web -d 'open the dashboard in the browser'
complete -c agentctl -n __agentctl_needs_command -a pair -d 'print the values the panel needs'
complete -c agentctl -n __agentctl_needs_command -a serve -d 'run the daemon'
complete -c agentctl -n __agentctl_needs_command -a install -d 'install and start the launchd agent'
complete -c agentctl -n __agentctl_needs_command -a restore -d 'bring back agents lost with the tmux server'
complete -c agentctl -n __agentctl_needs_command -a live -d 'Claude sessions started by hand in other terminals'
complete -c agentctl -n __agentctl_needs_command -a add -d 'put a hand-started Claude session on the deck'
complete -c agentctl -n __agentctl_needs_command -a reopen -d 'iTerm tabs for every agent no terminal shows'
complete -c agentctl -n __agentctl_needs_command -a hats -d 'the hats agents wear (one per working folder)'
complete -c agentctl -n __agentctl_needs_command -a accounts -d 'the Claude accounts agents run in'
complete -c agentctl -n __agentctl_needs_command -a handoff -d 'continue a Claude session in another account'
complete -c agentctl -n __agentctl_needs_command -a set -d 'change a setting (term, mouse, restore, hat)'
complete -c agentctl -n __agentctl_needs_command -a get -d 'show settings'
complete -c agentctl -n __agentctl_needs_command -a completion -d 'print the shell completion script'
complete -c agentctl -n __agentctl_needs_command -a version -d 'print the version'
complete -c agentctl -n __agentctl_needs_command -a help -d 'show usage'

# new
complete -c agentctl -n '__agentctl_using new' -s t -x -d title
complete -c agentctl -n '__agentctl_using new' -s c -x -a 'claude codex gemini shell' -d tool
complete -c agentctl -n '__agentctl_using new' -s a -x -a '(__agentctl_values accounts)' -d 'Claude account'
complete -c agentctl -n '__agentctl_using new' -s d -d 'start detached'
complete -c agentctl -n '__agentctl_arg_is new 0' -F -a '(__fish_complete_directories)'

# agents
complete -c agentctl -n '__agentctl_arg_is attach\ a\ rm\ move\ mv 0' -a '(__agentctl_values agents)'
complete -c agentctl -n '__agentctl_arg_is handoff 0' -a '(__agentctl_values agents)'
complete -c agentctl -n '__agentctl_arg_is handoff 1' -a '(__agentctl_values accounts)'

# accounts
complete -c agentctl -n '__agentctl_arg_is accounts\ account 0' -a 'add default rm'
complete -c agentctl -n '__agentctl_using accounts account; and test (__agentctl_argc) -eq 1; and contains -- (commandline -opc)[3] default rm' -a '(__agentctl_values accounts)'
complete -c agentctl -n '__agentctl_using accounts account; and test (__agentctl_argc) -eq 2; and test (commandline -opc)[3] = add' -a '(__fish_complete_directories)'
complete -c agentctl -n '__agentctl_using accounts account; and test (__agentctl_argc) -eq 3; and test (commandline -opc)[3] = add' -a 'teal blue yellow green purple pink sky ink'

# resume
complete -c agentctl -n '__agentctl_using resume continue' -l force -d 'resume even if it looks open elsewhere'
complete -c agentctl -n '__agentctl_using resume continue' -s d -d 'start detached'
complete -c agentctl -n '__agentctl_arg_is resume\ continue 0' -a '(__agentctl_values resumable)'

# sessions
complete -c agentctl -n '__agentctl_using sessions s' -s n -x -a '10 20 50 0' -d 'how many to show (0 = all)'

# sim
complete -c agentctl -n '__agentctl_arg_is sim 0' -a start -d 'start simulated agents'
complete -c agentctl -n '__agentctl_arg_is sim 0' -a stop -d 'remove all simulated agents'
complete -c agentctl -n '__agentctl_using sim' -l root -r -a '(__fish_complete_directories)' -d 'parent folder with projects'
complete -c agentctl -n '__agentctl_using sim' -l slots -x -a '4 8 12 16' -d 'how many agents'
complete -c agentctl -n '__agentctl_using sim' -l speed -x -a '0.5 1 1.5 2 3' -d 'activity speed'
complete -c agentctl -n '__agentctl_using sim' -l patience -x -a '30 45 90 -1' -d 'seconds before prompts self-answer, -1 never'

# pair, serve, completion
complete -c agentctl -n '__agentctl_using pair' -l rotate -d 'issue a new token'
complete -c agentctl -n '__agentctl_using serve' -l demo -d 'simulated fleet from the fixture'
complete -c agentctl -n '__agentctl_arg_is completion 0' -a 'zsh fish'

# set / get
complete -c agentctl -n '__agentctl_arg_is set 0' -a term -d 'how focus shows an agent'
complete -c agentctl -n '__agentctl_arg_is set 0' -a mouse -d 'who owns the mouse in agent terminals'
complete -c agentctl -n '__agentctl_arg_is set 0' -a restore -d 'what happens to agents lost with tmux'
complete -c agentctl -n '__agentctl_arg_is set 0' -a hat -d 'the hat of an agent working folder'
complete -c agentctl -n '__agentctl_set_is term 1' -a iterm -d 'select the agent iTerm tab and pane'
complete -c agentctl -n '__agentctl_set_is term 1' -a tmux -d 'switch your last-used tab to the agent'
complete -c agentctl -n '__agentctl_set_is term 1' -a window -d 'just raise the agent window'
complete -c agentctl -n '__agentctl_set_is restore 1' -a ask -d 'keep them for agentctl restore'
complete -c agentctl -n '__agentctl_set_is restore 1' -a auto -d 'bring them back right away'
complete -c agentctl -n '__agentctl_set_is mouse 1' -a tmux -d 'wheel scrolls tmux history, drag copies, click opens links'
complete -c agentctl -n '__agentctl_set_is mouse 1' -a native -d 'your terminal handles the mouse and its own scrollback'
complete -c agentctl -n '__agentctl_set_is hat 1' -a '(__agentctl_values agents)'
complete -c agentctl -n '__agentctl_set_is hat 1' -a '(__fish_complete_directories)'
complete -c agentctl -n '__agentctl_set_is hat 2' -a 'auto none hard-hat cap beanie helmet wizard beret chef crown headphones propeller top-hat cowboy bandana'
complete -c agentctl -n '__agentctl_set_is hat 3' -a 'teal blue yellow green purple pink sky ink'
complete -c agentctl -n '__agentctl_arg_is get 0' -a 'term mouse restore'
