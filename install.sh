#!/bin/bash
set -e

echo "=== 1. INSTALLING PACKAGES ==="
# We MUST install pywal before we can use it!
# We also ensure other core tools are present.
sudo pacman -S --noconfirm python-pywal libadwaita xdg-desktop-portal-gtk gnome-themes-extra

echo "=== 2. INSTALLING TEMPLATES ==="
# Create the directory
mkdir -p ~/.config/wal/templates
# Copy the verified static templates from the repo
cp -f ~/dotfiles/.config/wal/templates/* ~/.config/wal/templates/

echo "=== 3. CONFIGURING DARK MODE ==="
mkdir -p ~/.config/gtk-4.0
cat > ~/.config/gtk-4.0/settings.ini <<INI
[Settings]
gtk-application-prefer-dark-theme=1
gtk-theme-name=Adwaita-dark
gtk-icon-theme-name=Papirus
INI

echo "=== 4. GENERATING COLORS ==="
# Now that 'wal' is installed, this command will actually work
if [ -d "$HOME/dotfiles/wallpapers" ]; then
    WALLPAPER=$(find ~/dotfiles/wallpapers -type f \( -name "*.jpg" -o -name "*.png" \) | head -n 1)
    if [ -n "$WALLPAPER" ]; then
        echo "-> Generating colors from: $WALLPAPER"
        wal -i "$WALLPAPER"
    else
        echo "-> Warning: No wallpapers found."
    fi
fi

echo "=== DONE! REBOOT NOW. ==="
