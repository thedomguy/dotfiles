#!/bin/bash
# Configure Jiggler (Stick Software) to keep the Mac awake once it has been
# idle for 2 minutes. Jiggler handles the idle detection itself: with
# JiggleOnlyWhenIdle on, it jiggles only after JiggleSeconds of no input, and
# stops as soon as you touch the mouse or keyboard.

IDLE_SECONDS="${1:-120}"

defaults write com.stick.app.jiggler JiggleMasterSwitch -bool true
defaults write com.stick.app.jiggler JiggleOnlyWhenIdle -bool true
defaults write com.stick.app.jiggler JiggleSeconds -int "$IDLE_SECONDS"

# Jiggler reads its prefs at launch, so restart it.
osascript -e 'quit app "Jiggler"' 2>/dev/null
while pgrep -x Jiggler >/dev/null; do sleep 0.2; done
open -a Jiggler
