#!/usr/bin/env sh
SCREEN="$1"
WALLPAPER="$2"
BACKGROUNDS_JSON="${3:-$HOME/.dotfiles/.config/quickshell/df/config.json}"

if [ -z "$SCREEN" ] || [ -z "$WALLPAPER" ]; then
    exit 1
fi

if command -v jq >/dev/null 2>&1; then
    jq --arg s "$SCREEN" --arg w "$WALLPAPER" '.["wallpapers"][$s] = $w' "$BACKGROUNDS_JSON" > "${BACKGROUNDS_JSON}.tmp" && mv "${BACKGROUNDS_JSON}.tmp" "$BACKGROUNDS_JSON"
else
    sed -i "s/\"$SCREEN\": \"[^\"]*\"/\"$SCREEN\": \"$WALLPAPER\"/" "$BACKGROUNDS_JSON"
fi
