#!/bin/bash

# =================================================================
# EINSTELLUNGEN
# =================================================================

# Benutzername auf dem Server
SERVER_BENUTZER="timo"

# Die Tailscale-IP des Servers
SERVER_NAME="100.86.212.91"

# Der absolute Pfad zum Wurzelverzeichnis der Backups auf dem Server
BACKUP_WURZEL="/media/externe-ssd/laptop-backups"

# Dein lokales Home-Verzeichnis, das gesichert werden soll
QUELLE_PFAD="/home/timo/"

LOGFILE="/home/timo/.local/state/laptop-backup.log"

# Wie viele alte Backups sollen behalten werden?
BEHALTE_BACKUPS=4

# =================================================================
# Das eigentliche Backup-Skript
# =================================================================

log (){
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOGFILE"
}

log "Starte wöchentliches Snapshot-Backup am $(date)"

# Verbindungstest
if ! ping -c 1 -W 5 "$SERVER_NAME" > /dev/null 2>&1; then
    log "ABBRUCH: Server $SERVER_NAME ist nicht erreichbar (Tailscale offline?)."
    exit 1
fi

# Erstelle den Namen für das heutige Backup-Verzeichnis
DATUM=$(date '+%Y-%m-%d_%H-%M-%S')
AKTUELLES_BACKUP="${BACKUP_WURZEL}/${DATUM}"

# Der Pfad zum letzten Backup, um Hardlinks zu erstellen
LINK_ZIEL="${BACKUP_WURZEL}/latest"

# Baue die --link-dest Option zusammen, falls ein früheres Backup existiert
LINK_DEST_OPTION=""
# Prüfe über SSH, ob der "latest" Link auf dem Server existiert
if ssh "${SERVER_BENUTZER}@${SERVER_NAME}" "[ -d ${LINK_ZIEL} ]"; then
    log "Letztes Backup in ${LINK_ZIEL} gefunden. Nutze Hardlinks."
    LINK_DEST_OPTION="--link-dest=${LINK_ZIEL}"
else
    log "Kein vorheriges Backup gefunden. Erstelle ein Voll-Backup."
fi

# Führe rsync aus
# HINWEIS: --chmod=Du+w,Fu+w hinzugefügt, damit Dateien auf dem Ziel
# Schreibrechte bekommen (verhindert Permission Denied bei Go-Modulen).
log "Starte rsync nach ${AKTUELLES_BACKUP} ..."
rsync -avhP --delete \
  --chmod=Du+w,Fu+w \
  $LINK_DEST_OPTION \
  --include='/.bashrc' \
  --include='/Bilder/***' \
  --include='/bin/***' \
  --include='/Camera/***' \
  --include='/.config/' \
  --include='/.config/avizo/***' \
  --include='/.config/dunst/***' \
  --include='/.config/eww/***' \
  --include='/.config/fastfetch/***' \
  --include='/.config/hypr/***' \
  --include='/.config/kitty/***' \
  --include='/.config/nchat/***' \
  --include='/.config/pavucontrol.ini' \
  --include='/.config/rofi/***' \
  --include='/.config/shell/***' \
  --include='/.config/systemd/***' \
  --include='/.config/ulauncher/***' \
  --include='/.config/wal/***' \
  --include='/.config/waybar/***' \
  --include='/.config/wlogout/***' \
  --include='/.current_wallpaper' \
  --include='/Dokumente/***' \
  --include='/Downloads/***' \
  --exclude='*' \
  "$QUELLE_PFAD" \
  "${SERVER_BENUTZER}@${SERVER_NAME}:${AKTUELLES_BACKUP}" 2>&1 | tee -a "$LOGFILE"

RSYNC_EXIT_CODE=${PIPESTATUS[0]}

# Prüfe, ob rsync erfolgreich war
if [ $RSYNC_EXIT_CODE -eq 0 ]; then
    log "rsync erfolgreich abgeschlossen!"
    
    # Aktualisiere den "latest" Symlink auf dem Server
    log "Aktualisiere 'latest' Symlink."
    ssh "${SERVER_BENUTZER}@${SERVER_NAME}" "ln -snf ${AKTUELLES_BACKUP} ${LINK_ZIEL}"
    
    # Lösche alte Backups
    # HINWEIS: Hier wurde die Logik geändert. Statt einfachem 'rm' wird jetzt
    # erst 'chmod' ausgeführt, um schreibgeschützte Ordner löschbar zu machen.
    log "Lösche alte Backups. Behalte die letzten ${BEHALTE_BACKUPS}."
    
    ssh "${SERVER_BENUTZER}@${SERVER_NAME}" "ls -dt ${BACKUP_WURZEL}/*/ | tail -n +$((${BEHALTE_BACKUPS} + 1)) | while read -r dir_to_delete; do \
        echo \"Lösche: \$dir_to_delete\"; \
        chmod -R u+w \"\$dir_to_delete\"; \
        rm -rf \"\$dir_to_delete\"; \
    done"
    
    log "Backup erfolgreich abgeschlossen!"
else
    log "FEHLER: Das Backup ist mit Exit-Code $RSYNC_EXIT_CODE fehlgeschlagen. Details siehe oben."
    
    # Lösche das unvollständige Backup-Verzeichnis auf dem Server (auch hier mit chmod zur Sicherheit)
    ssh "${SERVER_BENUTZER}@${SERVER_NAME}" "chmod -R u+w ${AKTUELLES_BACKUP} && rm -rf ${AKTUELLES_BACKUP}"
    exit 1
fi

exit 0
