#!/bin/bash

if pgrep -x stalonetray >/dev/null; then
    pkill -x stalonetray
else
    nohup stalonetray -c "$HOME/.config/stalonetray/config" >/dev/null 2>&1 &
fi
