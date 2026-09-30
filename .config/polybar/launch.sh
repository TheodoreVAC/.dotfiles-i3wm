#!/bin/bash

killall -q polybar

while pgrep -u "$UID" -x polybar >/dev/null; do
    sleep 0.2
done

polybar example &
example_pid=$!

# Hide the system tray after the main bar's IPC is ready.
for attempt in {1..20}; do
    if polybar-msg -p "$example_pid" action '#tray.module_hide' >/dev/null 2>&1; then
        break
    fi
    sleep 0.1
done

# The date capsule is a separate override-redirect window. Let the watcher
# start it only when no i3 window is fullscreen, avoiding a visible flash.
~/.config/polybar/fullscreen-watch.sh "$example_pid" &

# Keep the visible bar's top spacing in sync after i3 starts or reloads.
i3-msg -q gaps top all set 42 >/dev/null 2>&1 || true
