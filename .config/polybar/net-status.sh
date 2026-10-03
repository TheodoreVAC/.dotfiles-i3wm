#!/bin/sh
# Статус сети для Polybar: иконка + Online/Offline + уровень сигнала (dBm).
icon=""
state=$(nmcli -t -f STATE general 2>/dev/null)
level=$(awk 'NR>2 && $1 ~ /:$/ {gsub(/\./,"",$4); print $4; exit}' /proc/net/wireless)

case "$state" in
    connected)
        if [ -n "$level" ]; then
            printf '%%{F#89B4FA}%s%%{F-}  Online %sdBm\n' "$icon" "$level"
        else
            printf '%%{F#89B4FA}%s%%{F-} Online\n' "$icon"
        fi
        ;;
    connecting*)
        printf '%%{F#B9B096}%s%%{F-} Connecting\n' "$icon"
        ;;
    *)
        printf '%%{F#C4727E}%s%%{F-} Offline\n' "$icon"
        ;;
esac
