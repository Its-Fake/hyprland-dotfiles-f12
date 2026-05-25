#!/bin/bash
# Benutze den "terse mode" (-t) für eine sprachunabhängige Ausgabe ("enabled" oder "disabled")
# Wir fragen nur den Status von WIFI ab, da dies den Zustand des Flugzeugmodus am besten widerspiegelt.
STATE=$(nmcli -t -f WIFI radio)

if [ "$STATE" = "enabled" ]; then
    # Wenn WLAN an ist, schalte den Flugzeugmodus EIN (alle Funkmodule aus)
    nmcli radio all off
else
    # Wenn WLAN aus ist, schalte den Flugzeugmodus AUS (alle Funkmodule an)
    nmcli radio all on
fi
