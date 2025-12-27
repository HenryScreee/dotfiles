#!/bin/bash
# -----------------------------------------------------------------------------
# Henry's Hyprland Installer (v8 - The "Config Enforcer" Edition)
# -----------------------------------------------------------------------------
GREEN="\e[32m"; YELLOW="\e[33m"; RED="\e[31m"; RESET="\e[0m"
DOTFILES_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

echo -e "${GREEN}Starting Installation...${RESET}"

# --- 1. DETECT GPU ---
if lspci | grep -qi nvidia; then
    GPU_PKGS="nvidia-dkms nvidia-utils nvidia-settings linux-headers"
else
    GPU_PKGS=""
fi

# --- 2. UPDATE KEYRINGS ---
echo -e "${YELLOW}Updating Keyrings...${RESET}"
sudo pacman -Sy --noconfirm archlinux-keyring

# --- 3. INSTALL PACKAGES ---
echo -e "${YELLOW}Installing Dependencies...${RESET}"
sudo pacman -S --needed --noconfirm git base-devel python python-pip python-requests

PKGS=(
    # Desktop
    hyprland hypridle hyprlock waybar swww waypaper rofi-wayland
    dunst network-manager-applet nwg-dock-hyprland sddm
    qt5-graphicaleffects qt5-quickcontrols2
    
    # Theming
    nwg-look qt5ct qt6ct kvantum unzip curl
    materia-gtk-theme papirus-icon-theme 
    ttf-jetbrains-mono-nerd noto-fonts-emoji noto-fonts-cjk
    
    # Tools
    alacritty fish fastfetch nautilus firefox vesktop steam pavucontrol
    python-pywal cliphist wl-clipboard grimblast-git
    polkit-gnome brightnessctl pamixer
    
    # Audio
    pipewire wireplumber cava
    
    # GPU
    $GPU_PKGS
)

echo -e "${YELLOW}Installing Packages...${RESET}"
if command -v yay &> /dev/null; then
    yay -S --needed --noconfirm "${PKGS[@]}"
else
    git clone https://aur.archlinux.org/yay.git
    cd yay && makepkg -si --noconfirm
    cd .. && rm -rf yay
    yay -S --needed --noconfirm "${PKGS[@]}"
fi

# --- 4. PRE-GENERATE COLORS (FIXED) ---
echo -e "${YELLOW}Generating Initial Colors...${RESET}"
mkdir -p ~/.cache/wal
# Uses single quotes 'EOC' to prevent variable expansion failure
cat > ~/.cache/wal/colors-hyprland.conf <<'EOC'
$background = rgb(111111)
$foreground = rgb(eeeeee)
$color0 = rgb(111111)
$color1 = rgb(222222)
$color2 = rgb(222222)
$color3 = rgb(222222)
$color4 = rgb(222222)
$color5 = rgb(222222)
$color6 = rgb(222222)
$color7 = rgb(eeeeee)
$color8 = rgb(444444)
$color9 = rgb(222222)
$color10 = rgb(222222)
$color11 = rgb(222222)
$color12 = rgb(222222)
$color13 = rgb(222222)
$color14 = rgb(ffffff)
$color15 = rgb(ffffff)
EOC

# --- 5. LINK CONFIGS ---
echo -e "${YELLOW}Linking Config Files...${RESET}"
mkdir -p ~/.config

link_config() {
    local src="$DOTFILES_DIR/$1"
    local dest="$HOME/$1"
    mkdir -p "$(dirname "$dest")"
    [ -L "$dest" ] && rm "$dest"
    [ -f "$dest" ] && mv "$dest" "${dest}.bak"
    ln -s "$src" "$dest"
    echo "Linked $1"
}

link_config ".config/hypr/hyprland.conf"
link_config ".config/hypr/hyprlock.conf"
link_config ".config/hypr/hypridle.conf"
link_config ".config/waybar/config"
link_config ".config/waybar/style.css"
link_config ".config/waybar/scripts/quotes.py"
link_config ".config/alacritty/alacritty.toml"
link_config ".config/rofi/config.rasi"
link_config ".config/dunst/dunstrc"
link_config ".config/fish/config.fish"
link_config ".config/fastfetch/config.jsonc"
link_config ".config/waypaper/config.ini"

# Force Cava Config
mkdir -p ~/.config/cava
cp "$DOTFILES_DIR/.config/cava/config_waybar" ~/.config/cava/config_waybar

# NWG Dock
rm -rf ~/.config/nwg-dock-hyprland
ln -s "$DOTFILES_DIR/.config/nwg-dock-hyprland" ~/.config/nwg-dock-hyprland

# --- 6. SETUP THEME & CURSOR (HARD ENFORCEMENT) ---
echo -e "${YELLOW}Enforcing Theme, Cursor, and Shell...${RESET}"

# Install Cursor
mkdir -p ~/.icons
if [ ! -d "$HOME/.icons/Posy_Cursor" ]; then
    git clone https://github.com/simtrami/posy-improved-cursor-linux.git /tmp/posy
    cp -r /tmp/posy/Posy_Cursor ~/.icons/
    rm -rf /tmp/posy
fi

# Write GTK 3 Settings (Fixes Cursor/Theme in Apps)
mkdir -p ~/.config/gtk-3.0
cat > ~/.config/gtk-3.0/settings.ini <<EOF
[Settings]
gtk-theme-name=Materia-dark
gtk-icon-theme-name=Papirus
gtk-font-name=Sans 11
gtk-cursor-theme-name=Posy_Cursor
gtk-application-prefer-dark-theme=1
