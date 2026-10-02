#!/usr/bin/env bash
set -euo pipefail

wallpaper_dir="$HOME/Wallpapers"

if [[ "${1:-}" == --restore ]]; then
    if [[ -x "$HOME/.fehbg" ]]; then
        "$HOME/.fehbg"
    elif [[ -f "$wallpaper_dir/default1.png" ]]; then
        feh --bg-fill "$wallpaper_dir/default1.png"
    fi
    exit 0
fi

if [[ ! -d "$wallpaper_dir" ]]; then
    rofi -e "Папка ~/Wallpapers не найдена"
    exit 1
fi

declare -a wallpapers=()

while IFS= read -r -d '' image; do
    wallpapers+=("$image")
done < <(
    find "$wallpaper_dir" -maxdepth 1 -type f \
        \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' \
        -o -iname '*.webp' -o -iname '*.bmp' -o -iname '*.gif' \) \
        -print0 | sort -z
)

if ((${#wallpapers[@]} == 0)); then
    rofi -e "В ~/Wallpapers не найдены изображения"
    exit 1
fi

feh --thumbnails --title 'Wallpaper picker' \
    --geometry 1500x850+210+110 \
    --thumb-width 440 --thumb-height 248 \
    --index-info '%n' \
    --action 'feh --bg-fill %F && kill -TERM "$PPID"' \
    "${wallpapers[@]}"
