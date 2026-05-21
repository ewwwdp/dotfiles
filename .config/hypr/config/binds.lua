local values = require("config.locals")
local mainMod = "SUPER"
local terminal = "alacritty"
local fileManager = "thunar"
local menu =
"app=$(wofi --show drun --define=drun-print_desktop_file=true | sed -E 's/(\\.desktop) /\\1:/'); [[ -n \"$app\" ]] && uwsm app -- \"$app\""
local barReload = "killall qs; " .. values.qs
local screenshot = "hyprshot"

-- Apps / system
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + C", hl.dsp.window.close())


hl.bind(mainMod .. " + SHIFT + END", hl.dsp.exit())
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))

hl.bind(
    mainMod .. " + V",
    hl.dsp.window.float({ action = "toggle" })
)

hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))

hl.bind(
    mainMod .. " + ALT + P",
    hl.dsp.window.pseudo()
)

hl.bind(
    mainMod .. " + P",
    hl.dsp.window.pin({ action = "toggle" })
)

hl.bind(
    mainMod .. " + J",
    hl.dsp.layout("togglesplit")
)

hl.bind(
    mainMod .. " + L",
    hl.dsp.exec_cmd("hyprlock")
)

-- Focus movement
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

-- Workspaces (1–9, 0 = 10)
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Relative workspace switching
hl.bind(
    mainMod .. " + ALT + right",
    hl.dsp.focus({ workspace = "r+1" })
)

hl.bind(
    mainMod .. " + ALT + left",
    hl.dsp.focus({ workspace = "r-1" })
)

-- Reload quickshell/bar
hl.bind(
    mainMod .. " + SHIFT + B",
    hl.dsp.exec_cmd(barReload)
)

-- Swap windows
hl.bind(mainMod .. " + SHIFT + left", hl.dsp.window.swap({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.swap({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + up", hl.dsp.window.swap({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + down", hl.dsp.window.swap({ direction = "down" }))

-- Resize active window
hl.bind(mainMod .. " + CTRL + left", hl.dsp.window.resize({ relative = true, x = -30, y = 0 }))
hl.bind(mainMod .. " + CTRL + right", hl.dsp.window.resize({ relative = true, x = 30, y = 0 }))
hl.bind(mainMod .. " + CTRL + up", hl.dsp.window.resize({ relative = true, x = 0, y = -30 }))
hl.bind(mainMod .. " + CTRL + down", hl.dsp.window.resize({ relative = true, x = 0, y = 30 }))

-- Screenshots
hl.bind(mainMod .. " + S", hl.dsp.exec_cmd(screenshot .. " -m window --clipboard-only"))

hl.bind(
    "PRINT",
    hl.dsp.exec_cmd(screenshot .. " -m output --clipboard-only")
)

hl.bind(
    mainMod .. " + SHIFT + S",
    hl.dsp.exec_cmd(screenshot .. " -m region --clipboard-only")
)

-- Clipboard terminal
hl.bind(
    mainMod .. " + SHIFT + V",
    hl.dsp.exec_cmd(terminal .. " --class " .. values.clipse .. " -e " .. values.clipse)
)

-- Window grouping
hl.bind(mainMod .. " + G", hl.dsp.group.toggle())
-- hl.bind(mainMod .. " + ALT + G", hl.dsp.window.move({ "out_of_group" }))

hl.bind(mainMod .. " + TAB", hl.dsp.group.next())
hl.bind(mainMod .. " + SHIFT + TAB", hl.dsp.group.prev())

-- Mouse drag/resize
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Audio
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"),
    { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
    { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
    { locked = true, repeating = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
    { locked = true, repeating = true })

-- Brightness
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl s +10%"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 10%-"), { locked = true, repeating = true })

-- Media keys
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
