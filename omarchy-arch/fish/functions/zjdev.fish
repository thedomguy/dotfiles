function zjdev
    set layout_file (mktemp)
    echo "layout {
        pane split_direction=\"vertical\" {
            pane {
                name \"MAIN\"
            }
            pane size=60 {
                name \"SIDE\"
            }
        }
    }" > $layout_file
    zellij --layout $layout_file
    rm $layout_file
end

