-- Enable IPC (allows `hs` CLI to talk to the running instance)
require("hs.ipc")

-- Window focus dimmer
-- Active window: full opacity. All others: dimmed.
-- Tweak INACTIVE_ALPHA for more/less dimming (0.7 = 30% dim, 0.85 = 15% dim).

local INACTIVE_ALPHA = 0.85
local ACTIVE_ALPHA   = 1.0

-- Apps whose windows should never be dimmed (overlays, system UI, etc.)
local SKIP_APPS = {
    ["Hammerspoon"]         = true,
    ["Notification Center"] = true,
}

local function setAlpha(win, alpha)
    if not win then return end
    -- silently ignore windows that don't support alpha (e.g. some system panels)
    pcall(function() win:setAlpha(alpha) end)
end

local function refreshAll()
    local focused = hs.window.focusedWindow()
    for _, win in ipairs(hs.window.visibleWindows()) do
        local appName = win:application() and win:application():name() or ""
        if SKIP_APPS[appName] then
            setAlpha(win, ACTIVE_ALPHA)
        elseif win == focused then
            setAlpha(win, ACTIVE_ALPHA)
        else
            setAlpha(win, INACTIVE_ALPHA)
        end
    end
end

local wf = hs.window.filter.new(nil)
    :setOverrideFilter({ visible = true, allowRoles = '*' })

wf:subscribe({
    hs.window.filter.windowFocused,
    hs.window.filter.windowUnfocused,
    hs.window.filter.windowVisible,
    hs.window.filter.windowNotVisible,
}, refreshAll)

refreshAll()

hs.alert.show("Focus dimmer active (" .. math.floor((1 - INACTIVE_ALPHA) * 100) .. "% dim)")
