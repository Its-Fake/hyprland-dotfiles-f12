#!/bin/bash
# File to store rotation toggle state (0 = off, 1 = on)
TOGGLE_FILE="$HOME/.config/hypr/rotation-toggle"
if [ "$(cat "$TOGGLE_FILE")" -eq 1 ]; then
	echo "0" > "$TOGGLE_FILE"	
else 
	echo "1" > "$TOGGLE_FILE"
fi
