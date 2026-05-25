#!/bin/bash

# Deaktiviere die Bash History Expansion, um special Charakter in SSIDs zu erlauben
set +H

SSID="$1"

# Prüfen, ob eine Verbindung mit diesem Namen bereits existiert
if nmcli con show "$SSID" &>/dev/null; then
    nmcli con up "$SSID"
else
    # Wenn nicht, nach einem Passwort fragen
    PASSWORD=$(zenity --password --title="WLAN-Passwort für $SSID")
    if [ $? -eq 0 ]; then # Nur fortfahren, wenn nicht auf "Abbrechen" geklickt wurde
        nmcli dev wifi connect "$SSID" password "$PASSWORD"
    fi
fi
