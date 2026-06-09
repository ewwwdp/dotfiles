#!/usr/bin/env sh
MODE="${1:-default}"

case "$MODE" in
    default|vertical|both-vertical)
        ;;
    *)
        hyprctl notify -1 3000 "rgb(d20f39)" "Unknown monitor mode: $MODE"
        exit 1
        ;;
esac

MONITORS_LUA="$HOME/.config/hypr/config/monitors.lua"

sed -i "s/config\.monitors\.[a-z-]*/config.monitors.$MODE/" "$MONITORS_LUA"
hyprctl reload
hyprctl notify -1 3000 "rgb(40a02b)" "Monitor mode: $MODE"
