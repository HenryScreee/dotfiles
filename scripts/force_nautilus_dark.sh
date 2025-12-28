#!/bin/bash
echo "Forcing Nautilus to Dark Mode..."

# 1. Force Global Dark Preference (The "Modern" Way)
# This tells Libadwaita apps (Nautilus) to turn off the lights
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

# 2. Update settings.ini for legacy apps
mkdir -p ~/.config/gtk-3.0 ~/.config/gtk-4.0
# (We append to ensure we don't overwrite cursor settings)
echo 'gtk-application-prefer-dark-theme=1' >> ~/.config/gtk-3.0/settings.ini
echo 'gtk-application-prefer-dark-theme=1' >> ~/.config/gtk-4.0/settings.ini

# 3. Clean up duplicates in settings.ini (Optional, prevents mess)
sed -i -e '$!N; /^\(.*\)\n\1$/!P; D' ~/.config/gtk-3.0/settings.ini

echo "Dark Mode Enforced."
