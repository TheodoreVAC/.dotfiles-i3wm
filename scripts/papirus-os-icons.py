#!/usr/bin/env python3
"""Генерация икон-темы Papirus-OS: папки Papirus, перекрашенные в палитру OS."""

import colorsys
import os
import re

SRC = "/usr/share/icons/Papirus"
DST = os.path.expanduser("~/.icons/Papirus-OS")
SIZES = ["16x16", "22x22", "24x24", "32x32", "48x48", "64x64", "96x96", "128x128"]

# палитра из ~/.config/polybar/config.ini
PALETTE = [
    (0x89, 0xB4, 0xFA),  # blue
    (0x8F, 0xB0, 0xA6),  # green
    (0xB9, 0xB0, 0x96),  # yellow
    (0x9E, 0x9B, 0xC4),  # purple
    (0xC2, 0xA6, 0x7C),  # orange
    (0xAF, 0x93, 0xA8),  # pink
    (0xC4, 0x72, 0x7E),  # red
]

EXCLUDE = {
    # цветовые варианты папок
    "black", "blue", "brown", "cyan", "darkcyan", "magenta", "teal", "violet",
    "green", "grey", "gray", "indigo", "orange", "pink", "purple", "red",
    "wine", "yellow", "white", "breeze", "carmine", "yaru", "nordic",
    # дистрибутивы / окружения
    "adwaita", "gnome", "kali", "ubuntu", "arch", "debian", "linux", "mint",
    "manjaro", "opensuse", "fedora", "gentoo", "suse", "redhat", "puppy",
    "pardus", "oracle", "mageia", "mandriva", "kubuntu", "slackware",
    "trisquel", "zorin", "budgie", "elementary", "deepin", "endeavour",
    "artix", "kde", "xfce", "lxqt", "lxde", "mate", "unity", "distributor",
    "starthere", "start", "here",
}

HEX = re.compile(r"#([0-9a-fA-F]{6})\b")
HEX3 = re.compile(r"#([0-9a-fA-F]{3})\b")


def keep(name):
    tokens = set(re.split(r"[-_]", name.lower()))
    return not tokens & EXCLUDE


def palette_rgb(hexstr):
    r, g, b = (int(hexstr[i:i + 2], 16) for i in (0, 2, 4))
    h, s, v = colorsys.rgb_to_hsv(r / 255, g / 255, b / 255)
    if s < 0.12 or v < 0.12:
        return None
    best, best_delta = None, 999.0
    for p in PALETTE:
        ph, ps, pv = colorsys.rgb_to_hsv(*(c / 255 for c in p))
        delta = abs(h - ph)
        delta = min(delta, 1 - delta)
        if delta < best_delta:
            best, best_delta = (p, pv), delta
    (pr, pg, pb), pv = best
    ratio = v / pv if pv else 1.0
    return tuple(max(0, min(255, round(c * ratio))) for c in (pr, pg, pb))


def convert(text):
    def sub6(m):
        out = palette_rgb(m.group(1))
        return "#%02x%02x%02x" % out if out else m.group(0)

    def sub3(m):
        hex6 = "".join(ch * 2 for ch in m.group(1))
        out = palette_rgb(hex6)
        return "#%02x%02x%02x" % out if out else m.group(0)

    text = HEX.sub(sub6, text)
    text = HEX3.sub(sub3, text)
    return text


def main():
    total = 0
    names = set()
    for size in SIZES:
        src_dir = os.path.join(SRC, size, "places")
        if not os.path.isdir(src_dir):
            continue
        dst_dir = os.path.join(DST, size, "places")
        os.makedirs(dst_dir, exist_ok=True)
        for entry in sorted(os.listdir(src_dir)):
            if not entry.endswith(".svg"):
                continue
            name = entry[:-4]
            if not keep(name):
                continue
            src_path = os.path.join(src_dir, entry)
            if not os.path.isfile(src_path):  # битые ссылки
                continue
            with open(src_path, encoding="utf-8", errors="replace") as fh:
                data = fh.read()
            with open(os.path.join(dst_dir, entry), "w", encoding="utf-8") as fh:
                fh.write(convert(data))
            names.add(name)
            total += 1

    dirs = ",".join(f"{s}/places" for s in SIZES if os.path.isdir(os.path.join(DST, s, "places")))
    entries = []
    for size in SIZES:
        if os.path.isdir(os.path.join(DST, size, "places")):
            entries.append(
                f"[{size}/places]\nContext=Places\nSize={int(size.split('x')[0])}\nType=Fixed\n"
            )
    with open(os.path.join(DST, "index.theme"), "w", encoding="utf-8") as fh:
        fh.write(
            "[Icon Theme]\n"
            "Name=Papirus OS\n"
            "Comment=Papirus places recolored to the OS palette\n"
            "Inherits=Papirus\n"
            "Example=folder\n\n"
            f"Directories={dirs}\n\n" + "\n".join(entries)
        )
    print(f"icons: {total} files, {len(names)} names -> {DST}")


if __name__ == "__main__":
    main()
