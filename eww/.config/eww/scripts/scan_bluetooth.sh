#!/bin/bash
# Startet einen 5-sekündigen Bluetooth-Scan im Hintergrund.
# Der Scan läuft asynchron, das UI bleibt bedienbar.
(
  bluetoothctl scan on
  sleep 5
  bluetoothctl scan off
) &
