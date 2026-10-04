#!/usr/bin/env python3
"""Генерация икон-темы Papirus-OS: системный Papirus, перекрашенный в палитру Redline.

Две независимые перекраски:
  * places — через промежуточную «синюю» палитру (palette_rgb), затем фиксированная
    карта RED_MAP: blue-family -> Redline;
  * mimetypes/actions/devices/emblems/emotes/status — hue-сдвигом: холодный (синий)
    диапазон -> красный, зелёный -> янтарный.

Фильтр keep() применяется только к places (цветовые варианты папок и дистрибутивы
отбрасываются). Остальные контексты копируются целиком, категории не копируются.
Каталог назначения можно переопределить переменной PAPIRUS_OS_DST (для проверки).
"""

import colorsys
import os
import re
import shutil

SRC = "/usr/share/icons/Papirus"
DST = os.path.expanduser(os.environ.get("PAPIRUS_OS_DST", "~/.icons/Papirus-OS"))
SIZES = ["16x16", "22x22", "24x24", "32x32", "48x48", "64x64", "96x96", "128x128"]

# (каталог контекста, значение Context= в index.theme)
CONTEXTS = [
    ("places", "Places"),
    ("mimetypes", "MimeTypes"),
    ("actions", "Actions"),
    ("devices", "Devices"),
    ("emblems", "Emblems"),
    ("emotes", "Emotes"),
    ("status", "Status"),
]

# промежуточная палитра (синяя), нужна только чтобы «отбелить» исходные
# оттенки Papirus перед переводом в красные
PALETTE = [
    (0x89, 0xB4, 0xFA),  # blue
    (0x8F, 0xB0, 0xA6),  # green
    (0xB9, 0xB0, 0x96),  # yellow
    (0x9E, 0x9B, 0xC4),  # purple
    (0xC2, 0xA6, 0x7C),  # orange
    (0xAF, 0x93, 0xA8),  # pink
    (0xC4, 0x72, 0x7E),  # red
]

# blue-family -> Redline
RED_MAP = {
    "#7CA3E2": "#E63946",
    "#617FB1": "#B52A33",
    "#4C648B": "#8C1F27",
    "#3D506F": "#74181F",
    "#2B394F": "#4C1014",
    "#86B0F4": "#FF6E76",
    "#1B2331": "#1F1214",
    "#8EAFA5": "#C2555F",
    "#CFAEC7": "#D9B3B6",
}

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


def places_color(hexstr):
    """Цвет папки: промежуточная палитра + карта RED_MAP (её значения — uppercase)."""
    out = palette_rgb(hexstr)
    if out is None:
        return None
    hx = "#%02x%02x%02x" % out
    return RED_MAP.get(hx.upper(), hx)


def convert_places(text):
    def sub(match, width):
        raw = match.group(1)
        hexstr = raw if width == 6 else "".join(ch * 2 for ch in raw)
        out = places_color(hexstr)
        return out if out else match.group(0)

    # короткие hex переписываются первыми, чтобы результат снова не попал
    # под преобразование как «новый» 6-символьный цвет
    text = HEX3.sub(lambda m: sub(m, 3), text)
    text = HEX.sub(lambda m: sub(m, 6), text)
    return text


def hue_convert(text):
    """Холодный диапазон -> красный, зелёный -> янтарный (HLS)."""

    def conv(match):
        hx = match.group(1)
        r, g, b = (int(hx[i:i + 2], 16) / 255 for i in (0, 2, 4))
        h, l, s = colorsys.rgb_to_hls(r, g, b)
        H, L, S = h * 360, l, s
        if S < 0.10:
            return match.group(0)
        if 170 <= H <= 330:
            tH = (355 + (H - 240) * 0.15) % 360
            tS = min(1.0, S * 1.25)
        elif 60 < H < 170:
            tH = (35 + (H - 90) * 0.1) % 360
            tS = min(1.0, S * 1.15)
        else:
            return match.group(0)
        nr, ng, nb = colorsys.hls_to_rgb(tH / 360, L, tS)
        return "#%02X%02X%02X" % (round(nr * 255), round(ng * 255), round(nb * 255))

    return HEX.sub(conv, text)


def main():
    if os.path.isdir(DST):
        shutil.rmtree(DST)
    os.makedirs(DST, exist_ok=True)

    written = 0
    dirs = []
    for context, ctx_name in CONTEXTS:
        for size in SIZES:
            src_dir = os.path.join(SRC, size, context)
            if not os.path.isdir(src_dir):
                continue
            dst_dir = os.path.join(DST, size, context)
            os.makedirs(dst_dir, exist_ok=True)
            for entry in sorted(os.listdir(src_dir)):
                if not entry.endswith(".svg"):
                    continue
                name = entry[:-4]
                if context == "places" and not keep(name):
                    continue
                src_path = os.path.join(src_dir, entry)
                if not os.path.isfile(src_path):  # битые ссылки
                    continue
                with open(src_path, encoding="utf-8", errors="ignore") as fh:
                    data = fh.read()
                if context == "places":
                    data = convert_places(data)
                else:
                    data = hue_convert(data)
                with open(os.path.join(dst_dir, entry), "w", encoding="utf-8") as fh:
                    fh.write(data)
                written += 1
            dirs.append((f"{size}/{context}", ctx_name, int(size.split("x")[0])))

    index = [
        "[Icon Theme]",
        "Name=Papirus OS",
        "Comment=Papirus places recolored to the OS palette",
        "Inherits=Papirus",
        "Example=folder",
        "",
        "Directories=" + ",".join(d for d, _, _ in dirs),
        "",
    ]
    for key, ctx_name, px in dirs:
        index += [f"[{key}]", f"Context={ctx_name}", f"Size={px}", "Type=Fixed", ""]
    with open(os.path.join(DST, "index.theme"), "w", encoding="utf-8") as fh:
        fh.write("\n".join(index).rstrip("\n") + "\n")

    print(f"icons: {written} files, {len(dirs)} dirs -> {DST}")


if __name__ == "__main__":
    main()
