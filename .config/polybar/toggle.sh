#!/usr/bin/env bash
# Переключение Polybar: скрыть бар и отдать его верхний отступ окну
# (окно растягивается вверх к краю экрана), либо вернуть бар обратно.
set -u

# Значения из ~/.config/i3/config: gaps inner 4, gaps outer 4, gaps top 42.
# При скрытом баре верхний отступ сжимается до 4 (как у остальных краёв),
# inner/outer остаются как в конфиге — по краям остаются отступы.
GAP_TOP_SHOWN=42
GAP_TOP_HIDDEN=4
GAP_OUTER_SHOWN=4
GAP_OUTER_HIDDEN=4
GAP_INNER_SHOWN=4
GAP_INNER_HIDDEN=4

STATE_FILE="${XDG_RUNTIME_DIR:-/tmp}/polybar-hidden-${UID}"

gap() {
    i3-msg -q "gaps $1 all set $2" >/dev/null 2>&1 || true
}

# 0 — окно бара замаплено, 1 — размаплено, 2 — определить не удалось.
bar_mapped() {
    python3 -c '
import sys
try:
    from Xlib import display, X
except Exception:
    sys.exit(2)
try:
    d = display.Display()
except Exception:
    sys.exit(2)
for w in d.screen().root.query_tree().children:
    if w.get_wm_class() == ("polybar", "Polybar"):
        sys.exit(0 if w.get_attributes().map_state == X.IsViewable else 1)
sys.exit(1)
' 2>/dev/null
}

bar_mapped
rc=$?

case "$rc" in
    0) visible=1 ;;
    1) visible=0 ;;
    *) # Нет python-xlib — опираемся на сохранённое состояние.
        if [ -e "$STATE_FILE" ]; then visible=0; else visible=1; fi ;;
esac

if [ "$visible" -eq 1 ]; then
    polybar-msg cmd hide >/dev/null 2>&1 || true
    gap top "$GAP_TOP_HIDDEN"
    gap outer "$GAP_OUTER_HIDDEN"
    gap inner "$GAP_INNER_HIDDEN"
    : > "$STATE_FILE"
else
    if pgrep -u "$UID" -x polybar >/dev/null 2>&1; then
        polybar-msg cmd show >/dev/null 2>&1 || true
    else
        ~/.config/polybar/launch.sh >/dev/null 2>&1 &
        exit 0
    fi
    gap inner "$GAP_INNER_SHOWN"
    gap outer "$GAP_OUTER_SHOWN"
    gap top "$GAP_TOP_SHOWN"
    rm -f "$STATE_FILE"
fi
