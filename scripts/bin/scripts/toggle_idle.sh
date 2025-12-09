#!/bin/bash
flag=/tmp/hypridle_paused
pidf=/tmp/hypridle_inhib_pid

if [ -f "$flag" ]; then
    # Idle wieder aktivieren
    kill "$(cat "$pidf")" 2>/dev/null
    rm -f "$pidf" "$flag"
    wtype " " && sleep 0.1
else
    # Idle pausieren
    systemd-inhibit --what=idle --why="ManualPause" sleep infinity &
    echo $! > "$pidf"
    touch "$flag"
fi
