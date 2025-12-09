#!/bin/bash
# $1 = action (connect/disconnect), $2 = MAC Address
if [ "$1" == "connect" ]; then
    bluetoothctl connect "$2"
elif [ "$1" == "disconnect" ]; then
    bluetoothctl disconnect "$2"
fi
