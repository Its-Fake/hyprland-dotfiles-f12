#!/bin/bash
# Koppelt und vertraut einem Gerät anhand seiner MAC-Adresse.
MAC="$1"

if [ -z "$MAC" ]; then
    exit 1
fi

bluetoothctl pair "$MAC"
sleep 1
bluetoothctl trust "$MAC"
