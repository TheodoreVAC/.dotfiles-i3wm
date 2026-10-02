#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
stamp="$(date +%Y%m%d-%H%M%S)"
dry_run=0
if [[ "${1:-}" == --dry-run ]]; then
    dry_run=1
elif (($#)); then
    printf 'Usage: %s [--dry-run]\n' "$0" >&2
    exit 2
fi

link_file() {
    local relative="$1"
    local source="$repo_dir/$relative"
    local target="$HOME/$relative"

    if [[ ! -e "$source" ]]; then
        printf 'Skipping missing source: %s\n' "$source" >&2
        return
    fi
    if ((dry_run)); then
        printf 'Would link %s -> %s\n' "$target" "$source"
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

while IFS= read -r relative; do
    [[ -n "$relative" ]] && link_file "$relative"
done <<'FILES'
.xinitrc
.Xresources
.zshrc
.p10k.zsh
.config/alacritty/alacritty.toml
.config/alacritty/config.toml
.config/dunst/dunstrc
.config/dunst/history.sh
.config/dunst/status.sh
.config/dunst/toggle-dnd.sh
.config/dunst/volume-notify.sh
.config/fastfetch/config.jsonc
.config/gtk-3.0/settings.ini
.config/gtk-4.0/settings.ini
.config/i3/config
.config/i3/screenshot.sh
.config/i3/wallpaper-picker.sh
.config/systemd/user/autotiling.service
.config/i3status/config
.config/picom/picom.conf
.config/polybar/config.ini
.config/polybar/i3-mode.sh
.config/polybar/launch.sh
.config/polybar/wifi-status.sh
.config/rofi/config.rasi
.config/rofi/notifications.rasi
.config/rofi/wallpaper-picker.rasi
.config/yazi/theme.toml
FILES

font_dir="$repo_dir/.local/share/fonts"
if [[ -d "$font_dir" ]]; then
    if ((dry_run)); then
        printf 'Would install bundled fonts from %s\n' "$font_dir"
    else
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
fi

if ((dry_run)); then
    printf '\nPreview complete; no files were changed.\n'
else
    printf '\nConfigs are linked. Existing files were moved to timestamped .pre-dotfiles backups.\n'
fi

if ! "$repo_dir/scripts/install-deps.sh" --check >/dev/null 2>&1; then
    printf 'Some packages are still missing. Run: %s/scripts/install-deps.sh\n' "$repo_dir"
fi
