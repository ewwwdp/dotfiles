#!/bin/bash

# Specify the source name
SOURCE="alsa_input.pci-0000_00_1f.3.analog-stereo"

# Toggle mute
pactl set-source-mute "$SOURCE" $((1 - $(pactl list sources | grep -A 15 "$SOURCE" | grep "Mute:" | grep -c "yes")))
