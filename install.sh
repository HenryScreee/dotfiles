#!/bin/bash
set -e

echo "=== 1. INSTALLING PACKAGES ==="
sudo pacman -S --noconfirm hyprland sddm waybar rofi-wayland alacritty dunst swww \
    xdg-desktop-portal-hyprland xdg-desktop-portal-gtk \
    qt5-wayland qt6-wayland polkit-kde-agent \
    ttf-font-awesome ttf-jetbrains-mono-nerd \
    python-pywal libadwaita gnome-themes-extra

echo "=== 2. INSTALLING CONFIGS ==="
# Create the config folder
mkdir -p ~/.config
# Copy ALL dotfiles (Hyprland, Waybar, etc.) to the system
# We use -rf to overwrite default configs
cp -rf ~/dotfiles/.config/* ~/.config/

echo "=== 3. SETUP TEMPLATES & DARK MODE ==="
# (These files were copied in step 2, but we ensure the directories exist)
mkdir -p ~/.config/wal/templates
mkdir -p ~/.config/gtk-4.0

# Enforce Dark Mode for GTK4
cat > ~/.config/gtk-4.0/settings.ini <<INI
[Settings]
gtk-application-prefer-dark-theme=1
gtk-theme-name=Adwaita-dark
gtk-icon-theme-name=Papirus
INI

echo "=== 4. ENABLING SERVICES ==="
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
