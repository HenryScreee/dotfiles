#!/bin/bash

# --- 1. FIX NAUTILUS (Undo the broken symlinks) ---
echo "Fixing Nautilus..."
# Remove the forced CSS that caused white-on-white
rm -rf ~/.config/gtk-4.0
mkdir -p ~/.config/gtk-4.0

# Create a clean settings file that forces Dark Mode natively
cat > ~/.config/gtk-4.0/settings.ini <<INI
[Settings]
gtk-application-prefer-dark-theme=1
gtk-cursor-theme-name=Posy_Cursor
gtk-icon-theme-name=Papirus
INI

# Force Libadwaita to Dark Mode (The "Modern" Way)
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"

# --- 2. FIX CURSOR (The "Search & Rescue" Method) ---
echo "Fixing Cursor..."
TARGET="$HOME/.icons/Posy_Cursor"

# If the folder exists, check for nesting
if [ -d "$TARGET" ]; then
    # If index.theme is NOT in the top level, find it
    if [ ! -f "$TARGET/index.theme" ]; then
        FOUND=$(find "$TARGET" -name "index.theme" | head -n 1)
        if [ -n "$FOUND" ]; then
            # We found the real files nested deeper. Move them up.
            REAL_DIR=$(dirname "$FOUND")
            echo "Found cursor files at: $REAL_DIR"
            cp -r "$REAL_DIR"/* "$TARGET/"
            rm -rf "$TARGET/Posy_Cursor" 2>/dev/null
        fi
    fi
fi

# Re-apply cursor settings
gsettings set org.gnome.desktop.interface cursor-theme 'Posy_Cursor'
hyprctl setcursor Posy_Cursor 24
echo "Visuals Repaired."
