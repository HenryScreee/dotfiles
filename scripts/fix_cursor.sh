#!/bin/bash
TARGET="$HOME/.icons/Posy_Cursor"
if [ -d "$TARGET/Posy_Cursor" ]; then
    mv "$TARGET/Posy_Cursor"/* "$TARGET/"
    rmdir "$TARGET/Posy_Cursor"
fi
# Force update icon cache
gtk-update-icon-cache ~/.icons/Posy_Cursor
echo "Cursor Fixed."
