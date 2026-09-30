#!/usr/bin/env python3

import os
import subprocess
import sys


INTERFACE = "wlp10s0"
THEME = os.path.expanduser("~/.config/rofi/theme.rasi")


def run(command, *, input_text=None, timeout=15):
    return subprocess.run(
        command,
        input=input_text,
        capture_output=True,
        text=True,
        timeout=timeout,
        check=False,
    )


def split_nmcli(line):
    fields = []
    field = []
    escaped = False

    for char in line.rstrip("\n"):
        if escaped:
            field.append(char)
            escaped = False
        elif char == "\\":
            escaped = True
        elif char == ":":
            fields.append("".join(field))
            field = []
        else:
            field.append(char)

    if escaped:
        field.append("\\")
    fields.append("".join(field))
    return fields


def networks(rescan=False):
    command = [
        "nmcli",
        "-t",
        "-f",
        "IN-USE,SSID,SECURITY,SIGNAL",
        "device",
        "wifi",
        "list",
        "--rescan",
        "yes" if rescan else "no",
    ]
    result = run(command, timeout=30 if rescan else 10)
    if result.returncode != 0:
        return [], (result.stderr or result.stdout).strip()

    strongest = {}
    for line in result.stdout.splitlines():
        fields = split_nmcli(line)
        if len(fields) < 4:
            continue
        active, ssid, security, signal = fields[:4]
        if not ssid:
            continue
        try:
            signal_value = int(signal)
        except ValueError:
            signal_value = 0

        network = {
            "active": active == "*",
            "ssid": ssid,
            "security": security,
            "signal": signal_value,
        }
        previous = strongest.get(ssid)
        if previous is None or network["active"] or signal_value > previous["signal"]:
            strongest[ssid] = network

    return sorted(
        strongest.values(),
        key=lambda network: (not network["active"], -network["signal"], network["ssid"].casefold()),
    ), None


def notify(message, *, urgency="normal"):
    subprocess.Popen(
        ["notify-send", "--app-name=Wi-Fi", "--urgency", urgency, "Wi-Fi", message],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )


def choose(entries, prompt="Wi-Fi", password=False):
    command = ["rofi", "-dmenu", "-i", "-p", prompt, "-theme", THEME]
    if password:
        command.append("-password")
    result = run(
        command,
        input_text="\n".join(entries) + "\n",
        timeout=120,
    )
    if result.returncode != 0:
        return None
    return result.stdout.rstrip("\n")


def main():
    rescan = False
    while True:
        available, error = networks(rescan=rescan)
        rescan = False

        entries = []
        actions = {
            "  Обновить список сетей": ("refresh", None),
            "⚙  Настройки подключений": ("settings", None),
        }
        if error:
            entries.append(f"  Ошибка NetworkManager: {error}")
        elif not available:
            entries.append("󰤭  Доступных сетей нет")

        for network in available:
            icon = "" if network["active"] else "󰤨"
            security = network["security"] or "Открытая сеть"
            active = " · Подключено" if network["active"] else ""
            label = (
                f"{icon}  {network['ssid']}  ·  {network['signal']}%"
                f"  ·  {security}{active}"
            )
            actions[label] = ("disconnect" if network["active"] else "connect", network)
            entries.append(label)

        connected = next((network for network in available if network["active"]), None)
        if connected:
            disconnect_label = f"󰖪  Отключиться от {connected['ssid']}"
            actions[disconnect_label] = ("disconnect", connected)
            entries.insert(0, disconnect_label)
        entries[:0] = ["  Обновить список сетей", "⚙  Настройки подключений"]

        selected = choose(entries)
        if selected is None:
            return

        action, network = actions.get(selected, (None, None))
        if action == "refresh":
            rescan = True
            continue
        if action == "settings":
            subprocess.Popen(
                ["nm-connection-editor"],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )
            return
        if not network:
            return
        if action == "disconnect":
            result = run(["nmcli", "device", "disconnect", INTERFACE], timeout=20)
            if result.returncode == 0:
                notify(f"Отключено от {network['ssid']}")
            else:
                notify((result.stderr or result.stdout).strip() or "Не удалось отключиться", urgency="critical")
            return

        password = ""
        if network["security"]:
            password = choose([], prompt=f"Пароль · {network['ssid']}", password=True)
            if password is None or not password:
                return

        command = ["nmcli", "--wait", "25"]
        if network["security"]:
            command.append("--ask")
        command.extend(["device", "wifi", "connect", network["ssid"], "ifname", INTERFACE])
        result = run(
            command,
            input_text=f"{password}\n" if password else None,
            timeout=35,
        )
        if result.returncode == 0:
            notify(f"Подключено к {network['ssid']}")
        else:
            detail = (result.stderr or result.stdout).strip().splitlines()
            notify(detail[-1] if detail else "Не удалось подключиться", urgency="critical")
        return


if __name__ == "__main__":
    try:
        main()
    except subprocess.TimeoutExpired:
        notify("NetworkManager не ответил вовремя", urgency="critical")
    except FileNotFoundError as error:
        notify(f"Не найдена команда: {error.filename}", urgency="critical")
