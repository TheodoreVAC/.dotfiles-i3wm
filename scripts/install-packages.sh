#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
package_dir="$repo_dir/packages"
profile="${1:---desktop}"

case "$profile" in
    --desktop)
        arch_file="$package_dir/desktop-arch.txt"
        aur_file="$package_dir/desktop-aur.txt"
        ;;
    --all)
        arch_file="$package_dir/arch-explicit.txt"
        aur_file="$package_dir/aur-explicit.txt"
        ;;
    *)
        printf 'Usage: %s [--desktop|--all]\n' "$0" >&2
        exit 2
        ;;
esac

if [[ ! -f "$arch_file" || ! -f "$aur_file" ]]; then
    printf 'Package manifests are missing. Run scripts/capture-package-manifest.sh first.\n' >&2
    exit 1
fi

mapfile -t arch_packages < <(grep -Ev '^[[:space:]]*(#|$)' "$arch_file")
mapfile -t aur_packages < <(grep -Ev '^[[:space:]]*(#|$)' "$aur_file")

is_installed() {
    pacman -Qq -- "$1" >/dev/null 2>&1
}

missing_arch_packages=()
for package in "${arch_packages[@]}"; do
    is_installed "$package" || missing_arch_packages+=("$package")
done

if ((${#missing_arch_packages[@]})); then
    sudo pacman -S --needed "${missing_arch_packages[@]}"
fi

missing_aur_packages=()
for package in "${aur_packages[@]}"; do
    is_installed "$package" || missing_aur_packages+=("$package")
done

if ((${#missing_aur_packages[@]})) && ! command -v yay >/dev/null 2>&1; then
    printf 'yay is not installed; bootstrapping it from the AUR.\n'
    sudo pacman -S --needed git base-devel
    build_dir="$(mktemp -d)"
    trap 'rm -rf "$build_dir"' EXIT
    git clone https://aur.archlinux.org/yay.git "$build_dir/yay"
    (cd "$build_dir/yay" && makepkg -si --needed)
fi

if ((${#missing_aur_packages[@]})); then
    yay -S --needed "${missing_aur_packages[@]}"
fi
