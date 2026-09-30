#!/bin/sh

cd "$HOME/.config/ags" || exit 1

# AGS uses a single application instance for this config directory.
ags quit >/dev/null 2>&1 || true
sleep 0.2
exec ags run --gtk 4 wifi.ts
