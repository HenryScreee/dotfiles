#!/bin/bash
# -----------------------------------------------------------------------------
# Henry's Hyprland Installer (v9 - Gold Edition)
# -----------------------------------------------------------------------------
GREEN="\e[32m"; YELLOW="\e[33m"; RED="\e[31m"; RESET="\e[0m"
DOTFILES_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

echo -e "${GREEN}Starting Installation...${RESET}"

# --- 1. PREP & DEPENDENCIES ---
if lspci | grep -qi nvidia; then GPU="nvidia-dkms nvidia-utils nvidia-settings linux-headers"; else GPU=""; fi
sudo pacman -Sy --noconfirm archlinux-keyring
sudo pacman -S --needed --noconfirm git base-devel python python-pip python-requests

# --- 2. INSTALL PACKAGES ---
PKGS=(
    hyprland hypridle hyprlock waybar swww waypaper rofi-wayland xdg-desktop-portal-gtk
    dunst network-manager-applet nwg-dock-hyprland sddm
    qt5-graphicaleffects qt5-quickcontrols2
    nwg-look qt5ct qt6ct kvantum unzip curl
    materia-gtk-theme papirus-icon-theme 
    ttf-jetbrains-mono-nerd noto-fonts-emoji noto-fonts-cjk
    alacritty fish fastfetch nautilus firefox vesktop steam pavucontrol
    python-pywal cliphist wl-clipboard grimblast-git
    polkit-gnome brightnessctl pamixer
    pipewire wireplumber cava
    $GPU
)

if command -v yay &> /dev/null; then yay -S --needed --noconfirm "${PKGS[@]}"; else
    git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si --noconfirm && cd .. && rm -rf yay
    yay -S --needed --noconfirm "${PKGS[@]}"
fi

# --- 3. FIX COLORS (Prevents Red Bars) ---
mkdir -p ~/.cache/wal
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

# --- 4. DOWNLOAD WALLPAPER (Fixes Black Screen) ---
echo -e "${YELLOW}Downloading Default Wallpaper...${RESET}"
mkdir -p "$DOTFILES_DIR/wallpapers"
if [ ! -f "$DOTFILES_DIR/wallpapers/default.jpg" ]; then
    curl -L -o "$DOTFILES_DIR/wallpapers/default.jpg" https://w.wallhaven.cc/full/l8/wallhaven-l83o92.jpg
fi
# Set it immediately for next boot
mkdir -p ~/.config/waypaper
echo -e "[Settings]\nfolder = $HOME/dotfiles/wallpapers\nwallpaper = $HOME/dotfiles/wallpapers/default.jpg\nbackend = swww\nmonitors = All" > ~/.config/waypaper/config.ini

# --- 5. LINK CONFIGS (Explicit Mode) ---
echo -e "${YELLOW}Linking Configs...${RESET}"
mkdir -p ~/.config

link_file() {
    local src="$DOTFILES_DIR/$1"
    local dest="$HOME/$1"
    mkdir -p "$(dirname "$dest")"
    [ -L "$dest" ] && rm "$dest"
    [ -f "$dest" ] && mv "$dest" "${dest}.bak"
    ln -s "$src" "$dest"
    echo "Linked $1"
}

# The Critical List
link_file ".config/hypr/hyprland.conf"
link_file ".config/hypr/hyprlock.conf"
link_file ".config/waybar/config"
link_file ".config/waybar/style.css"
link_file ".config/waybar/scripts/quotes.py"
link_file ".config/alacritty/alacritty.toml"
link_file ".config/fish/config.fish"
link_file ".config/fastfetch/config.jsonc"
link_file ".config/rofi/config.rasi"
link_file ".config/dunst/dunstrc"

# Force Copies
mkdir -p ~/.config/cava
cp "$DOTFILES_DIR/.config/cava/config_waybar" ~/.config/cava/config_waybar
rm -rf ~/.config/nwg-dock-hyprland
ln -s "$DOTFILES_DIR/.config/nwg-dock-hyprland" ~/.config/nwg-dock-hyprland

# --- 6. THEME & SHELL ---
mkdir -p ~/.icons
[ ! -d "$HOME/.icons/Posy_Cursor" ] && git clone https://github.com/simtrami/posy-improved-cursor-linux.git /tmp/posy && cp -r /tmp/posy/Posy_Cursor ~/.icons/ && rm -rf /tmp/posy

# Generate GTK Settings
mkdir -p ~/.config/gtk-3.0 ~/.config/gtk-4.0
echo '[Settings]
gtk-theme-name=Materia-dark
gtk-icon-theme-name=Papirus
gtk-font-name=Sans 11
gtk-cursor-theme-name=Posy_Cursor
gtk-application-prefer-dark-theme=1' | tee ~/.config/gtk-3.0/settings.ini ~/.config/gtk-4.0/settings.ini > /dev/null

# Fix Fish
if [[ "$SHELL" != *"fish"* ]]; then chsh -s $(which fish); fi

# Finalize
chmod +x "$HOME/.config/waybar/scripts/quotes.py"
sed -i "s|/home/henrys|$HOME|g" $HOME/.config/hypr/hyprland.conf

sudo systemctl enable sddm
echo -e "${GREEN}Installation Complete! Rebooting...${RESET}"
sleep 3
reboot

