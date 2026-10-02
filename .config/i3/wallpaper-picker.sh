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

thumb_dir="$HOME/.cache/wallpaper-thumbs"
mkdir -p "$thumb_dir"

if command -v python3 >/dev/null 2>&1; then
    python3 - "$wallpaper_dir" "$thumb_dir" <<'PY' 2>/dev/null || true
import os
import sys

from PIL import Image

src_dir, dst_dir = sys.argv[1], sys.argv[2]
exts = {".png", ".jpg", ".jpeg", ".webp", ".bmp", ".gif"}
size = 512

for name in sorted(os.listdir(src_dir)):
    if os.path.splitext(name)[1].lower() not in exts:
        continue
    src = os.path.join(src_dir, name)
    if not os.path.isfile(src):
        continue
    dst = os.path.join(dst_dir, name)
    try:
        if os.path.exists(dst) and os.path.getmtime(dst) >= os.path.getmtime(src):
            continue
        with Image.open(src) as im:
            im.load()
            image = im.convert("RGB")
        width, height = image.size
        side = min(width, height)
        left = (width - side) // 2
        top = (height - side) // 2
        image = image.crop((left, top, left + side, top + side))
        image = image.resize((size, size), Image.LANCZOS)
        image.save(dst)
    except Exception:
        if os.path.exists(dst):
            os.remove(dst)
PY
fi

selection=$(
    for image in "${wallpapers[@]}"; do
        thumb="$thumb_dir/$(basename -- "$image")"
        [[ -f "$thumb" ]] || thumb="$image"
        printf '%s\0icon\x1f%s\n' "$(basename -- "$image")" "$thumb"
    done | rofi -dmenu -i -show-icons -p 'Обои' \
        -window-title 'Wallpaper Picker' \
        -theme "$HOME/.config/rofi/wallpaper-picker.rasi"
) || exit 0

[[ -n "$selection" ]] || exit 0
[[ -n "${wallpaper_by_name[$selection]:-}" ]] || exit 1

feh --bg-fill "${wallpaper_by_name[$selection]}"
