#!/usr/bin/env bash

mode="$(i3-msg -t get_binding_state 2>/dev/null | sed -n 's/.*"name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')"

if [[ -n "$mode" && "$mode" != default ]]; then
    printf '%s\n' "$mode"
else
    # Keep the command output non-empty so Polybar redraws and clears the old mode.
    printf '\u200b\n'
fi
