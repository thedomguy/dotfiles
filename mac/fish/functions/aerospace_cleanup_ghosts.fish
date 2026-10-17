function aerospace_cleanup_ghosts
    aerospace list-windows --all | while read -l window_info
        set -l window_id (echo $window_info | awk '{print $1}')
        if not kill -0 (aerospace list-windows --all | grep "^$window_id " | awk '{print $3}') > /dev/null 2>&1
            echo "Closing ghost window: $window_info"
            aerospace focus --window-id $window_id
            aerospace close
        end
    end
end
