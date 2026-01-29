MODE="$1"
CONF="$HOME/.config/hypr/hypr_files/monitor.conf"
NEW_CONF="$HOME/.config/hypr/hypr_files/monitors/${MODE}.conf"


if [ ! -f "$NEW_CONF" ]; then
    echo "Error: Configuration file $NEW_CONF does not exist"
    exit 1
fi

LINE=$(grep '^source *= *' "$CONF" | awk '{print $3}')

if [ -z "$LINE" ]; then
    echo "Error: Could not find source line in $CONF"
    exit 1
fi

sed -i "s|$LINE|$NEW_CONF|" "$CONF"
hyprctl reload
