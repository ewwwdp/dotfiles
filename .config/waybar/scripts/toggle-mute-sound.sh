#!/bin/bash

# Specify the sink (output) name
SINK="alsa_output.pci-0000_00_1f.3.analog-stereo"

# Toggle mute
pactl set-sink-mute "$SINK" $((1 - $(pactl list sinks | grep -A 15 "$SINK" | grep "Mute:" | grep -c "yes")))
