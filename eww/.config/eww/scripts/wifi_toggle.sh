#!/bin/bash
STATE=$(nmcli radio wifi | awk 'NR==1{print $1}')
if [ "$STATE" = "enabled" ]; then
    nmcli radio wifi off
else
    nmcli radio wifi on
fi
