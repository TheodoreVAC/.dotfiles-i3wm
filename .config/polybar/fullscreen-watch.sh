#!/usr/bin/env bash
set -euo pipefail

datepill_pid="${1:?Usage: fullscreen-watch.sh POLYBAR_PID}"

sync_datepill() {
    local fullscreen
    fullscreen="$(i3-msg -t get_tree | jq '[.. | objects | select(.fullscreen_mode? == 1)] | length > 0')"

    if [[ "$fullscreen" == true ]]; then
        polybar-msg -p "$datepill_pid" cmd hide >/dev/null 2>&1 || true
    else
        polybar-msg -p "$datepill_pid" cmd show >/dev/null 2>&1 || true
    fi
}

# Subscribe before checking the initial state so fullscreen changes cannot be
# missed between the first state check and the subscription.
exec 3< <(i3-msg -t subscribe -m '["window"]')
sync_datepill

while kill -0 "$datepill_pid" 2>/dev/null; do
    if IFS= read -r -t 1 -u 3 _event; then
        sync_datepill
    fi
done
