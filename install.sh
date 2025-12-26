#!/bin/bash
# -----------------------------------------------------------------------------
# Henry's Hyprland Installer (v4 - Waybar-Cava Edition)
# -----------------------------------------------------------------------------
GREEN="\e[32m"; YELLOW="\e[33m"; RED="\e[31m"; RESET="\e[0m"
DOTFILES_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

echo -e "${GREEN}Starting Installation...${RESET}"

# --- 1. DETECT GPU ---
echo -e "${YELLOW}Checking GPU...${RESET}"
if lspci | grep -qi nvidia; then
    echo "Nvidia GPU detected."
    GPU_PKGS="nvidia-dkms nvidia-utils nvidia-settings linux-headers"
else
    echo "Non-Nvidia GPU detected."
    GPU_PKGS=""
fi

# --- 2. PRE-CLEANUP (Avoid Conflicts) ---
# We remove standard waybar to prevent conflicts with waybar-cava
if pacman -Qi waybar &>/dev/null; then
    echo -e "${YELLOW}Removing standard waybar to install waybar-cava...${RESET}"
    sudo pacman -Rns --noconfirm waybar 2>/dev/null
fi

# --- 3. INSTALL PACKAGES ---
# REMOVED: waybar
# ADDED: waybar-cava, pipewire (explicitly)
PKGS=(
    # Desktop Core
    hyprland hypridle hyprlock waybar-cava swww waypaper rofi-wayland
    dunst network-manager-applet nwg-dock-hyprland
    sddm qt5-graphicaleffects qt5-quickcontrols2
    
    # Terminal & Shell
    alacritty fish fastfetch
    
    # Apps & Tools
    nautilus firefox vesktop spotify-launcher steam pavucontrol
    python-pywal python-pip cliphist wl-clipboard grimblast-git
    polkit-gnome qt5ct brightnessctl pamixer
    
    # Audio & Visuals
    pipewire wireplumber cava
    
    # Theming & Fonts
    materia-gtk-theme papirus-icon-theme
    ttf-jetbrains-mono-nerd ttf-dejavu ttf-font-awesome
    
    # GPU Drivers
    $GPU_PKGS
)

echo -e "${YELLOW}Installing Packages...${RESET}"
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

# --- 4. CONFIGURE SDDM (Login Screen) ---
echo -e "${YELLOW}Enabling SDDM...${RESET}"
sudo systemctl enable sddm
sudo mkdir -p /etc/sddm.conf.d

# --- 5. LINK DOTFILES ---
echo -e "${YELLOW}Linking Config Files...${RESET}"

link_config() {
    local source_path="$DOTFILES_DIR/$1"
    local dest_path="$HOME/$1"
    local dest_dir=$(dirname "$dest_path")
    mkdir -p "$dest_dir"
    if [ -L "$dest_path" ]; then rm "$dest_path"; elif [ -f "$dest_path" ]; then mv "$dest_path" "${dest_path}.bak"; fi
    ln -s "$source_path" "$dest_path"
    echo "Linked $1"
}

link_config ".config/hypr/hyprland.conf"
link_config ".config/hypr/hyprlock.conf"
link_config ".config/hypr/hypridle.conf"
link_config ".config/waybar/config"
link_config ".config/waybar/style.css"
link_config ".config/alacritty/alacritty.toml"
link_config ".config/wal/templates/colors-hyprland.conf"
link_config ".config/rofi/config.rasi"
link_config ".config/dunst/dunstrc"
link_config ".config/fish/config.fish"
link_config ".config/fastfetch/config.jsonc"
link_config ".config/waypaper/config.ini"
rm -rf "$HOME/.config/nwg-dock-hyprland"
ln -s "$DOTFILES_DIR/.config/nwg-dock-hyprland" "$HOME/.config/nwg-dock-hyprland"

# Fix Source Paths for the current user
sed -i "s|/home/henrys|$HOME|g" $HOME/.config/hypr/hyprland.conf
sed -i "s|HOME_DIR|$HOME|g" $HOME/.config/waypaper/config.ini

# --- 6. BOOTSTRAP COLORS ---
echo -e "${YELLOW}Generating bootstrap colors...${RESET}"
mkdir -p ~/.cache/wal
cat > ~/.cache/wal/colors-hyprland.conf <<EOC
\$background = rgb(111111)
\$foreground = rgb(eeeeee)
\$color0 = rgb(111111)
\$color1 = rgb(888888)
\$color2 = rgb(888888)
\$color3 = rgb(888888)
\$color4 = rgb(888888)
\$color5 = rgb(888888)
\$color6 = rgb(888888)
\$color7 = rgb(eeeeee)
\$color8 = rgb(444444)
\$color9 = rgb(888888)
\$color10 = rgb(888888)
\$color11 = rgb(888888)
\$color12 = rgb(888888)
\$color13 = rgb(888888)
\$color14 = rgb(ffffff)
\$color15 = rgb(ffffff)
EOC

# --- 7. WALLPAPERS & THEME ---
if [ -d "$DOTFILES_DIR/wallpapers" ]; then
    echo "Copying wallpapers..."
    mkdir -p ~/Pictures/wallpapers
    cp -r "$DOTFILES_DIR/wallpapers/"* ~/Pictures/wallpapers/
fi

gsettings set org.gnome.desktop.interface gtk-theme 'Materia-dark-compact'
gsettings set org.gnome.desktop.interface icon-theme 'Papirus'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

# --- 8. SAFETY DEBLOAT ---
for pkg in wofi kitty foot dolphin mako; do
    if pacman -Qi $pkg &>/dev/null; then
        echo "Removing conflicting app: $pkg"
        sudo pacman -Rns --noconfirm $pkg 2>/dev/null
    fi
done

echo -e "${GREEN}Installation Complete!${RESET}"
echo "Reboot now. You should see the SDDM Login Screen."
