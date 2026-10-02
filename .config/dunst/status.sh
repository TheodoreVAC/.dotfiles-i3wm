#!/usr/bin/env bash
# Состояние уведомлений для Polybar: счётчик истории или режим «Не беспокоить».
set -u

if ! command -v dunstctl >/dev/null 2>&1; then
    printf '%%{F#6F7785}󰂚%%{F-}\n'
    exit 0
fi

if [[ "$(dunstctl is-paused 2>/dev/null)" == "true" ]]; then
    printf '%%{F#FAB387}󰂛 DND%%{F-}\n'
    exit 0
fi

count="$(dunstctl count history 2>/dev/null || true)"
[[ "$count" =~ ^[0-9]+$ ]] || count=0

if ((count > 0)); then
    printf '%%{F#89B4FA}󰂚 %s%%{F-}\n' "$count"
else
    printf '%%{F#6F7785}󰂚%%{F-}\n'
fi
