#!/bin/bash
set -e

echo "=== 1. PREPARING SYSTEM (Multilib & YAY) ==="
# Enable Multilib (Required for Steam)
if grep -q "#\[multilib\]" /etc/pacman.conf; then
    echo "-> Enabling Multilib repository..."
    sudo sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
    sudo pacman -Sy
fi

# Install Git & Base-Devel
sudo pacman -S --noconfirm git base-devel

# Install YAY (AUR Helper)
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
# CORE: Hyprland, SDDM, Waybar, etc.
# APPS: Thunar, Firefox, Fish, Steam, Spotify, Vesktop
# UTILS: Fastfetch, Grimblast, Polkit-Gnome
yay -S --noconfirm \
    hyprland sddm waybar rofi-wayland alacritty dunst swww \
    xdg-desktop-portal-hyprland xdg-desktop-portal-gtk \
    qt5-wayland qt6-wayland \
    polkit-gnome \
    ttf-font-awesome ttf-jetbrains-mono-nerd \
    python-pywal libadwaita gnome-themes-extra \
    thunar thunar-volman thunar-archive-plugin gvfs file-roller \
    fish firefox grimblast fastfetch \
    steam spotify vesktop

echo "=== 3. INSTALLING CONFIGS ==="
mkdir -p ~/.config
# Copy ALL dotfiles to system config
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

echo "=== 7. SETTING SHELL TO FISH ==="
# Only run if fish isn't already the shell
if [[ "$SHELL" != */fish ]]; then
    chsh -s /usr/bin/fish
fi

echo "=== INSTALL COMPLETE ==="
echo "Please reboot your system."
