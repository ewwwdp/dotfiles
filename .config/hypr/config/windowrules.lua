hl.window_rule({
	name = "suppress-maximize-events",
	match = {
		class = ".*",
	},
	suppress_event = "maximize",
})

hl.window_rule({
	name = "fix-xwayland-drags",
	match = {
		class = "^$",
		title = "^$",
		xwayland = true,
		float = true,
		fullscreen = false,
		pin = false,
	},
	no_focus = true,
})

hl.window_rule({
	name = "telegram_discord",
	match = {
		class = "(org.telegram.desktop|discord|vesktop)",
	},
	float = true,
	size = "monitor_w*0.7 monitor_h*0.8",
	center = true,
	workspace = 4,
})

hl.window_rule({
	name = "clipse",
	match = {
		class = "(clipse)",
	},
	float = true,
	center = true,
	size = "622 652",
})

hl.window_rule({
	name = "gtk",
	match = {
		class = "(xdg-desktop-portal-gtk)",
	},
	float = true,
	center = true,
	size = "monitor_w*0.7 monitor_h*0.8",
})

hl.window_rule({
	name = "tray_items_1",
	match = {
		class = "^(pavucontrol|org.pulseaudio.pavucontrol|com.saivert.pwvucontrol|nm-applet|nm-connection-editor|blueman-manager|com.network.manager)$",
	},
	float = true,
	size = "497 371",
	move = "monitor_w-window_w-20 30",
})
