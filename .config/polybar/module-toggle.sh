#!/usr/bin/env bash
# Переключает видимость модуля Polybar и запоминает состояние,
# чтобы после перезагрузки/i3-reload оно восстанавливалось.
set -u

mod="${1:-}"
case "$mod" in
    tray|xwindow) ;;
    *) echo "usage: $0 tray|xwindow" >&2; exit 1 ;;
esac

state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/polybar"
state_file="$state_dir/$mod.state"
mkdir -p "$state_dir"

cur="$(cat "$state_file" 2>/dev/null || true)"
if [ -z "$cur" ]; then
    case "$mod" in
        tray)    cur=hidden ;;
        xwindow) cur=shown ;;
    esac
fi

if [ "$cur" = "shown" ]; then
    new=hidden
    action=module_hide
else
    new=shown
    action=module_show
fi

polybar-msg action "#${mod}.${action}" >/dev/null 2>&1 || true
printf '%s\n' "$new" > "$state_file"
