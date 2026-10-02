#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
source_file="$repo_dir/system/lightdm-gtk-greeter.conf"
css_source_file="$repo_dir/system/lightdm-gtk-greeter.css"
target_file="/etc/lightdm/lightdm-gtk-greeter.conf"
css_dir="/usr/share/themes/Dracula/gtk-3.0/apps"
css_target_file="$css_dir/lightdm-gtk-greeter.css"
stamp="$(date +%Y%m%d-%H%M%S)"

if [[ ! -f "$source_file" ]]; then
    printf 'Missing greeter config: %s\n' "$source_file" >&2
    exit 1
fi

if [[ ! -f "$css_source_file" ]]; then
    printf 'Missing greeter stylesheet: %s\n' "$css_source_file" >&2
    exit 1
fi

if [[ -e "$target_file" ]]; then
    sudo cp -a -- "$target_file" "$target_file.pre-dotfiles.$stamp"
    printf 'Backed up current config to %s.pre-dotfiles.%s\n' "$target_file" "$stamp"
fi

sudo install -o root -g root -m 0644 -- "$source_file" "$target_file"

if sudo test -e "$css_target_file"; then
    sudo cp -a -- "$css_target_file" "$css_target_file.pre-dotfiles.$stamp"
    printf 'Backed up current stylesheet to %s.pre-dotfiles.%s\n' "$css_target_file" "$stamp"
fi

sudo install -d -o root -g root -m 0755 -- "$css_dir"
sudo install -o root -g root -m 0644 -- "$css_source_file" "$css_target_file"
printf 'Installed LightDM GTK greeter config and stylesheet. They will appear at the next login.\n'
