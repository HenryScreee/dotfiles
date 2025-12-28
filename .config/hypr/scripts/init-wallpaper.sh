#!/bin/bash

# 1. Kill any existing wallpaper daemons to prevent conflicts
pkill swww-daemon

# 2. Start the daemon in the background
swww-daemon &

# 3. Wait for it to initialize (Crucial Step!)
sleep 1

# 4. Apply the wallpaper
# If pywal has run before, use the last cached image.
# Otherwise, find the first image in the wallpapers folder.
if [ -f "$HOME/.cache/wal/wal" ]; then
    swww img "$(cat $HOME/.cache/wal/wal)" --transition-type any
else
    # Fallback: Find the first wallpaper in the folder
    FIRST_WALL=$(find $HOME/dotfiles/wallpapers -type f \( -name "*.jpg" -o -name "*.png" \) | head -n 1)
    if [ -n "$FIRST_WALL" ]; then
        wal -i "$FIRST_WALL"
        swww img "$FIRST_WALL" --transition-type any
    fi
fi
