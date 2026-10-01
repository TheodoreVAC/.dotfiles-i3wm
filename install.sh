#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

case "${1:-}" in
    --dry-run) exec "$repo_dir/scripts/install-configs.sh" --dry-run ;;
    --help|-h)
        printf 'Использование: %s [--dry-run]\n' "$0"
        exit 0
        ;;
    "") ;;
    *) printf 'Неизвестный аргумент: %s (см. --help)\n' "$1" >&2; exit 2 ;;
esac

printf '\nTheodoreVAC · i3/X11 dotfiles\n\n'
printf '1) Установить конфиги и шрифты\n'
printf '2) Посмотреть план установки\n'
printf 'q) Выход\n\nВыбор [1]: '
IFS= read -r choice || choice=1
case "${choice:-1}" in
    1) "$repo_dir/scripts/install-configs.sh" ;;
    2) "$repo_dir/scripts/install-configs.sh" --dry-run ;;
    q|Q) exit 0 ;;
    *) printf 'Выберите 1, 2 или q.\n' >&2; exit 2 ;;
esac
