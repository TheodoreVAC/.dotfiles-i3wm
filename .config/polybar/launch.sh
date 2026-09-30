#!/bin/bash

killall -q polybar

while pgrep -u "$UID" -x polybar >/dev/null; do
    sleep 0.2
done

polybar example &
polybar datepill &

# Скрываем системный трей при запуске; Super+F12 переключает его видимость.
for attempt in {1..20}; do
    if polybar-msg action '#tray.module_hide' >/dev/null 2>&1; then
        break
    fi
    sleep 0.1
done
