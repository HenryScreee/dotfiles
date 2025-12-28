#!/bin/bash
set -e # Exit immediately if a command fails

echo "=== STARTING CLEAN INSTALL ==="

# 1. SETUP WAL TEMPLATES
echo "-> Installing Color Templates..."
# Create the config directory safely
mkdir -p ~/.config/wal/templates
# Copy the files from the repo to the config folder
# We use 'cp' instead of 'ln' to prevent symlink looping crashes
cp -f ~/dotfiles/.config/wal/templates/* ~/.config/wal/templates/

# 2. SETUP GTK / NAUTILUS
echo "-> Configuring Dark Mode..."
mkdir -p ~/.config/gtk-4.0
# Force dark mode file
cat > ~/.config/gtk-4.0/settings.ini <<INI
[Settings]
gtk-application-prefer-dark-theme=1
gtk-theme-name=Adwaita-dark
gtk-icon-theme-name=Papirus
INI

# 3. INITIALIZE COLORS
echo "-> Generating Colors..."
if [ -d "$HOME/dotfiles/wallpapers" ]; then
    # Grab the first image found
    WALLPAPER=$(find ~/dotfiles/wallpapers -type f \( -name "*.jpg" -o -name "*.png" \) | head -n 1)
    
    if [ -n "$WALLPAPER" ]; then
        echo "   Using wallpaper: $WALLPAPER"
        wal -i "$WALLPAPER"
    else
        echo "   [!] No wallpaper found in ~/dotfiles/wallpapers."
    fi
else
    echo "   [!] Wallpaper folder missing."
fi

echo "=== INSTALL COMPLETE ==="
echo "Please reboot your system."
