#!/bin/bash

# -----------------------------------------------------------------------------
# Henry's Hyprland Setup Installer (Triple-Checked Version)
# -----------------------------------------------------------------------------
GREEN="\e[32m"; YELLOW="\e[33m"; RED="\e[31m"; RESET="\e[0m"
DOTFILES_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

echo -e "${GREEN}Starting Setup...${RESET}"

# --- 1. DETECT GPU (Nvidia Check) ---
echo -e "${YELLOW}Checking GPU...${RESET}"
GPU_PKGS=""
if lspci | grep -qi nvidia; then
    echo "Nvidia GPU detected."
    GPU_PKGS="nvidia-dkms nvidia-utils nvidia-settings linux-headers"
else
    echo "Non-Nvidia GPU detected. Skipping specific drivers."
fi

# --- 2. INSTALL PACKAGES ---
# AUDIT NOTES:
# - Added 'dunst' (Notification daemon required by hyprland.conf)
# - Added 'network-manager-applet' (Tray icon required by hyprland.conf)
# - Added 'qt5ct' (Qt theme tool required by environment vars)
# - Added 'wireplumber' (Audio control required by Waybar)
# - Added 'ttf-font-awesome' (Icons required by Waybar CSS)
# - Added 'steam' (Required by Super+Ctrl+S keybind)

PKGS=(
    # Desktop Environment
    hyprland hypridle hyprlock waybar swww waypaper rofi-wayland
    dunst network-manager-applet nwg-dock-hyprland
    
    # Terminal & Shell
    alacritty fish fastfetch starship
    
    # Applications
    nautilus firefox vesktop spotify-launcher steam
    
    # Tools & Utilities
    python-pywal python-pip cliphist wl-clipboard grimblast-git
    polkit-gnome qt5ct brightnessctl pamixer
    
    # Audio
    pipewire wireplumber cava
    
    # Theming & Fonts
    materia-gtk-theme papirus-icon-theme
    ttf-jetbrains-mono-nerd ttf-dejavu ttf-font-awesome
    
    # GPU
    $GPU_PKGS
)

echo -e "${YELLOW}Installing Packages...${RESET}"

# Check for yay or paru, else install yay
if command -v yay &> /dev/null; then
    yay -Sy --needed --noconfirm "${PKGS[@]}"
elif command -v paru &> /dev/null; then
    paru -Sy --needed --noconfirm "${PKGS[@]}"
else
    echo -e "${RED}AUR helper not found. Installing yay...${RESET}"
    sudo pacman -S --needed --noconfirm git base-devel
    git clone https://aur.archlinux.org/yay.git
    cd yay && makepkg -si --noconfirm
    cd .. && rm -rf yay
    yay -Sy --needed --noconfirm "${PKGS[@]}"
fi

# --- 3. LINK DOTFILES ---
echo -e "${YELLOW}Linking Config Files...${RESET}"

# Helper function to backup and link
link_config() {
    local source_path="$DOTFILES_DIR/$1"
    local dest_path="$HOME/$1"
    local dest_dir=$(dirname "$dest_path")

    mkdir -p "$dest_dir"
    
    # Backup existing config if it exists
    if [ -L "$dest_path" ]; then
        rm "$dest_path"
    elif [ -f "$dest_path" ]; then
        mv "$dest_path" "${dest_path}.bak"
    fi

    ln -s "$source_path" "$dest_path"
    echo "Linked $1"
}

# Link core configs
link_config ".config/hypr/hyprland.conf"
link_config ".config/waybar/config"
link_config ".config/waybar/style.css"
link_config ".config/alacritty/alacritty.toml"
link_config ".config/wal/templates/colors-hyprland.conf"

# Link Dock folder
rm -rf "$HOME/.config/nwg-dock-hyprland"
ln -s "$DOTFILES_DIR/.config/nwg-dock-hyprland" "$HOME/.config/nwg-dock-hyprland"

# --- 4. SYSTEM TWEAKS ---
echo -e "${YELLOW}Applying System Tweaks...${RESET}"
# Force Dark Theme for GTK 
gsettings set org.gnome.desktop.interface gtk-theme 'Materia-dark-compact'
gsettings set org.gnome.desktop.interface icon-theme 'Papirus'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

# --- 5. WALLPAPER SETUP ---
# Copies the local repo 'wallpapers' folder to the user's Pictures
if [ -d "$DOTFILES_DIR/wallpapers" ]; then
    echo "Copying wallpapers..."
    mkdir -p ~/Pictures/wallpapers
    cp -r "$DOTFILES_DIR/wallpapers/"* ~/Pictures/wallpapers/
else
    echo "Warning: No 'wallpapers' folder found in repo."
fi

# --- 6. FINALIZE ---
chmod +x "$DOTFILES_DIR/install.sh"
echo -e "${GREEN}Installation Complete!${RESET}"
echo -e "IMPORTANT: Open 'waypaper', select an image, and click 'Set' to generate colors."
echo -e "Then reboot your system."
