#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
package_dir="$repo_dir/packages"
mkdir -p "$package_dir"

# Don't add retired panel/tray packages or split debug outputs back to the install snapshot.
pacman -Qqe | grep -Ev -- '(^waybar$|^stalonetray$|-debug$)' | sort -u > "$package_dir/explicit-installed.txt"

foreign_explicit="$(mktemp)"
trap 'rm -f "$foreign_explicit"' EXIT
pacman -Qqm | sort -u > "$foreign_explicit"

# Keep a review list and installable manifests without retired packages or debug outputs.
cp "$package_dir/explicit-installed.txt" "$package_dir/explicit-installable.txt"
grep -Fxf "$foreign_explicit" "$package_dir/explicit-installable.txt" | sort -u > "$package_dir/aur-explicit.txt"
grep -Fxv -f "$package_dir/aur-explicit.txt" "$package_dir/explicit-installable.txt" | sort -u > "$package_dir/arch-explicit.txt"

# yay may come from a custom repo and therefore not appear in pacman -Qm.
if grep -Fxq yay "$package_dir/explicit-installable.txt"; then
    sed -i '/^yay$/d' "$package_dir/arch-explicit.txt"
    grep -Fxq yay "$package_dir/aur-explicit.txt" || printf 'yay\n' >> "$package_dir/aur-explicit.txt"
    sort -u -o "$package_dir/aur-explicit.txt" "$package_dir/aur-explicit.txt"
fi

printf 'Wrote package snapshots under %s\n' "$package_dir"
