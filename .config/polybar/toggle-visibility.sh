#!/bin/sh

set -eu

state_file="${XDG_RUNTIME_DIR:-/tmp}/.polybar-hidden"

if [ -e "$state_file" ]; then
    i3-msg -q gaps top all set 42
    polybar-msg cmd show
    rm -f -- "$state_file"
else
    polybar-msg cmd hide
    i3-msg -q gaps top all set 0
    : > "$state_file"
fi
