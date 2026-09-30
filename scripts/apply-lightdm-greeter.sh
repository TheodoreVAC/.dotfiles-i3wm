#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
source_file="$repo_dir/system/lightdm-gtk-greeter.conf"
target_file="/etc/lightdm/lightdm-gtk-greeter.conf"
stamp="$(date +%Y%m%d-%H%M%S)"

if [[ ! -f "$source_file" ]]; then
    printf 'Missing greeter config: %s\n' "$source_file" >&2
    exit 1
fi

if [[ -e "$target_file" ]]; then
    sudo cp -a -- "$target_file" "$target_file.pre-dotfiles.$stamp"
    printf 'Backed up current config to %s.pre-dotfiles.%s\n' "$target_file" "$stamp"
fi

sudo install -o root -g root -m 0644 -- "$source_file" "$target_file"
printf 'Installed LightDM GTK greeter style. It will appear at the next login.\n'
