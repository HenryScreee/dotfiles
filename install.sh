#!/bin/bash
# -----------------------------------------------------------------------------
# Henry's Hyprland Installer (v5.1 - Neutral Dark & White Cursor)
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

# --- 2. INSTALL PACKAGES ---
PKGS=(
    # Desktop Core
    hyprland hypridle hyprlock waybar swww waypaper rofi-wayland
    dunst network-manager-applet nwg-dock-hyprland
    sddm qt5-graphicaleffects qt5-quickcontrols2
    
    # Theming Tools
    nwg-look qt5ct qt6ct kvantum unzip curl git
    
    # Terminal & Shell
    alacritty fish fastfetch
    
    # Apps & Tools
    nautilus firefox vesktop steam pavucontrol
    python-pywal python-pip cliphist wl-clipboard grimblast-git
    polkit-gnome brightnessctl pamixer
    
    # Audio & Visuals
    pipewire wireplumber cava
    
    # Music (User Requested: AUR Spotify)
    spotify
    
    # Theming Assets
    papirus-icon-theme ttf-jetbrains-mono-nerd ttf-dejavu ttf-font-awesome
    arc-gtk-theme  # Neutral Dark Theme
    
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

# --- 3. CONFIGURE SDDM ---
echo -e "${YELLOW}Enabling SDDM...${RESET}"
sudo systemctl enable sddm
sudo mkdir -p /etc/sddm.conf.d

# --- 4. INSTALL CUSTOM CURSOR (Posy White) ---
echo -e "${YELLOW}Installing Posy's White Cursor...${RESET}"
if [ ! -d "$HOME/.icons/Posy_Cursor" ]; then
    mkdir -p ~/.icons
    git clone https://github.com/simtrami/posy-improved-cursor-linux.git /tmp/posy-cursor
    # "Posy_Cursor" is the white version
    cp -r /tmp/posy-cursor/Posy_Cursor ~/.icons/
    rm -rf /tmp/posy-cursor
fi

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
link_config ".config/waybar/scripts/quotes.py"
link_config ".config/cava/config_waybar" 
link_config ".config/alacritty/alacritty.toml"
link_config ".config/wal/templates/colors-hyprland.conf"
link_config ".config/rofi/config.rasi"
link_config ".config/dunst/dunstrc"
link_config ".config/fish/config.fish"
link_config ".config/fastfetch/config.jsonc"
link_config ".config/waypaper/config.ini"
rm -rf "$HOME/.config/nwg-dock-hyprland"
ln -s "$DOTFILES_DIR/.config/nwg-dock-hyprland" "$HOME/.config/nwg-dock-hyprland"

chmod +x "$HOME/.config/waybar/scripts/quotes.py"

# Fix Source Paths
sed -i "s|/home/henrys|$HOME|g" $HOME/.config/hypr/hyprland.conf
sed -i "s|HOME_DIR|$HOME|g" $HOME/.config/waypaper/config.ini

# --- 6. BOOTSTRAP COLORS ---
mkdir -p ~/.cache/wal
cat > ~/.cache/wal/colors-hyprland.conf <<EOC
\$background = rgb(111111)
\$foreground = rgb(eeeeee)
\$color0 = rgb(111111)
\$color11 = rgb(888888)
\$color14 = rgb(ffffff)
EOC

# --- 7. APPLY NEUTRAL THEME ---
# Set Arc-Dark (Neutral Grey) and Posy's White Cursor
gsettings set org.gnome.desktop.interface gtk-theme 'Arc-Dark'
gsettings set org.gnome.desktop.interface icon-theme 'Papirus'
gsettings set org.gnome.desktop.interface cursor-theme 'Posy_Cursor'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

echo -e "${GREEN}Installation Complete!${RESET}"
echo "Reboot now."
