function fish_user_key_bindings
  fzf --fish | source
  # Accept autosuggestion with Ctrl+J (same as right arrow)
  bind \cj forward-char
end
