local values = require("config.locals")

hl.on("hyprland.start", function()
    hl.exec_cmd(values.qs)
    hl.exec_cmd(values.clipse .. " -listen")
end)
