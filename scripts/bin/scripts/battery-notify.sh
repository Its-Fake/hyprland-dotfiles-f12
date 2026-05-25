#!/bin/bash

BATTERY_LEVEL=$(cat /sys/class/power_supply/BAT1/capacity)
BATTERY_STATUS=$(cat /sys/class/power_supply/BAT1/status)
LAST_NOTIFICATION_FILE="/tmp/battery_last_notification_${USER}"

# Lese letzte Benachrichtigung (verhindert Spam)
if [ -f "$LAST_NOTIFICATION_FILE" ]; then
    LAST_LEVEL=$(cat "$LAST_NOTIFICATION_FILE")
else
    LAST_LEVEL=50
fi

# Akku voll (80% oder höher) und lädt noch
if [ "$BATTERY_LEVEL" -ge 80 ] && [ "$BATTERY_STATUS" == "Charging" ] && [ "$LAST_LEVEL" -lt 80 ]; then
    notify-send -u critical "Akku fast voll" "Bitte Stecker ziehen!"
    echo "$BATTERY_LEVEL" > "$LAST_NOTIFICATION_FILE"
fi

# Akku fast leer (20% oder niedriger) und lädt nicht
if [ "$BATTERY_LEVEL" -le 20 ] && [ "$BATTERY_STATUS" != "Charging" ] && [ "$LAST_LEVEL" -gt 20 ]; then
    notify-send -u critical "Akku fast leer" "Bitte Stecker anschließen!"
    echo "$BATTERY_LEVEL" > "$LAST_NOTIFICATION_FILE"
fi

# Reset der Benachrichtigung wenn Akku in normalem Bereich (21-79%)
if [ "$BATTERY_LEVEL" -gt 20 ] && [ "$BATTERY_LEVEL" -lt 80 ]; then
    echo "50" > "$LAST_NOTIFICATION_FILE"
fi

# Auch reset wenn Status sich ändert (z.B. Stecker gezogen/angeschlossen)
if [ "$BATTERY_LEVEL" -le 20 ] && [ "$BATTERY_STATUS" == "Charging" ]; then
    echo "50" > "$LAST_NOTIFICATION_FILE"
fi

if [ "$BATTERY_LEVEL" -ge 80 ] && [ "$BATTERY_STATUS" != "Charging" ]; then
    echo "50" > "$LAST_NOTIFICATION_FILE"
fi
