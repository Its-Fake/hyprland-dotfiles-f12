#!/bin/bash

# EINSTELLUNGEN
SERVER_BENUTZER="timo"
SERVER_NAME="100.86.212.91"
SERVER_QUELLE="/media/externe-ssd/"

LOKAL_MOUNT="/mnt/offsite-backup"
BACKUP_WURZEL="${LOKAL_MOUNT}/server-backups"
BEHALTE_BACKUPS=3

# Initialisierung
DRY_RUN=false
DATUM=$(date '+%Y-%m-%d_%H-%M-%S')
AKTUELLES_BACKUP="${BACKUP_WURZEL}/${DATUM}"
LINK_ZIEL="${BACKUP_WURZEL}/latest"

if ! mountpoint -q "$LOKAL_MOUNT"; then
    echo "FEHLER: SSD nicht gemountet unter $LOKAL_MOUNT"
    exit 1
fi

# Dry-Run Option setzen
DRY_FLAG=""
if [ "$DRY_RUN" = true ]; then
    DRY_FLAG="--dry-run"
    echo "--- SIMULATION LÄUFT (Keine Daten werden kopiert) ---"
fi

# Hardlink-Check
LINK_DEST_OPTION=""
if [ -d "${LINK_ZIEL}" ]; then
    LINK_DEST_OPTION="--link-dest=${LINK_ZIEL}"
fi

# Ausführung
mkdir -p "${AKTUELLES_BACKUP}"

rsync -avhP $DRY_FLAG --delete \
  $LINK_DEST_OPTION \
  --rsync-path="sudo rsync" \
  --exclude="lost+found" \
  "${SERVER_BENUTZER}@${SERVER_NAME}:${SERVER_QUELLE}" \
  "${AKTUELLES_BACKUP}"

if [ $? -eq 0 ] && [ "$DRY_RUN" = false ]; then
    ln -snf "${AKTUELLES_BACKUP}" "${LINK_ZIEL}"
    ls -dt "${BACKUP_WURZEL}"/*/ | tail -n +$((${BEHALTE_BACKUPS} + 1)) | xargs -r rm -rf
    echo "Backup abgeschlossen."
fi
