#!/usr/bin/env bash
# reload-colors.sh
# Lädt Pywal-Farben neu in Kitty, Dunst, Waybar, Wofi, Wlogout

LOGFILE="/tmp/reload-colors.log"
echo "==============================" >> "$LOGFILE"
echo "$(date '+%Y-%m-%d %H:%M:%S') - Starte Reload" >> "$LOGFILE"

# Pfad zu Pywal-Farbdateien
PYWAL_COLORS="$HOME/.cache/wal/colors.sh"

echo "Prüfe Pywal-Farbdateien..." | tee -a "$LOGFILE"
if [ ! -f "$PYWAL_COLORS" ]; then
    echo "FEHLER: $PYWAL_COLORS existiert nicht. Bitte vorher wal ausführen." | tee -a "$LOGFILE"
    exit 1
fi

# --------------------------
# Kitty-Terminals aktualisieren
# --------------------------
KITTY_COLORS="$HOME/.cache/wal/colors-kitty.conf"
if command -v kitty &>/dev/null; then
    echo "Aktualisiere Kitty..." | tee -a "$LOGFILE"
    kitty @ set-colors --all "$KITTY_COLORS" >> "$LOGFILE" 2>&1
    echo "Kitty aktualisiert." | tee -a "$LOGFILE"
else
    echo "Kitty nicht gefunden." | tee -a "$LOGFILE"
fi

# --------------------------
# Dunst aktualisieren
# --------------------------
echo "Aktualisiere Dunst-Konfiguration..." | tee -a "$LOGFILE"
DUNST_TEMPLATE="$HOME/.config/dunst/dunstrc.template"
DUNST_CONFIG="$HOME/.config/dunst/dunstrc"
DUNST_COLORS="$HOME/.cache/wal/dunstrc"

# Setze die finale Konfigurationsdatei aus der Vorlage und den Pywal-Farben zusammen
cat "$DUNST_TEMPLATE" "$DUNST_COLORS" > "$DUNST_CONFIG"
echo "Dunst-Konfiguration neu aus Vorlagen erstellt." | tee -a "$LOGFILE"

if pgrep dunst &>/dev/null; then
    # Dunst neu starten, um die neue Konfiguration zu laden
    pkill dunst
    sleep 0.1
    dunst >> "$LOGFILE" 2>&1 &
    echo "Dunst neu gestartet." | tee -a "$LOGFILE"
else
    echo "Dunst läuft nicht, wird beim nächsten Mal gestartet." | tee -a "$LOGFILE"
fi

# --------------------------
# Waybar neu starten
# --------------------------
if pgrep waybar &>/dev/null; then
    echo "Starte Waybar neu..." | tee -a "$LOGFILE"
    pkill waybar
    sleep 0.5
    waybar >> "$LOGFILE" 2>&1 &
    echo "Waybar neu gestartet." | tee -a "$LOGFILE"
else
    echo "Waybar nicht gefunden, starte neu..." | tee -a "$LOGFILE"
    waybar >> "$LOGFILE" 2>&1 &
fi

# --------------------------
# Wofi neu starten 
# --------------------------
if pgrep wofi &>/dev/null; then
    echo "Beende laufendes Wofi..." | tee -a "$LOGFILE"
    pkill wofi
    echo "Wofi beendet." | tee -a "$LOGFILE"
fi

# --------------------------
# Wlogout neu starten
# --------------------------
if pgrep wlogout &>/dev/null; then
    echo "Starte Wlogout neu..." | tee -a "$LOGFILE"
    pkill wlogout
    wlogout >> "$LOGFILE" 2>&1 &
    echo "Wlogout neu gestartet." | tee -a "$LOGFILE"
fi

# -------------------------
# Eww Neu starten
# ------------------------
if pgrep eww &>/dev/null; then
    echo "Aktualisiere Eww..." | tee -a "$LOGFILE"
    
    # Liste aller aktuell geöffneten Fenster in einer Variable speichern
    open_windows=$(eww list-windows)
    echo "Aktuell geöffnete Eww-Fenster: $open_windows" | tee -a "$LOGFILE"
    
    # Konfiguration neu laden (wendet die neuen Farben an)
    eww reload >> "$LOGFILE" 2>&1
    echo "Eww-Konfiguration neu geladen." | tee -a "$LOGFILE"
    
    # Zuvor geöffnete Fenster wieder öffnen, falls welche offen waren
    if [ -n "$open_windows" ]; then
        echo "Öffne Eww-Fenster erneut: $open_windows" | tee -a "$LOGFILE"
        eww open-many $open_windows >> "$LOGFILE" 2>&1
    else
        echo "Keine Eww-Fenster waren geöffnet, nichts zu tun." | tee -a "$LOGFILE"
    fi
    echo "Eww aktualisiert." | tee -a "$LOGFILE"
else
    echo "Eww läuft nicht, keine Aktualisierung nötig." | tee -a "$LOGFILE"
fi

echo "$(date '+%Y-%m-%d %H:%M:%S') - Reload abgeschlossen." | tee -a "$LOGFILE"
echo "==============================" >> "$LOGFILE"
