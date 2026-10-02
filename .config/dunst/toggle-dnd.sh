#!/usr/bin/env bash
# Переключение режима «Не беспокоить» с уведомительной подсказкой.
set -euo pipefail

if [[ "$(dunstctl is-paused)" == "true" ]]; then
    dunstctl set-paused false
    dunstify -a "Уведомления" -u low -t 1500 \
        -h string:x-dunst-stack-tag:dnd \
        "Уведомления включены" "Новые уведомления снова показываются"
else
    dunstify -a "Уведомления" -u low -t 1700 \
        -h string:x-dunst-stack-tag:dnd \
        "Не беспокоить" "Уведомления отключены"
    (sleep 1.8; dunstctl set-paused true) &
fi
