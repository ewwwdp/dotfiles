require("config.env")
require("config.autostart")
require("config.monitor")
require("config.input")
require("config.binds")
require("config.look")
require("config.windowrules")

hl.config({
    misc = {
        force_default_wallpaper = -1,
        disable_hyprland_logo = true,
        middle_click_paste = false
    },
    ecosystem = {
        no_update_news = true,
        no_donation_nag = true
    }
})
