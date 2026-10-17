function wakeup --description "Start-of-day setup: mirror displays, launch Teams/Arc/Ghostty/Cursor"
    display mirror

    open -a "Microsoft Teams"
    open -a "Arc"
    open -a "Ghostty"
    open -a "Cursor"
end
