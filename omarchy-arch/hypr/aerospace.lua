-- AeroSpace (macOS) shortcuts ported to Hyprland. Same ALT-based keys; Omarchy's
-- SUPER bindings are left untouched. Loaded from ~/.config/hypr/bindings.lua.

-- Omarchy binds ALT+TAB to window cycling; AeroSpace uses it for workspace back-and-forth.
hl.unbind("ALT + TAB")
hl.unbind("ALT + SHIFT + TAB")

-- Layout: alt-slash (tiles) / alt-comma (accordion)
o.bind("ALT + SLASH", "Toggle split direction", hl.dsp.layout("togglesplit"))
o.bind("ALT + COMMA", "Toggle workspace layout", "omarchy-hyprland-workspace-layout-toggle")

-- Focus: alt-hjkl
o.bind("ALT + H", "Focus left", hl.dsp.focus({ direction = "l" }))
o.bind("ALT + J", "Focus down", hl.dsp.focus({ direction = "d" }))
o.bind("ALT + K", "Focus up", hl.dsp.focus({ direction = "u" }))
o.bind("ALT + L", "Focus right", hl.dsp.focus({ direction = "r" }))

-- Move window: alt-shift-hjkl
o.bind("ALT + SHIFT + H", "Move window left", hl.dsp.window.swap({ direction = "l" }))
o.bind("ALT + SHIFT + J", "Move window down", hl.dsp.window.swap({ direction = "d" }))
o.bind("ALT + SHIFT + K", "Move window up", hl.dsp.window.swap({ direction = "u" }))
o.bind("ALT + SHIFT + L", "Move window right", hl.dsp.window.swap({ direction = "r" }))

-- Resize: alt-minus / alt-equal (small), with shift (large)
o.bind("ALT + MINUS", "Shrink window", hl.dsp.window.resize({ x = -50, y = 0, relative = true }))
o.bind("ALT + EQUAL", "Grow window", hl.dsp.window.resize({ x = 50, y = 0, relative = true }))
o.bind("ALT + SHIFT + MINUS", "Shrink window a lot", hl.dsp.window.resize({ x = -300, y = 0, relative = true }))
o.bind("ALT + SHIFT + EQUAL", "Grow window a lot", hl.dsp.window.resize({ x = 300, y = 0, relative = true }))

-- Workspaces: alt-1..0 focus, alt-shift-1..0 move window
for workspace = 1, 10 do
  local key = "code:" .. tostring(workspace + 9)
  o.bind("ALT + " .. key, "Switch to workspace " .. workspace, hl.dsp.focus({ workspace = tostring(workspace) }))
  o.bind("ALT + SHIFT + " .. key, "Move window to workspace " .. workspace, hl.dsp.window.move({ workspace = tostring(workspace) }))
end

-- alt-tab: workspace back-and-forth; alt-shift-tab: move workspace to next monitor
o.bind("ALT + TAB", "Former workspace", hl.dsp.focus({ workspace = "previous" }))
o.bind("ALT + SHIFT + TAB", "Move workspace to next monitor", hl.dsp.workspace.move({ monitor = "+1" }))

-- App launchers (alt-b/g/f/o)
o.bind("ALT + B", "Browser", { omarchy = "browser" })
o.bind("ALT + G", "Terminal", { omarchy = "terminal" })
o.bind("ALT + F", "File manager", { omarchy = "nautilus" })
o.bind("ALT + O", "Obsidian", "obsidian")
