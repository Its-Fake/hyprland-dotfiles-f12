#!/bin/bash

# Mit swaync: Anzahl der ungelesenen Notifications
count=$(dunstctl count history)
icon="󰂚 "

# Ausgabe als einfache Zeichenkette für Waybar
echo "$icon$count"
