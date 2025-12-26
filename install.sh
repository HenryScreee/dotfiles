#!/bin/bash

# -----------------------------------------------------------------------------
# Henry's Hyprland Setup Installer
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
# Includes 'cava' for Waybar and 'waypaper/swww' for wallpapers
PKGS=(
    hyprland hypridle hyprlock waybar swww waypaper rofi-wayland
    alacritty nautilus firefox vesktop spotify-launcher
    python-pywal python-pip cliphist wl-clipboard
    ttf-jetbrains-mono-nerd ttf-dejavu
    polkit-gnome materia-gtk-theme papirus-icon-theme
    nwg-dock-hyprland grimblast-git
    cava
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
    
    if [ -L "$dest_path" ]; then
        rm "$dest_path"
    elif [ -f "$dest_path" ]; then
        mv "$dest_path" "${dest_path}.bak"
    fi

    ln -s "$source_path" "$dest_path"
    echo "Linked $1"
}

# Link specific files
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

# --- 5. FINALIZE ---
chmod +x "$DOTFILES_DIR/install.sh"
echo -e "${GREEN}Installation Complete!${RESET}"
echo -e "IMPORTANT: Open 'waypaper', select an image, and click 'Set' to generate colors."
echo -e "Then reboot your system."
