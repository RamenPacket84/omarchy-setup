-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- SUPER+F was fullscreen. Tiled fullscreen remains on SUPER+CTRL+F.
hl.unbind("SUPER + F")
o.bind("SUPER + F", "File manager", { omarchy = "nautilus" })

-- Default browser (Brave Origin).
o.bind("SUPER + B", "Browser", { omarchy = "browser" })

-- SUPER+X was universal cut (Ctrl+X).
hl.unbind("SUPER + X")
o.bind("SUPER + X", "X", { webapp = "https://x.com/" })

o.bind("SUPER + Y", "YouTube", { webapp = "https://youtube.com/" })

-- SUPER+RETURN already launches the default terminal (Ghostty) via Omarchy.

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")
