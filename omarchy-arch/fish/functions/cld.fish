function cld --wraps='claude -p "/usage" | grep "Current session"' --wraps='echo "Checking claude usage" && claude -p "/usage" | grep "Current session"' --wraps='echo "Checking claude usage..." && claude -p "/usage" | grep "Current session"' --description 'alias cld=echo "Checking claude usage..." && claude -p "/usage" | grep "Current session"'
    echo "Checking claude usage..." && claude -p "/usage" | grep "Current session" $argv
end
