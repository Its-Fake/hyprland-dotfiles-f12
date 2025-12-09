#!/usr/bin/env bash
## inspired from https://github.com/JaKooLit 💫 ##
# This script for selecting wallpapers (SUPER W)

#!/usr/bin/env bash
## inspired from https://github.com/JaKooLit 💫 ##
# This script for selecting wallpapers (SUPER W)

# Ordner mit Wallpapers
wallpaperDir="${1:-$HOME/Bilder/wallpaper}"
themesDir="$HOME/.config/rofi/themes"

# swww-Übergangsparameter
FPS=60
TYPE="any"
DURATION=3
BEZIER="0.4,0.2,0.4,1.0"
SWWW_PARAMS="--transition-fps ${FPS} --transition-type ${TYPE} --transition-duration ${DURATION} --transition-bezier ${BEZIER}"

# Bilder und Ordner finden
mapfile -t DIRS < <(find "$wallpaperDir" -maxdepth 1 -mindepth 1 -type d | sort)
mapfile -t PICS < <(find "$wallpaperDir" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" \) | sort)

# Random Wahl vorbereiten
randomPicture="${PICS[$RANDOM % ${#PICS[@]}]}"
randomChoice="[Random]"
backChoice="[..]"

# Rofi Befehl
rofiCommand="rofi -show -dmenu -theme ${themesDir}/wallpaper-select.rasi"

# Wallpaper setzen
set_wallpaper() {
    local file="$1"

     # swww-daemon prüfen und ggf. starten
    if ! pgrep -x swww-daemon > /dev/null; then
        swww init
        sleep 0.5 # Kurz warten, bis der Daemon bereit ist
    fi 

    # wallpaper auf allen Monitoren setzen
    swww img "$file" ${SWWW_PARAMS}

    ln -sf "$file" "$HOME/.current_wallpaper"
    [[ -x ~/bin/scripts/pywal.sh ]] && ~/bin/scripts/pywal.sh
    [[ -x ~/bin/scripts/generate-theme.sh ]] && ~/bin/scripts/generate-theme.sh
    [[ -x ~/bin/scripts/reload-colors.sh ]] && ~/bin/scripts/reload-colors.sh
}

# Menü für rofi
menu() {
    [[ "$(realpath "$wallpaperDir")" != "$(realpath "$HOME/Bilder/wallpaper")" ]] && printf "%s\n" "$backChoice"
    printf "%s\n" "$randomChoice"
    for d in "${DIRS[@]}"; do
        printf "[%s]\x00icon\x1f%s\n" "$(basename "$d")" "/usr/share/icons/breeze-dark/places/48/folder-grey.svg"
    done
    for img in "${PICS[@]}"; do
        printf "%s\x00icon\x1f%s\n" "$(basename "$img" | cut -d. -f1)" "$img"
    done
}

# Main
choice=$(menu | ${rofiCommand})

[[ -z $choice ]] && exit 0

if [[ "$choice" == "$randomChoice" ]]; then
    set_wallpaper "$randomPicture"
elif [[ "$choice" == "$backChoice" ]]; then
    parent="$(dirname "$wallpaperDir")"
    exec "$0" "$parent"
elif [[ "$choice" =~ ^\[.*\]$ ]]; then
    dir="$(echo "$choice" | sed 's/^\[\(.*\)\]$/\1/')"
    exec "$0" "$wallpaperDir/$dir"
else
    for file in "${PICS[@]}"; do
        if [[ "$(basename "$file" | cut -d. -f1)" == "$choice" ]]; then
            set_wallpaper "$file"
	   exit 0
        fi
    done
fi

