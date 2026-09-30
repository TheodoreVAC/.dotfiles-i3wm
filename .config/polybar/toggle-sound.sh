#!/bin/sh

if ags list 2>/dev/null | grep -Fxq ags; then
    ags quit
else
    cd "$HOME/.config/ags" || exit 1
    nohup ags run --gtk 4 >/dev/null 2>&1 &
fi
