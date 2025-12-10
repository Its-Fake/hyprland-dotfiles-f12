#!/bin/bash

USER="timo"
KEEP=10
LOGFILE="/var/log/timeshift.log"
NOW=$(date +%d.%m.%Y-%H:%M)

# DBUS-Adresse aus User-Session holen
DBUS_SESSION=$(grep -z DBUS_SESSION_BUS_ADDRESS /proc/$(pgrep -u $USER -x Hyprland)/environ | tr '\0' '\n' | grep DBUS_SESSION_BUS_ADDRESS | cut -d= -f2-)

# Funktion zum Loggen
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOGFILE"
    sudo -u $USER DBUS_SESSION_BUS_ADDRESS="$DBUS_SESSION" notify-send "Timeshift-Snapshot" "$1"
}

log "===== Script gestartet ====="
log "Datum heute: $NOW"

# Prüfen, ob es heute schon einen Snapshot gibt
#if timeshift --list | grep -q "$NOW"; then
#    log "Es existiert bereits ein Snapshot für heute." 
#    log "===== Script beendet ====="
#    exit 0
#fi

# Snapshot erstellen
log "Erstelle neuen Snapshot..."
echo "--- Timeshift Output Start ---" >> "$LOGFILE"
timeshift --create --comments "Auto snapshot $NOW" --tags >> "$LOGFILE" 2>&1
EXIT_CODE=$?
echo "--- Timeshift Output Ende ---" >> "$LOGFILE"
if [ $EXIT_CODE -ne 0 ]; then
    log "Fehler: Snapshot konnte nicht erstellt werden."
    log "===== Script beendet ====="
    exit 1
fi

# Snapshots zählen
SNAP_COUNT=$(timeshift --list | grep "Auto snapshot" | wc -l)
log "Aktuelle Snapshot-Anzahl: $SNAP_COUNT"

# Falls mehr als $KEEP vorhanden sind → ältesten löschen
if [ "$SNAP_COUNT" -gt "$KEEP" ]; then
    OLDEST=$(timeshift --list | grep "Auto snapshot" | awk '{print $3}' | sort | head -n 1)
    log "Zu viele Snapshots, lösche ältesten: $OLDEST"
    timeshift --delete --snapshot "$OLDEST" >> "$LOGFILE" 2>&1
else
    log "Keine Löschung nötig."
fi

log "===== Script beendet ====="
systemctl poweroff
