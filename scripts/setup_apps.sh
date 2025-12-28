#!/bin/bash

# A. Vesktop
echo "Setting up Vesktop..."
mkdir -p ~/.config/vesktop/themes
cp ~/dotfiles/configs/vesktop/*.css ~/.config/vesktop/themes/ 2>/dev/null

# B. Spotify & Spicetify
echo "Setting up Spotify..."
# 1. Install Spotify (if missing)
if ! command -v spotify &> /dev/null; then
    yay -S --noconfirm spotify
fi
# 2. Install Spicetify (if missing)
if ! command -v spicetify &> /dev/null; then
    sudo chmod a+wr /opt/spotify
    sudo chmod a+wr /opt/spotify/Apps -R
    curl -fsSL https://raw.githubusercontent.com/spicetify/spicetify-cli/master/install.sh | sh
    sudo chmod a+wr /opt/spotify
    sudo chmod a+wr /opt/spotify/Apps -R
fi
# 3. Copy Configs
mkdir -p ~/.config/spicetify/Themes
cp -r ~/dotfiles/configs/spicetify/Lucid ~/.config/spicetify/Themes/
cp ~/dotfiles/configs/spicetify/config-xpui.ini ~/.config/spicetify/
# 4. Apply
spicetify backup apply
spicetify apply

# C. Firefox
echo "Setting up Firefox..."
# Find the random profile folder
FF_PROFILE=$(find ~/.mozilla/firefox -maxdepth 1 -type d -name "*.default-release" | head -n 1)
if [ -n "$FF_PROFILE" ]; then
    mkdir -p "$FF_PROFILE/chrome"
    ln -sf ~/dotfiles/configs/firefox/userChrome.css "$FF_PROFILE/chrome/userChrome.css"
    ln -sf ~/dotfiles/configs/firefox/user.js "$FF_PROFILE/user.js"
    echo "Firefox transparency patched."
else
    echo "ERROR: Run Firefox once to create a profile, then run this script again."
fi
