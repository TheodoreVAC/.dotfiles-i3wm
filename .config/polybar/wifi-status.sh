#!/bin/sh

ssid=$(iwgetid -r 2>/dev/null)
if [ -n "$ssid" ]; then
    printf '  %s\n' "$ssid"
else
    printf '  Disconnected\n'
fi
