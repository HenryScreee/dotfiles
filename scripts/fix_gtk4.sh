#!/bin/bash
# 1. Create local theme folder
mkdir -p ~/.themes
mkdir -p ~/.config/gtk-4.0

# 2. Copy Materia-dark to local themes (fixes permissions issues)
if [ -d /usr/share/themes/Materia-dark ]; then
    cp -r /usr/share/themes/Materia-dark ~/.themes/
fi

# 3. Link GTK4 assets directly (The "Nuclear" Option)
rm -rf ~/.config/gtk-4.0/assets
rm -f ~/.config/gtk-4.0/gtk.css
rm -f ~/.config/gtk-4.0/gtk-dark.css

ln -sf ~/.themes/Materia-dark/gtk-4.0/assets ~/.config/gtk-4.0/assets
ln -sf ~/.themes/Materia-dark/gtk-4.0/gtk.css ~/.config/gtk-4.0/gtk.css
ln -sf ~/.themes/Materia-dark/gtk-4.0/gtk-dark.css ~/.config/gtk-4.0/gtk-dark.css

echo "GTK4 Forced."
