function toggle_refresh
    # Check if displayplacer is installed
    if not command -v displayplacer > /dev/null
        echo "Error: displayplacer is not installed"
        return 1
    end

    # Get current display settings
    set -l display_info (displayplacer list)

    # Check if external display exists by looking for the specific ID
    if not string match -q "*0B5D5DDC-FE0D-1FFC-6BD9-59D498C4642E*" "$display_info"
        echo "External display not detected"
        return 1
    end

    # Extract current refresh rate using string match
    if string match -q "*Hertz: 60*" "$display_info"
        # Currently at 60Hz, switch to 75Hz
        displayplacer "id:0B5D5DDC-FE0D-1FFC-6BD9-59D498C4642E res:2560x1080 hz:75 color_depth:8 enabled:true scaling:off origin:(0,0) degree:0" "id:60AAAF15-1461-8013-C747-00F04537856E res:1792x1120 hz:59 color_depth:8 enabled:true scaling:on origin:(-1792,223) degree:0"
        echo "Switched to 75Hz"
    else if string match -q "*Hertz: 75*" "$display_info"
        # Currently at 75Hz, switch to 60Hz
        displayplacer "id:0B5D5DDC-FE0D-1FFC-6BD9-59D498C4642E res:2560x1080 hz:60 color_depth:8 enabled:true scaling:off origin:(0,0) degree:0" "id:60AAAF15-1461-8013-C747-00F04537856E res:1792x1120 hz:59 color_depth:8 enabled:true scaling:on origin:(-1792,223) degree:0"
        echo "Switched to 60Hz"
    else
        echo "Unable to determine current refresh rate"
        return 1
    end
end
