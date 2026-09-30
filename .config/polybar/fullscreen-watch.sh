#!/usr/bin/env bash
set -euo pipefail

main_bar_pid="${1:?Usage: fullscreen-watch.sh MAIN_POLYBAR_PID}"

# Shell sessions may retain an I3SOCK path from an earlier i3 process.
unset I3SOCK

datepill_pid=""

start_datepill() {
    if [[ -n "$datepill_pid" ]] && kill -0 "$datepill_pid" 2>/dev/null; then
        return
    fi

    polybar datepill &
    datepill_pid=$!
}

stop_datepill() {
    if [[ -n "$datepill_pid" ]] && kill -0 "$datepill_pid" 2>/dev/null; then
        kill "$datepill_pid" 2>/dev/null || true
        wait "$datepill_pid" 2>/dev/null || true
    fi
    datepill_pid=""
}

sync_datepill() {
    local fullscreen
    fullscreen="$(i3-msg -t get_tree | jq '[.. | objects | select(.fullscreen_mode? == 1)] | length > 0')"

    if [[ "$fullscreen" == true ]]; then
        stop_datepill
    else
        start_datepill
    fi
}

# Subscribe before checking the initial state so fullscreen changes cannot be
# missed between the first state check and the subscription.
exec 3< <(i3-msg -t subscribe -m '["window"]')
sync_datepill

while kill -0 "$main_bar_pid" 2>/dev/null; do
    if IFS= read -r -t 1 -u 3 _event; then
        sync_datepill
    fi
done

stop_datepill
