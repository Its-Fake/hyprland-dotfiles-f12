#!/bin/bash

# Das Skript erwartet ein Argument: "window" oder "region"
MODE="$1"

# --- Absolute Pfade zu den Programmen---
EWW_CMD="/home/timo/.local/bin/eww"
SLEEP_CMD="/usr/bin/sleep"
HYPRSHOT_CMD="/usr/bin/hyprshot"
# ---------------------------------------------------------

# Das Eww-Panel schließen
$EWW_CMD close control_center

# Kurz warten, damit das Fenster Zeit hat, zu verschwinden
# $SLEEP_CMD 0.3

# Den Screenshot im gewünschten Modus aufnehmen
$HYPRSHOT_CMD -m "$MODE" -o "$HOME/Bilder/Bildschirmfotos"
