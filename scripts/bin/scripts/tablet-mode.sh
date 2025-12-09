#!/bin/bash

# Log-Datei für Debugging
LOG_FILE="/tmp/waybar_tablet_mode.log"
echo "--- Skript gestartet am $(date) ---" >> $LOG_FILE

# Aktuelle Drehung aus Hyprland holen
# Wir verwenden den vollen Pfad zu hyprctl, um PATH-Probleme auszuschließen
transform=$(/usr/bin/hyprctl monitors | /usr/bin/awk -F'transform: ' '/transform:/ {print $2}' | head -n1)
echo "Transform-Wert gefunden: '$transform'" >> $LOG_FILE

# Alle Werte außer 0 sind Tablet-Modus
if [[ "$transform" != "0" ]]; then
    echo "Tablet-Modus erkannt. Exit 0 (Anzeigen)." >> $LOG_FILE
    exit 0  # Tablet-Modus: Modul anzeigen
else
    echo "Normal-Modus erkannt. Exit 1 (Verstecken)." >> $LOG_FILE
    exit 1  # Normal-Modus: Modul verstecken
fi
