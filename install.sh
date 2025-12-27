#!/bin/bash
# Henry's Hyprland Installer v8
DOTFILES_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
GREEN="\e[32m"; YELLOW="\e[33m"; RESET="\e[0m"

echo -e "${GREEN}Starting v8 Installation...${RESET}"

# 1. GPU Check
if lspci | grep -qi nvidia; then GPU="nvidia-dkms nvidia-utils nvidia-settings linux-headers"; else GPU=""; fi

# 2. Keyrings
sudo pacman -Sy --noconfirm archlinux-keyring

# 3. Dependencies
sudo pacman -S --needed --noconfirm git base-devel python python-pip python-requests

# 4. Core Packages
PKGS=(
    hyprland hypridle hyprlock waybar swww waypaper rofi-wayland
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

# 5. Fix Colors (Single Quote EOC Fix)
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

# 6. Link Configs
mkdir -p ~/.config
link_config() {
    src="$DOTFILES_DIR/$1"; dest="$HOME/$1"; mkdir -p "$(dirname "$dest")"
    [ -L "$dest" ] && rm "$dest"; [ -f "$dest" ] && mv "$dest" "${dest}.bak"
    ln -s "$src" "$dest"
}
for f in .config/hypr/hyprland.conf .config/hypr/hyprlock.conf .config/hypr/hypridle.conf \
         .config/waybar/config .config/waybar/style.css .config/waybar/scripts/quotes.py \
         .config/alacritty/alacritty.toml .config/rofi/config.rasi .config/dunst/dunstrc \
         .config/fish/config.fish .config/fastfetch/config.jsonc .config/waypaper/config.ini; do
    link_config "$f"
done

# Force Copies
mkdir -p ~/.config/cava
cp "$DOTFILES_DIR/.config/cava/config_waybar" ~/.config/cava/config_waybar
rm -rf ~/.config/nwg-dock-hyprland; ln -s "$DOTFILES_DIR/.config/nwg-dock-hyprland" ~/.config/nwg-dock-hyprland

# 7. Theme & Shell Enforcement
mkdir -p ~/.icons
[ ! -d "$HOME/.icons/Posy_Cursor" ] && git clone https://github.com/simtrami/posy-improved-cursor-linux.git /tmp/posy && cp -r /tmp/posy/Posy_Cursor ~/.icons/ && rm -rf /tmp/posy

# Generate GTK Settings (Bypasses GUI requirement)
mkdir -p ~/.config/gtk-3.0 ~/.config/gtk-4.0
echo '[Settings]
gtk-theme-name=Materia-dark
gtk-icon-theme-name=Papirus
gtk-font-name=Sans 11
gtk-cursor-theme-name=Posy_Cursor
gtk-application-prefer-dark-theme=1' | tee ~/.config/gtk-3.0/settings.ini ~/.config/gtk-4.0/settings.ini > /dev/null

# Change Shell
if [[ "$SHELL" != *"fish"* ]]; then chsh -s $(which fish); fi

# Finalize
chmod +x "$HOME/.config/waybar/scripts/quotes.py"
sed -i "s|/home/henrys|$HOME|g" $HOME/.config/hypr/hyprland.conf
sed -i "s|HOME_DIR|$HOME|g" $HOME/.config/waypaper/config.ini

sudo systemctl enable sddm
echo "Done. Rebooting..."
sleep 2
reboot
