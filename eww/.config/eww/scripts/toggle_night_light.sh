#!/bin/bash
if pgrep -x "gammastep" > /dev/null
then
    killall gammastep
else
    gammastep -l 50.8:6.1 -t 6500:4000 &
fi
