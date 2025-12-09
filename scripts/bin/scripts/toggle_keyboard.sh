#!/bin/bash

# Konfiguration
KEYBOARD_CMD="wvkbd-deskintl -l full,special"
KEYBOARD_DIR="~/wvkbd"  # Passe diesen Pfad an!
PIDFILE="/tmp/wvkbd.pid"

# Funktion: Tastatur starten
start_keyboard() {
    if [ -f "$PIDFILE" ] && kill -0 $(cat "$PIDFILE") 2>/dev/null; then
        echo "Keyboard is already running"
        return 1
    fi
    
    cd "$KEYBOARD_DIR"
    nohup $KEYBOARD_CMD > /dev/null 2>&1 &
    echo $! > "$PIDFILE"
    echo "Keyboard started"
    return 0
}

# Funktion: Tastatur stoppen
stop_keyboard() {
    if [ -f "$PIDFILE" ]; then
        PID=$(cat "$PIDFILE")
        if kill -0 "$PID" 2>/dev/null; then
            kill "$PID"
            rm -f "$PIDFILE"
            echo "Keyboard stopped"
            return 0
        else
            rm -f "$PIDFILE"
            echo "Keyboard was not running"
            return 1
        fi
    else
        # Fallback: Kill alle wvkbd Prozesse
        pkill -f "wvkbd-deskintl"
        echo "Keyboard stopped (fallback)"
        return 0
    fi
}

# Funktion: Status prüfen
status_keyboard() {
    if [ -f "$PIDFILE" ] && kill -0 $(cat "$PIDFILE") 2>/dev/null; then
        echo "running"
        return 0
    else
        echo "stopped"
        return 1
    fi
}

# Hauptlogik
case "$1" in
    start)
        start_keyboard
        ;;
    stop)
        stop_keyboard
        ;;
    toggle)
        if status_keyboard >/dev/null; then
            stop_keyboard
        else
            start_keyboard
        fi
        ;;
    status)
        status_keyboard
        ;;
    *)
        echo "Usage: $0 {start|stop|toggle|status}"
        echo ""
        echo "Commands:"
        echo "  start   - Start the virtual keyboard"
        echo "  stop    - Stop the virtual keyboard"
        echo "  toggle  - Toggle keyboard on/off"
        echo "  status  - Check if keyboard is running"
        exit 1
        ;;
esac
