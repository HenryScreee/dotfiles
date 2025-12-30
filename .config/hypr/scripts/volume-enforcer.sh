#!/bin/bash

# Infinite loop to police volume
while true; do
    # Find all audio inputs belonging to Firefox
    # We use 'pactl' to list them, find the ID, and force volume to 100% (65536 is 100% in integer math, or just use 100%)
    
    pactl list sink-inputs short | grep -i "firefox" | cut -f1 | while read -r id; do
        # Mute status: Unmute it
        pactl set-sink-input-mute "$id" 0
        # Volume status: Force to 100%
        pactl set-sink-input-volume "$id" 100%
    done
    
    # Wait 1 second before checking again
    sleep 1
done
