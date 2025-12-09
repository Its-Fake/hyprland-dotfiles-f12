#!/bin/bash
# Nimmt den Namen der Verbindung als erstes Argument ($1) entgegen
CON_NAME="$1"

# Bricht ab, wenn kein Name übergeben wurde
if [ -z "$CON_NAME" ]; then
    exit 1
fi

# Prüft, ob die übergebene Verbindung aktiv ist, und schaltet sie entsprechend
if nmcli con show --active | grep -q "$CON_NAME"; then
    nmcli con down "$CON_NAME"
else
    nmcli con up "$CON_NAME"
fi
