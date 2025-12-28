#!/bin/bash
set -e

echo "=== 1. INSTALLING YAY (AUR HELPER) ==="
# We need git and base-devel to compile yay
sudo pacman -S --noconfirm git base-devel

# Clone and build yay
if ! command -v yay &> /dev/null; then
    echo "-> Building yay..."
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ..
    rm -rf yay
else
    echo "-> Yay is already installed."
fi

echo "=== 2. INSTALLING PACKAGES ==="
# Added: nautilus, fish, firefox, grimblast
# We use yay here just in case, but pacman works for these too
yay -S --noconfirm hyprland sddm waybar rofi-wayland alacritty dunst swww \
    xdg-desktop-portal-hyprland xdg-desktop-portal-gtk \
    qt5-wayland qt6-wayland polkit-kde-agent \
    ttf-font-awesome ttf-jetbrains-mono-nerd \
    python-pywal libadwaita gnome-themes-extra \
    nautilus fish firefox grimblast

echo "=== 3. INSTALLING CONFIGS ==="
mkdir -p ~/.config
# Copy ALL dotfiles to system config (Force overwrite)
cp -rf ~/dotfiles/.config/* ~/.config/

echo "=== 4. SETUP TEMPLATES & DARK MODE ==="
mkdir -p ~/.config/wal/templates
mkdir -p ~/.config/gtk-4.0

# Enforce Dark Mode
cat > ~/.config/gtk-4.0/settings.ini <<INI
[Settings]
gtk-application-prefer-dark-theme=1
gtk-theme-name=Adwaita-dark
gtk-icon-theme-name=Papirus
INI

echo "=== 5. ENABLING SERVICES ==="
sudo systemctl enable sddm

echo "=== 6. GENERATING COLORS ==="
if [ -d "$HOME/dotfiles/wallpapers" ]; then
    WALLPAPER=$(find ~/dotfiles/wallpapers -type f \( -name "*.jpg" -o -name "*.png" \) | head -n 1)
    if [ -n "$WALLPAPER" ]; then
        echo "-> Generating colors from: $WALLPAPER"
        wal -i "$WALLPAPER"
    fi
fi

echo "=== INSTALL COMPLETE ==="
