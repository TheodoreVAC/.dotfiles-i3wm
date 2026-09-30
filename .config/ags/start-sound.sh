#!/bin/sh

cd "$HOME/.config/ags" || exit 1

exec ags run --gtk 4
