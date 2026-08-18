if command -v fish >/dev/null 2>&1; then
  eval "$(fish -lc '__emit_rn_android_env_sh' 2>/dev/null)"
fi

[ -f ~/.fzf.bash ] && source ~/.fzf.bash


# Added by Antigravity CLI installer
export PATH="/Users/rahul.bhatt/.local/bin:$PATH"
