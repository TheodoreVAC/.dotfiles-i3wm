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

# Keep the visible bar's top spacing in sync after i3 starts or reloads.
rm -f -- "${XDG_RUNTIME_DIR:-/tmp}/.polybar-hidden"
i3-msg -q gaps top all set 42 >/dev/null 2>&1 || true
