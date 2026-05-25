#!/bin/bash
# $1 = Typ (sink/source), $2 = Ziel-ID

TYPE="$1"
TARGET_ID="$2"

if [ "$TYPE" == "sink" ]; then
    # 1. Setze das Standard-Ausgabegerät mit dem korrekten pactl-Befehl.
    pactl set-default-sink "$TARGET_ID"

    # 2. Verschiebe alle aktuell laufenden Audio-Streams zum neuen Gerät.
    for INPUT_ID in $(pactl list sink-inputs | grep 'Sink Input #' | awk '{print $3}' | sed 's/#//'); do
        pactl move-sink-input "$INPUT_ID" "$TARGET_ID"
    done

elif [ "$TYPE" == "source" ]; then
    # 1. Setze das Standard-Eingabegerät mit dem korrekten pactl-Befehl.
    pactl set-default-source "$TARGET_ID"

    # 2. Verschiebe alle aktuell laufenden Aufnahmen zum neuen Gerät.
    for OUTPUT_ID in $(pactl list source-outputs | grep 'Source Output #' | awk '{print $3}' | sed 's/#//'); do
        pactl move-source-output "$OUTPUT_ID" "$TARGET_ID"
    done
fi