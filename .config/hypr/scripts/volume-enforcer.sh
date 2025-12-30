#!/bin/bash

while true; do
    # 1. Get a list of all current audio stream IDs
    # (pactl list short returns: ID SINK PROTOCOL ...)
    for id in $(pactl list sink-inputs short | cut -f1); do
        
        # 2. Check if this specific ID belongs to Firefox
        # We query the details for this ID and grep for the name
        if pactl list sink-inputs | grep -A 20 "Sink Input #$id" | grep -i "firefox" > /dev/null; then
            
            # 3. Found it! Force it to 100% (65536)
            # We also unmute it just in case.
            pactl set-sink-input-mute "$id" 0
            pactl set-sink-input-volume "$id" 100%
        fi
    done

    # Check again every second
    sleep 1
done
