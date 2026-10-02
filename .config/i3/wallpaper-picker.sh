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
declare -A wallpaper_by_name=()

while IFS= read -r -d '' image; do
    wallpapers+=("$image")
    wallpaper_by_name["$(basename -- "$image")"]="$image"
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

selection=$(
    for image in "${wallpapers[@]}"; do
        printf '%s\0icon\x1f%s\n' "$(basename -- "$image")" "$image"
    done | rofi -dmenu -i -show-icons -p 'Обои' \
        -theme-str 'window { width: 85%; height: 70%; } listview { columns: 3; lines: 2; fixed-columns: true; } element { orientation: vertical; spacing: 8px; padding: 10px; } element-icon { size: 220px; } element-text { horizontal-align: 0.5; }'
) || exit 0

[[ -n "$selection" ]] || exit 0
[[ -n "${wallpaper_by_name[$selection]:-}" ]] || exit 1

feh --bg-fill "${wallpaper_by_name[$selection]}"
