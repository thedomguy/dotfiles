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

# >>> iom-prima-word-smart-doc >>>
# One-shot alias for Word Smart Document servers (script lives in .local).
export IOM_WSD_SPAWN="/Users/rahul.bhatt/work/iom-prima/.local/word-smart-doc/spawn.sh"
alias wsd="$IOM_WSD_SPAWN"
_iom_wsd_chpwd() {
  case "$PWD/" in
    /Users/rahul.bhatt/work/iom-prima/.worktrees/*)
      alias wsd-up="$IOM_WSD_SPAWN up"
      alias wsd-down="$IOM_WSD_SPAWN down"
      alias wsd-status="$IOM_WSD_SPAWN status"
      ;;
    *)
      unalias wsd-up wsd-down wsd-status 2>/dev/null || true
      ;;
  esac
}
autoload -Uz add-zsh-hook
add-zsh-hook chpwd _iom_wsd_chpwd
_iom_wsd_chpwd
# <<< iom-prima-word-smart-doc <<<
