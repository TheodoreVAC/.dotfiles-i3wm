#!/bin/sh
# Статус сети для Polybar: иконка + Link/No link + уровень сигнала (dBm).
icon=""
state=$(nmcli -t -f STATE general 2>/dev/null)
level=$(awk 'NR>2 && $1 ~ /:$/ {gsub(/\./,"",$4); print $4; exit}' /proc/net/wireless)

case "$state" in
    connected)
        if [ -n "$level" ]; then
            printf '%%{F#E63946}%s  Link %sdBm%%{F-}\n' "$icon" "$level"
        else
            printf '%%{F#E63946}%s  Link%%{F-}\n' "$icon"
        fi
        ;;
    connecting*)
        printf '%%{F#E0A458}%s%%{F-} Connecting\n' "$icon"
        ;;
    *)
        printf '%%{F#FF5A63}%s%%{F-} No link\n' "$icon"
        ;;
esac
