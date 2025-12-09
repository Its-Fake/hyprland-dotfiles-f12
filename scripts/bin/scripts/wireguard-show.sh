#!/bin/bash

# WireGuard Interface Name (anpassen falls nötig)
WG_INTERFACE="/etc/wireguard/f_-NL-FREE-93.conf"
WG_INTERFACE2="/etc/wireguard/wg-NL-FREE-216.conf"

# Prüfen ob WireGuard läuft (mit sudo)
if sudo ip link show "$WG_INTERFACE" &> /dev/null; then
    # Interface existiert, prüfen ob aktiv
    if [[ $(sudo ip link show "$WG_INTERFACE" | grep -c "state UP") -eq 1 ]]; then
        # Verbindungsinformationen abrufen
        WG_STATUS=$(sudo wg show "$WG_INTERFACE" 2>/dev/null)

        if [[ -n "$WG_STATUS" ]]; then
            # Peer-Informationen extrahieren
            ENDPOINT=$(echo "$WG_STATUS" | grep -oP 'endpoint: \K[^:]+' | head -1)
            LATEST_HANDSHAKE=$(echo "$WG_STATUS" | grep -oP 'latest handshake: \K.*' | head -1)

            # Handshake-Zeit prüfen
            if [[ -n "$LATEST_HANDSHAKE" ]]; then
                HANDSHAKE_AGO=$(date -d "$LATEST_HANDSHAKE" +%s 2>/dev/null || echo 0)
                NOW=$(date +%s)
                TIME_DIFF=$((NOW - HANDSHAKE_AGO))

                if [[ $TIME_DIFF -lt 300 ]]; then
                    # Aktive Verbindung (weniger als 5 Minuten)
                    echo "󰖂"
                    echo "WireGuard: Verbunden\nEndpoint: $ENDPOINT\nLetzter Handshake: vor $((TIME_DIFF / 60)) Min"
                    echo "connected"
                else
                    # Inaktive Verbindung
                    echo "󰖂"
                    echo "WireGuard: Inaktiv\nLetzter Handshake: vor $((TIME_DIFF / 60)) Min"
                    echo "inactive"
                fi
            else
                # Interface up aber kein Handshake
                echo "󰖂"
                echo "WireGuard: Interface aktiv\nKein Handshake"
                echo "inactive"
            fi
        else
            # Interface up aber kein WireGuard Status
            echo "󰖂"
            echo "WireGuard: Interface aktiv\nKeine Peers"
            echo "inactive"
        fi
    else
        # Interface existiert aber ist down
        echo "󰖂"
        echo "WireGuard: Interface down"
        echo "disconnected"
    fi
else
    # Interface existiert nicht
    echo "󰖂"
    echo "WireGuard: Nicht verfügbar"
    echo "disconnected"
fi
