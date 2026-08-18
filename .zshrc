if command -v fish >/dev/null 2>&1; then
  eval "$(fish -lc '__emit_rn_android_env_sh' 2>/dev/null)"
fi

export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh" # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" # This loads nvm bash_completion

alias claude-mem='/Users/rahul.bhatt/.bun/bin/bun "/Users/rahul.bhatt/.claude/plugins/cache/thedotmack/claude-mem/10.6.2/scripts/worker-service.cjs"'

# asdf shims for per-project tool versions
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh


# Added by Antigravity CLI installer
export PATH="/Users/rahul.bhatt/.local/bin:$PATH"
