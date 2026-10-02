#!/usr/bin/env bash
set -euo pipefail

# Проверяет (а с флагом без --check ещё и устанавливает) пакеты,
# без которых конфиги из репозитория не работают.

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

check_only=0
case "${1:-}" in
    --check) check_only=1 ;;
    "") ;;
    --help|-h)
        printf 'Использование: %s [--check]\n' "$0"
        printf '  --check  только проверить и выйти с кодом 1, если чего-то нет\n'
        exit 0
        ;;
    *) printf 'Неизвестный аргумент: %s (см. --help)\n' "$1" >&2; exit 2 ;;
esac

# Команда -> пакет Arch Linux.
declare -A command_packages=(
    [alacritty]=alacritty
    [autotiling]=autotiling
    [dex]=dex
    [dunst]=dunst
    [eza]=eza
    [fastfetch]=fastfetch
    [feh]=feh
    [i3-msg]=i3-wm
    [i3lock]=i3lock
    [jq]=jq
    [maim]=maim
    [nm-applet]=network-manager-applet
    [notify-send]=libnotify
    [pactl]=libpulse
    [pavucontrol]=pavucontrol
    [picom]=picom
    [polybar]=polybar
    [python3]=python
    [redshift]=redshift
    [rofi]=rofi
    [setxkbmap]=xorg-setxkbmap
    [thunar]=thunar
    [wpctl]=wireplumber
    [xclip]=xclip
    [xdg-open]=xdg-utils
    [xrandr]=xorg-xrandr
    [xrdb]=xorg-xrdb
    [xset]=xorg-xset
    [xss-lock]=xss-lock
    [yazi]=yazi
    [zsh]=zsh
)

missing=()

for command_name in "${!command_packages[@]}"; do
    if ! command -v "$command_name" >/dev/null 2>&1; then
        missing+=("${command_packages[$command_name]}")
    fi
done

# Плагины Zsh: подходят системные пакеты либо копии из Oh My Zsh.
if [[ ! -r /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh &&
      ! -r "$HOME/.oh-my-zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh" ]]; then
    missing+=(zsh-autosuggestions)
fi
if [[ ! -r /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh &&
      ! -r "$HOME/.oh-my-zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh" ]]; then
    missing+=(zsh-syntax-highlighting)
fi

# Pillow делает миниатюры для выбора обоев.
if ! python3 -c 'import PIL' >/dev/null 2>&1; then
    missing+=(python-pillow)
fi

# Xlib — polybar/toggle.sh определяет по нему, виден ли бар.
if ! python3 -c 'import Xlib' >/dev/null 2>&1; then
    missing+=(python-xlib)
fi

if ((${#missing[@]})); then
    mapfile -t missing < <(printf '%s\n' "${missing[@]}" | sort -u)
fi

hints=()
[[ -r "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]] ||
    hints+=("Oh My Zsh не найден: git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh")

if ((${#missing[@]} == 0)); then
    printf 'Все зависимости установлены.\n'
else
    printf 'Отсутствуют пакеты:\n'
    printf '  - %s\n' "${missing[@]}"
fi

if ((${#hints[@]})); then
    printf 'Замечания:\n'
    printf '  - %s\n' "${hints[@]}"
fi

if ((check_only)); then
    ((${#missing[@]} == 0)) && exit 0
    exit 1
fi

if ((${#missing[@]} == 0)); then
    exit 0
fi

read -r -p 'Установить недостающее? [Y/n] ' reply
case "${reply:-}" in
    [Nn]*) printf 'Пропущено.\n'; exit 0 ;;
esac

if command -v yay >/dev/null 2>&1; then
    installer=(yay -S --needed)
else
    installer=(sudo pacman -S --needed)
fi

"${installer[@]}" --noconfirm "${missing[@]}"
printf '\nПакеты установлены. Для применения shell-конфигов откройте новый терминал.\n'
