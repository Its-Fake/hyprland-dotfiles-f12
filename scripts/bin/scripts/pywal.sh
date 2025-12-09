#!/usr/bin/env bash

wallpaper_path=$(readlink "/home/timo/.current_wallpaper")
echo "Wallpaper path: $wallpaper_path"

check_file() {
    if [ ! -f "$1" ]; then
        echo "File $1 not found!"
        exit 1
    fi
}

check_file "$wallpaper_path"

# Pywal Farben generieren
/usr/bin/wal -i "$wallpaper_path" --backend wal

# Farben aus Pywal laden
. ~/.cache/wal/colors.sh  # lädt $color0..$color15, $foreground, $background

# Kitty-Tab-Hintergründe dynamisch setzen
# Hintergrund in RGB umwandeln
r=$((16#${background:1:2}))
g=$((16#${background:3:2}))
b=$((16#${background:5:2}))

# Helligkeit berechnen (Luminanz)
lum=$(( (r*299 + g*587 + b*114)/1000 ))

# Hintergrund für aktive/inaktive Tabs wählen
if [ "$lum" -lt 128 ]; then
    tab_active=$color7       # helle Akzentfarbe
    tab_inactive=$color8     # neutrale Farbe
else
    tab_active=$color0       # dunkle Akzentfarbe
    tab_inactive=$color8
fi

# Tab-Foreground dynamisch kontrastreich setzen
# Aktiver Tab
r_tab=$((16#${tab_active:1:2}))
g_tab=$((16#${tab_active:3:2}))
b_tab=$((16#${tab_active:5:2}))
lum_tab=$(( (r_tab*299 + g_tab*587 + b_tab*114)/1000 ))
if [ "$lum_tab" -lt 128 ]; then
    fg_active="#ffffff"
else
    fg_active="#000000"
fi

# Inaktiver Tab
r_tab=$((16#${tab_inactive:1:2}))
g_tab=$((16#${tab_inactive:3:2}))
b_tab=$((16#${tab_inactive:5:2}))
lum_tab=$(( (r_tab*299 + g_tab*587 + b_tab*114)/1000 ))
if [ "$lum_tab" -lt 128 ]; then
    fg_inactive="#ffffff"
else
    fg_inactive="#000000"
fi

# Kitty-Extra Conf schreiben
cat > ~/.cache/wal/kitty-extra.conf <<EOF
active_tab_background $tab_active
active_tab_foreground $fg_active
inactive_tab_background $tab_inactive
inactive_tab_foreground $fg_inactive
EOF

# Hex in rgba umwandeln (1.0 alpha = ee)
hex_to_rgba() {
    hex=${1#\#}
    r=$((16#${hex:0:2}))
    g=$((16#${hex:2:2}))
    b=$((16#${hex:4:2}))
    echo "rgba($(printf "%02x" $r)$(printf "%02x" $g)$(printf "%02x" $b)ee)"
}

active_rgba=$(hex_to_rgba $color11)
inactive_rgba=$(hex_to_rgba $color8)

# In Hyprland-Conf ersetzen
sed -i "s/^ *col.active_border =.*/    col.active_border = $active_rgba/" ~/.config/hypr/hyprland.conf
sed -i "s/^ *col.inactive_border =.*/    col.inactive_border = $inactive_rgba/" ~/.config/hypr/hyprland.conf

# Hyprland reloaden
hyprctl reload
