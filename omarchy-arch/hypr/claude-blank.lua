-- Black screen for overnight Claude sessions: any key/mouse wakes it, no password.
-- See bin/claude-lid-keepalive. Loaded from ~/.config/hypr/bindings.lua.
o.bind("SUPER + CTRL + D", "Black screen (Claude)", os.getenv("HOME") .. "/.local/bin/claude-lid-keepalive blank")
