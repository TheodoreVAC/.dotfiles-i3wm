#!/bin/bash

killall -q polybar

while pgrep -u "$UID" -x polybar >/dev/null; do
    sleep 0.2
done

polybar example &
example_pid=$!

# Wait for the main bar's IPC, then hide its tray before starting the date pill.
for attempt in {1..20}; do
    if polybar-msg -p "$example_pid" action '#tray.module_hide' >/dev/null 2>&1; then
        break
    fi
    sleep 0.1
done

polybar datepill &
datepill_pid=$!

# Start the pill last so it remains above the main bar where they overlap.
for attempt in {1..20}; do
    if polybar-msg -p "$datepill_pid" cmd show >/dev/null 2>&1; then
        break
    fi
    sleep 0.1
done

# Keep the visible bar's top spacing in sync after i3 starts or reloads.
i3-msg -q gaps top all set 42 >/dev/null 2>&1 || true
