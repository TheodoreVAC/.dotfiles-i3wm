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

# Восстанавливаем сохранённое состояние tray и xwindow (Super+F11 / Super+F12).
state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/polybar"
apply_state() {
    local mod="$1" def="$2" cur action
    cur="$(cat "$state_dir/$mod.state" 2>/dev/null || true)"
    [ -n "$cur" ] || cur="$def"
    case "$cur" in
        shown) action=module_show ;;
        *)     action=module_hide ;;
    esac
    polybar-msg -p "$example_pid" action "#${mod}.${action}" >/dev/null 2>&1 || true
}
apply_state tray hidden
apply_state xwindow shown

# Keep the visible bar's spacing in sync after i3 starts or reloads.
# Если бар был скрыт (Super+B), оставляем его скрытым и после перезагрузки i3.
STATE_FILE="${XDG_RUNTIME_DIR:-/tmp}/polybar-hidden-${UID}"
if [ -e "$STATE_FILE" ]; then
    polybar-msg -p "$example_pid" cmd hide >/dev/null 2>&1 || true
    i3-msg -q gaps inner all set 4 >/dev/null 2>&1 || true
    i3-msg -q gaps outer all set 4 >/dev/null 2>&1 || true
    i3-msg -q gaps top all set 4 >/dev/null 2>&1 || true
else
    i3-msg -q gaps inner all set 4 >/dev/null 2>&1 || true
    i3-msg -q gaps outer all set 4 >/dev/null 2>&1 || true
    i3-msg -q gaps top all set 4 >/dev/null 2>&1 || true
fi
