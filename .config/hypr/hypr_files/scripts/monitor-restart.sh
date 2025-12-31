#!/usr/bin/env bash

CONF="$HOME/.config/hypr/hypr_files/monitor.conf"
LINE=$(grep '^source *= *' "$CONF" | awk '{print $3}')

if [[ "$LINE" == *hdmi.conf ]]; then
    BROKEN="${LINE%.conf}.co"

    sed -i "s|$LINE|$BROKEN|" "$CONF"

    sleep 5
    sed -i "s|$BROKEN|$LINE|" "$CONF"

    hyprctl reload
fi
