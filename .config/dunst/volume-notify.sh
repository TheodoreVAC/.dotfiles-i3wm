#!/usr/bin/env bash
# OSD-уведомления громкости и микрофона с полосой прогресса.
set -euo pipefail

mode="${1:-volume}"

case "$mode" in
    volume)
        read -r level muted < <(
            wpctl get-volume @DEFAULT_AUDIO_SINK@ |
                awk '{m = ($3 == "[MUTED]") ? 1 : 0; printf "%d %d\n", $2 * 100, m}'
        )
        tag="osd-volume"
        label="Громкость"
        ;;
    mic)
        read -r level muted < <(
            wpctl get-volume @DEFAULT_SOURCE@ |
                awk '{m = ($3 == "[MUTED]") ? 1 : 0; printf "%d %d\n", $2 * 100, m}'
        )
        tag="osd-mic"
        label="Микрофон"
        ;;
    *)
        printf 'Usage: %s {volume|mic}\n' "$0" >&2
        exit 2
        ;;
esac

((level > 100)) && level=100

if ((muted)); then
    icon="󰝟"
    text="выключен"
    bar=0
elif [[ "$mode" == "mic" ]]; then
    icon="󰍬"
    text="${level}%"
    bar="$level"
elif ((level == 0)); then
    icon="󰕿"
    text="0%"
    bar=0
elif ((level < 50)); then
    icon="󰖀"
    text="${level}%"
    bar="$level"
else
    icon="󰕾"
    text="${level}%"
    bar="$level"
fi

dunstify -a "Система" -u normal -t 2500 \
    -h "int:value:${bar}" \
    -h "string:x-dunst-stack-tag:${tag}" \
    "${icon} ${label}" "${text}"
