#!/usr/bin/env bash
# Скриншот maim с копированием в буфер и уведомлением dunst.
set -euo pipefail

file="$HOME/Pictures/$(date +%F_%H-%M-%S).png"

if [[ "${1:-}" == "area" ]]; then
    if ! maim -s "$file"; then
        rm -f "$file"
        exit 0
    fi
else
    maim "$file"
fi

xclip -selection clipboard -t image/png >/dev/null 2>&1 < "$file"

dunstify -a "Скриншот" -i "$file" -t 4000 \
    -h string:x-dunst-stack-tag:screenshot \
    "Скриншот сохранён" "$file"
