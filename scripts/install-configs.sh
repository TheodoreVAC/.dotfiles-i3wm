#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
stamp="$(date +%Y%m%d-%H%M%S)"

link_file() {
    local relative="$1"
    local source="$repo_dir/$relative"
    local target="$HOME/$relative"

    if [[ ! -e "$source" ]]; then
        printf 'Skipping missing source: %s\n' "$source" >&2
        return
    fi

    mkdir -p "$(dirname -- "$target")"
    if [[ -L "$target" && "$(readlink -- "$target")" == "$source" ]]; then
        return
    fi
    if [[ -e "$target" || -L "$target" ]]; then
        mv -- "$target" "$target.pre-dotfiles.$stamp"
        printf 'Backed up existing file: %s.pre-dotfiles.%s\n' "$target" "$stamp"
    fi
    ln -s -- "$source" "$target"
    printf 'Linked %s\n' "$relative"
}

link_external() {
    local source="$1"
    local target="$2"
    if [[ ! -e "$source" ]]; then
        printf 'Skipping missing dependency path: %s\n' "$source" >&2
        return
    fi
    mkdir -p "$(dirname -- "$target")"
    if [[ -L "$target" && "$(readlink -- "$target")" == "$source" ]]; then
        return
    fi
    if [[ -e "$target" || -L "$target" ]]; then
        mv -- "$target" "$target.pre-dotfiles.$stamp"
        printf 'Backed up existing path: %s.pre-dotfiles.%s\n' "$target" "$stamp"
    fi
    ln -s -- "$source" "$target"
}

while IFS= read -r relative; do
    [[ -n "$relative" ]] && link_file "$relative"
done <<'FILES'
.xinitrc
.config/alacritty/alacritty.toml
.config/alacritty/config.toml
.config/fastfetch/config.jsonc
.config/gtk-3.0/settings.ini
.config/i3/config
.config/i3status/config
.config/picom/picom.conf
.config/polybar/config.ini
.config/polybar/launch.sh
.config/polybar/toggle-sound.sh
.config/polybar/wifi-menu.py
.config/polybar/wifi-status.sh
.config/rofi/theme.rasi
.config/ags/app.ts
.config/ags/env.d.ts
.config/ags/package.json
.config/ags/start-sound.sh
.config/ags/style.scss
.config/ags/tsconfig.json
.config/ags/toggle-wifi.sh
.config/ags/wifi.ts
FILES

font_dir="$repo_dir/.local/share/fonts"
if [[ -d "$font_dir" ]]; then
    mkdir -p "$HOME/.local/share/fonts"
    for font in "$font_dir"/*.ttf; do
        target="$HOME/.local/share/fonts/$(basename -- "$font")"
        if [[ -e "$target" ]] && ! cmp -s -- "$font" "$target"; then
            mv -- "$target" "$target.pre-dotfiles.$stamp"
            printf 'Backed up existing font: %s.pre-dotfiles.%s\n' "$target" "$stamp"
        fi
        install -m 0644 "$font" "$target"
    done
    command -v fc-cache >/dev/null 2>&1 && fc-cache -f "$HOME/.local/share/fonts"
fi

# AGS ships its JavaScript modules system-wide; these links make the AGS project runnable.
link_external /usr/share/ags/js "$HOME/.config/ags/node_modules/ags"
link_external /usr/share/ags/js/node_modules/gnim "$HOME/.config/ags/node_modules/gnim"

printf '\nConfigs are linked. Existing files were moved to timestamped .pre-dotfiles backups.\n'
