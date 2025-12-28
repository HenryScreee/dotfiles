#!/bin/bash
# Force GTK 3 settings
mkdir -p ~/.config/gtk-3.0
cat > ~/.config/gtk-3.0/settings.ini <<INI
[Settings]
gtk-theme-name=Materia-dark
gtk-icon-theme-name=Papirus
gtk-font-name=Sans 11
gtk-cursor-theme-name=Posy_Cursor
gtk-application-prefer-dark-theme=1
INI

# Force GTK 4 settings (Nautilus uses this)
mkdir -p ~/.config/gtk-4.0
cat > ~/.config/gtk-4.0/settings.ini <<INI
[Settings]
gtk-theme-name=Materia-dark
gtk-icon-theme-name=Papirus
gtk-font-name=Sans 11
gtk-cursor-theme-name=Posy_Cursor
gtk-application-prefer-dark-theme=1
INI

# Apply to running session
gsettings set org.gnome.desktop.interface gtk-theme 'Materia-dark'
gsettings set org.gnome.desktop.interface cursor-theme 'Posy_Cursor'
gsettings set org.gnome.desktop.interface icon-theme 'Papirus'

echo "Theme Forced. Restart apps to see changes."
