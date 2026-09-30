#!/bin/sh

ssid=$(nmcli -t -f IN-USE,SSID device wifi list --rescan no 2>/dev/null \
    | awk -F: '$1 == "*" { print $2; exit }')
if [ -n "$ssid" ]; then
    printf '  %s\n' "$ssid"
else
    printf '  Disconnected\n'
fi
