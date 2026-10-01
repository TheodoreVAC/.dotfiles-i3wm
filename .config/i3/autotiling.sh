#!/usr/bin/env bash
set -euo pipefail

if pgrep -u "$UID" -f '[a]utotiling --limit 2' >/dev/null; then
    pkill -u "$UID" -f '[a]utotiling --limit 2' || true
fi

exec autotiling --limit 2
