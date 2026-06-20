-- @meta icon=f0c51 label=Both
hl.monitor({
    output = "HDMI-A-1",
    mode = "1920x1080@200.00",
    position = "0x0",
    scale = 1,
})

hl.monitor({
    output = "DP-1",
    mode = "1920x1080@60.00",
    position = "1920x-600",
    disabled = false,
    scale = 1,
    transform = 3,
})
