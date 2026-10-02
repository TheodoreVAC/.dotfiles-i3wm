#!/usr/bin/env bash
# История уведомлений в Rofi: список, копирование, очистка, повтор последнего.
set -euo pipefail

if ! command -v dunstctl >/dev/null 2>&1; then
    rofi -e "dunst не установлен"
    exit 1
fi

history="$(dunstctl history 2>/dev/null || printf '[]')"

count="$(
    jq 'if type == "object" then (.data // []) else . end
        | if type == "array" and length > 0 and (.[0] | type) == "array"
          then .[0] else . end
        | length' <<< "$history" 2>/dev/null || printf 0
)"

if ((count == 0)); then
    rofi -e "История уведомлений пуста"
    exit 0
fi

# Строка идёт в rofi напрямую из конвейера: переменная bash вырезала бы
# NUL-байты и сломала разделитель "текст\0icon\x1fимя".
selection="$(
    {
        printf 'Очистить историю\0icon\x1fedit-clear-all\n'
        printf 'Показать последнее ещё раз\0icon\x1fview-refresh\n'
        python3 -c '
import html
import json
import re
import sys

strip = re.compile(r"<[^>]+>")
raw = json.load(sys.stdin)

# dunstctl history отдаёт dbus-обёртку {"type": ..., "data": [[{...}]]}.
items = raw.get("data", raw) if isinstance(raw, dict) else raw
if items and isinstance(items[0], list):
    items = items[0]


def value(entry, key):
    field = entry.get(key)
    if isinstance(field, dict) and "data" in field:
        return field["data"]
    return field or ""


for item in items:
    summary = strip.sub("", str(value(item, "summary"))).strip()
    body = strip.sub("", str(value(item, "body"))).strip()
    app = str(value(item, "appname")).strip()
    icon_path = str(value(item, "icon_path")).strip()

    text = summary
    if body:
        text = f"{summary} — {body}" if summary else body
    text = html.unescape(text).replace("\n", " ").strip()
    if not text:
        continue

    icon = icon_path or app or "dialog-information"
    sys.stdout.write(f"{text}\0icon\x1f{icon}\n")
' <<< "$history"
    } | rofi -dmenu -i -no-custom \
        -p "История ($count)" -format 's' \
        -window-title 'Notification History' \
        -theme "$HOME/.config/rofi/notifications.rasi"
)" || exit 0

# Rofi должен вернуть только текст, но подстрахуемся от служебных байтов.
selection="${selection%%$'\x1f'*}"
[[ -n "$selection" ]] || exit 0

case "$selection" in
    "Очистить историю")
        dunstctl history-clear
        dunstify -a "Уведомления" -u low -t 1500 \
            -h string:x-dunst-stack-tag:history \
            "История очищена" "Уведомлений больше нет"
        ;;
    "Показать последнее ещё раз")
        dunstctl history-pop
        ;;
    *)
        # xclip держит выделение в фоне — закрываем его потоки,
        # иначе конвейер не завершится.
        printf '%s' "$selection" | xclip -selection clipboard >/dev/null 2>&1
        dunstify -a "Уведомления" -u low -t 1500 \
            -h string:x-dunst-stack-tag:history \
            "Скопировано в буфер обмена" "$selection"
        ;;
esac
