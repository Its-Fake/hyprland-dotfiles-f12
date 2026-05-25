#!/bin/bash
EWW_CMD="/home/timo/.local/bin/eww"

# Prüfen ob das control_center Fenster bereits offen ist
if $EWW_CMD active-windows | grep -q "control_center"; then
    # Fenster ist offen -> schließen
    $EWW_CMD close control_center
else
    # Fenster ist geschlossen -> öffnen
    $EWW_CMD open control_center
    
    # Optional: View setzen falls Parameter übergeben wurde
    if [ ! -z "$1" ]; then
	sleep 0.1
        $EWW_CMD update cc_view="$1"
    fi
fi
