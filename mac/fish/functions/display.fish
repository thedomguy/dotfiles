function display --description "Switch display layout: extend | mirror | retina | status | log"
    # Screen IDs (persistent):
    #   ULTRA1  = DE8080FB  — Samsung G5 Odyssey 3440x1440 @ 165Hz (main)
    #   MACBOOK = 37D8832A  — 14" MacBook built-in
    #   ULTRA2  = 58761370  — LG 34" 2560x1080 @ 75Hz (above)
    set ULTRA1     "DE8080FB-E78E-4446-A049-494CCC4D6C61"
    set MB         "37D8832A-2D66-02CA-B9F7-8F30A301B230"
    set ULTRA2     "58761370-D24D-45D0-8A87-24945FF477AD"
    set BRIGHTNESS /Users/rahul.bhatt/personal/dotfiles/mac/scripts/macbook-brightness.py
    set LOGFILE    /tmp/display-brightness.log
    # Saved brightness persists across mirror→extend so extend always restores correctly
    set MB_SAVE    /tmp/display-mb-brightness
    set DDC_SAVE   /tmp/display-ddc-brightness

    set dp_list (displayplacer list 2>/dev/null)
    set has_ultra1 (echo $dp_list | grep -q $ULTRA1 && echo 1 || echo 0)
    set has_ultra2 (echo $dp_list | grep -q $ULTRA2 && echo 1 || echo 0)
    set MC_DOMAIN  app.monitorcontrol.MonitorControl

    function __log_brightness -a label
        set mb_val  (python3 $argv[2] get 2>/dev/null; or echo "n/a")
        set ddc_val (m1ddc get luminance 2>/dev/null; or echo "n/a")
        printf '[%s] %-12s  MacBook: %-6s  Samsung DDC: %s/100\n' \
            (date '+%H:%M:%S') $label $mb_val $ddc_val \
            | tee -a $argv[3]
    end

    # Saves the current levels so `extend` can restore them. Skips values that
    # are already dimmed, so a repeat call never overwrites a good save with 0.
    function __save_brightness -a brightness mb_save ddc_save
        set mb_cur (python3 $brightness get 2>/dev/null)
        if python3 -c "exit(0 if float('$mb_cur') > 0.01 else 1)" 2>/dev/null
            echo $mb_cur > $mb_save
        end
        set ddc_cur (m1ddc get luminance 2>/dev/null)
        if test "$ddc_cur" -gt 1 2>/dev/null
            echo $ddc_cur > $ddc_save
        end
    end

    # Mirror's brightness state: MacBook at 0, Samsung at its saved level.
    # Sync stays off. Re-enabling it would let MC see the mismatch and dim
    # Samsung; `display extend` restores it once brightness is back to normal.
    function __dim_mb -a brightness ddc_save mc_domain
        defaults write $mc_domain enableBrightnessSync -bool false
        python3 $brightness set 0
        m1ddc set luminance (cat $ddc_save) >/dev/null 2>&1
    end

    # Detects the live layout so extend/mirror/retina can skip a switch
    # that's already in place. Mirror and retina both drive the ULTRA1+MB
    # pair as a mirrored bundle (same origin) — the resolution tells them
    # apart: retina drives at the MacBook's native 1728x1080, mirror drives
    # at the ultrawide's 3440x1440.
    #
    # Callers must pass dp_list as `(string join \n -- $dp_list | string collect)`,
    # not the bare list var: fish re-splits command substitutions on
    # newlines even when captured into one string, so without `string
    # collect` it arrives here as many positional args instead of one
    # blob — and without `string join \n` first, `echo $dp_list` inside
    # this function joins list elements with spaces, destroying the line
    # structure `grep -A5` needs to isolate a screen's block.
    function __display_mode -a dp_list has_ultra1
        if test $has_ultra1 -eq 0
            echo macbook-only
            return
        end
        set u1_origin (echo $dp_list | grep -A5 "s809841995" | grep "Origin" | string match -r '\(.*?\)')
        set mb_origin (echo $dp_list | grep -A5 "s4251086178" | grep "Origin" | string match -r '\(.*?\)')
        if test "$u1_origin" != "$mb_origin"
            echo extend
            return
        end
        set mb_res (echo $dp_list | grep -A5 "s4251086178" | grep "Resolution" | string match -r '\d+x\d+')
        if test "$mb_res" = "1728x1080"
            echo retina
        else
            echo mirror
        end
    end

    switch $argv[1]
        case extend
            set -l mode (__display_mode (string join \n -- $dp_list | string collect) $has_ultra1)
            if test "$mode" = extend
                echo "Already in extend — nothing to do"
                return 0
            end
            if test $has_ultra1 -eq 1
                echo "Switching to: extend (all connected displays)"
                __log_brightness "extend PRE" $BRIGHTNESS $LOGFILE

                # Restore from saved file (written by mirror) so we always get back
                # to the pre-mirror level, not whatever the current dimmed state is
                if test -f $MB_SAVE
                    set mb_target (cat $MB_SAVE)
                else
                    set mb_target (python3 $BRIGHTNESS get 2>/dev/null)
                end
                if test -f $DDC_SAVE
                    set ddc_target (cat $DDC_SAVE)
                else
                    set ddc_target (m1ddc get luminance 2>/dev/null)
                end

                set dp_args \
                    "id:$ULTRA1 res:3440x1440 hz:165 color_depth:8 enabled:true scaling:off origin:(0,0) degree:0" \
                    "id:$MB res:1728x1080 hz:120 color_depth:8 enabled:true scaling:on origin:(-1728,165) degree:0"
                test $has_ultra2 -eq 1; and set dp_args $dp_args \
                    "id:$ULTRA2 res:2560x1080 hz:75 color_depth:8 enabled:true scaling:off origin:(406,-1080) degree:0"
                # Sync may already be disabled (coming from mirror) — ensure it's off
                # during the switch, restore brightness, then re-enable so MC sees no mismatch
                defaults write $MC_DOMAIN enableBrightnessSync -bool false
                displayplacer $dp_args
                sleep 0.5
                python3 $BRIGHTNESS set $mb_target
                m1ddc set luminance $ddc_target >/dev/null 2>&1
                # Both displays now at target levels — safe to re-enable sync
                defaults write $MC_DOMAIN enableBrightnessSync -bool true
                __log_brightness "extend POST" $BRIGHTNESS $LOGFILE
            else
                echo "No external displays connected — MacBook only"
                displayplacer "id:$MB res:1728x1080 hz:120 color_depth:8 enabled:true scaling:on origin:(0,0) degree:0"
            end

        case mirror
            set -l mode (__display_mode (string join \n -- $dp_list | string collect) $has_ultra1)
            if test $has_ultra1 -eq 1
                # Layout and brightness are separate: macOS can restore the
                # mirrored layout (login, wake) but relight the built-in panel,
                # so only the layout switch is skipped when already mirrored.
                if test "$mode" = mirror
                    echo "Already in mirror — making sure the MacBook panel is dimmed"
                else
                    echo "Switching to: mirror (MacBook + ultrawide mirrored)"
                end
                __log_brightness "mirror PRE" $BRIGHTNESS $LOGFILE

                __save_brightness $BRIGHTNESS $MB_SAVE $DDC_SAVE

                # Sync off before the switch so MC doesn't react to it mid-way
                defaults write $MC_DOMAIN enableBrightnessSync -bool false
                if test "$mode" != mirror
                    displayplacer "id:$ULTRA1+$MB res:3440x1440 hz:165 color_depth:8 enabled:true scaling:off origin:(0,0) degree:0"
                    sleep 0.5
                end
                __dim_mb $BRIGHTNESS $DDC_SAVE $MC_DOMAIN
                __log_brightness "mirror POST" $BRIGHTNESS $LOGFILE
            else
                echo "Main ultrawide not connected — nothing to mirror to"
                return 1
            end

        case retina
            set -l mode (__display_mode (string join \n -- $dp_list | string collect) $has_ultra1)
            if test "$mode" = retina
                echo "Already in retina — nothing to do"
                return 0
            end
            echo "Switching to: retina only (MacBook primary, externals mirrored)"
            __log_brightness "retina PRE" $BRIGHTNESS $LOGFILE
            python3 $BRIGHTNESS get 2>/dev/null > $MB_SAVE
            m1ddc get luminance 2>/dev/null > $DDC_SAVE

            # Mirror externals rather than disabling — cutting DP signal sends monitors
            # into deep standby requiring physical power button press to recover.
            defaults write $MC_DOMAIN enableBrightnessSync -bool false
            if test $has_ultra1 -eq 1
                displayplacer "id:$MB+$ULTRA1 res:1728x1080 hz:120 color_depth:8 enabled:true scaling:on origin:(0,0) degree:0"
            else
                displayplacer "id:$MB res:1728x1080 hz:120 color_depth:8 enabled:true scaling:on origin:(0,0) degree:0"
            end
            sleep 0.5
            python3 $BRIGHTNESS set (cat $MB_SAVE)
            m1ddc set luminance (cat $DDC_SAVE) >/dev/null 2>&1
            defaults write $MC_DOMAIN enableBrightnessSync -bool true
            __log_brightness "retina POST" $BRIGHTNESS $LOGFILE

        case status
            switch (__display_mode (string join \n -- $dp_list | string collect) $has_ultra1)
                case retina
                    echo "Current mode: retina (MacBook native, externals mirrored)"
                case mirror
                    echo "Current mode: mirror"
                case extend
                    echo "Current mode: extend"
                case macbook-only
                    echo "Current mode: MacBook only (no externals connected)"
            end
            string join \n -- $dp_list | grep -E "^(Type|Resolution|Origin|Enabled):"
            echo ""
            set mb_now  (python3 $BRIGHTNESS get 2>/dev/null)
            set ddc_now (m1ddc get luminance 2>/dev/null)
            echo "Brightness — MacBook: $mb_now  Samsung DDC: $ddc_now/100"

        case log
            if test -f $LOGFILE
                cat $LOGFILE
            else
                echo "No brightness log yet — run extend/mirror/retina first"
            end

        case '*'
            echo "Usage: display [extend|mirror|retina|status|log]"
            echo ""
            echo "  extend  — all connected displays extended"
            echo "  mirror  — MacBook + main ultrawide mirrored, retina dims to 0"
            echo "  retina  — MacBook only (externals mirrored to it)"
            echo "  status  — show current layout + live brightness"
            echo "  log     — brightness log for this session"
    end
end
