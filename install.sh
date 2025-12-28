#!/bin/bash
set -e

echo "=== 1. INSTALLING HYPRLAND & ESSENTIALS ==="
# The critical desktop packages
sudo pacman -S --noconfirm hyprland sddm waybar rofi-wayland alacritty dunst swww \
    xdg-desktop-portal-hyprland xdg-desktop-portal-gtk \
    qt5-wayland qt6-wayland polkit-kde-agent \
    ttf-font-awesome ttf-jetbrains-mono-nerd \
    python-pywal libadwaita gnome-themes-extra

echo "=== 2. INSTALLING TEMPLATES ==="
mkdir -p ~/.config/wal/templates
# Copy verified templates (using -f to force overwrite)
cp -f ~/dotfiles/.config/wal/templates/* ~/.config/wal/templates/

echo "=== 3. CONFIGURING DARK MODE ==="
mkdir -p ~/.config/gtk-4.0
cat > ~/.config/gtk-4.0/settings.ini <<INI
[Settings]
gtk-application-prefer-dark-theme=1
gtk-theme-name=Adwaita-dark
gtk-icon-theme-name=Papirus
INI

echo "=== 4. ENABLING SERVICES ==="
# Ensure SDDM starts on boot
sudo systemctl enable sddm

echo "=== 5. GENERATING COLORS ==="
if [ -d "$HOME/dotfiles/wallpapers" ]; then
    WALLPAPER=$(find ~/dotfiles/wallpapers -type f \( -name "*.jpg" -o -name "*.png" \) | head -n 1)
    if [ -n "$WALLPAPER" ]; then
        echo "-> Generating colors from: $WALLPAPER"
        wal -i "$WALLPAPER"
    fi
fi

echo "=== INSTALL COMPLETE ==="