# --- INITIALIZE COLORS ---
if [ -d "$HOME/dotfiles/wallpapers" ]; then
    echo "Initializing Pywal..."
    # Grabs the first image found in the wallpapers folder
    FIRST_WALL=$(find ~/dotfiles/wallpapers -type f \( -name "*.jpg" -o -name "*.png" \) | head -n 1)
    if [ -n "$FIRST_WALL" ]; then
        wal -i "$FIRST_WALL"
    else
        echo "Warning: No wallpapers found to initialize colors."
    fi
fi

echo "=== FIXING PYWAL TEMPLATES ==="
# 1. Nuke the old folder to prevent recursion bugs
rm -rf ~/.config/wal/templates

# 2. Create the parent directory
mkdir -p ~/.config/wal

# 3. COPY the templates (Safer than symlinking)
cp -r ~/dotfiles/.config/wal/templates ~/.config/wal/

# 4. Initialize Colors (Now guaranteed to find the templates)
if [ -d "$HOME/dotfiles/wallpapers" ]; then
    echo "Initializing Pywal..."
    FIRST_WALL=$(find ~/dotfiles/wallpapers -type f \( -name "*.jpg" -o -name "*.png" \) | head -n 1)
    if [ -n "$FIRST_WALL" ]; then
        wal -i "$FIRST_WALL"
    else
        echo "Warning: No wallpapers found."
    fi
fi

echo "=== FINAL CONFIGURATION ==="

# 1. Fix Nautilus / GTK4 Dark Mode (The Official Way)
# This ensures Nautilus knows it should be dark
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'

# 2. Install Missing Portal (Crucial for Nautilus themes)
if ! pacman -Qs xdg-desktop-portal-gtk > /dev/null; then
    echo "Installing GTK Portal..."
    sudo pacman -S --noconfirm xdg-desktop-portal-gtk
fi

# 3. FIX PYWAL TEMPLATES (The "Safe Copy" Method)
# We delete the destination first to prevent the "folder inside folder" crash
rm -rf ~/.config/wal/templates
mkdir -p ~/.config/wal
# Copy the populated templates from the repo
cp -r ~/dotfiles/.config/wal/templates ~/.config/wal/

# 4. Initialize Colors
if [ -d "$HOME/dotfiles/wallpapers" ]; then
    echo "Initializing Pywal..."
    FIRST_WALL=$(find ~/dotfiles/wallpapers -type f \( -name "*.jpg" -o -name "*.png" \) | head -n 1)
    if [ -n "$FIRST_WALL" ]; then
        wal -i "$FIRST_WALL"
    else
        echo "Warning: No wallpapers found."
    fi
fi

echo "=== FINALIZING SETUP ==="

# 1. Automate Nautilus Fix (So you don't have to run the script manually)
echo "Applying GTK Dark Mode..."
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
# Ensure the folder exists for local settings
mkdir -p ~/.config/gtk-4.0
echo -e "[Settings]\ngtk-application-prefer-dark-theme=1" > ~/.config/gtk-4.0/settings.ini

# 2. Fix Pywal Templates (Safe Copy)
echo "Setting up Color Templates..."
# Delete any existing folder/symlink to avoid crashes
rm -rf ~/.config/wal/templates
mkdir -p ~/.config/wal
# Copy the verified templates from the repo
cp -r ~/dotfiles/.config/wal/templates ~/.config/wal/

# 3. Initialize Colors
if [ -d "$HOME/dotfiles/wallpapers" ]; then
    echo "Initializing Pywal..."
    # Find the first image
    FIRST_WALL=$(find ~/dotfiles/wallpapers -type f \( -name "*.jpg" -o -name "*.png" \) | head -n 1)
    if [ -n "$FIRST_WALL" ]; then
        wal -i "$FIRST_WALL"
    fi
fi

echo "=== 9. FINAL SYSTEM CONFIGURATION ==="

# A. Force Nautilus Dark Mode (File-Based Method)
# This works even if gsettings fails during install
mkdir -p ~/.config/gtk-4.0
cat > ~/.config/gtk-4.0/settings.ini <<INI
[Settings]
gtk-application-prefer-dark-theme=1
gtk-cursor-theme-name=Posy_Cursor
gtk-icon-theme-name=Papirus
INI

# B. Install the missing Portal (Required for Nautilus to listen)
if ! pacman -Qs xdg-desktop-portal-gtk > /dev/null; then
    echo "Installing GTK Portal..."
    sudo pacman -S --noconfirm xdg-desktop-portal-gtk
fi

# C. Setup Pywal Templates (Copy, don't Generate)
echo "Installing Color Templates..."
rm -rf ~/.config/wal/templates
mkdir -p ~/.config/wal
# We COPY the files we verified on the host
cp -r ~/dotfiles/.config/wal/templates ~/.config/wal/

# D. Initialize Colors (First Boot)
if [ -d "$HOME/dotfiles/wallpapers" ]; then
    echo "Initializing Colors..."
    FIRST_WALL=$(find ~/dotfiles/wallpapers -type f \( -name "*.jpg" -o -name "*.png" \) | head -n 1)
    if [ -n "$FIRST_WALL" ]; then
        wal -i "$FIRST_WALL"
    fi
fi
