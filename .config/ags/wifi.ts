import app from "ags/gtk4/app"
import Gtk from "gi://Gtk?version=4.0"
import Gio from "gi://Gio"
import GLib from "gi://GLib"
import style from "./style.scss"

const interfaceName = GLib.getenv("WIFI_INTERFACE") || "wlp10s0"
let window: Gtk.Window | null = null
let networkList: Gtk.Box
let statusLabel: Gtk.Label

function run(command: string[]): string {
    try {
        const process = Gio.Subprocess.new(command, Gio.SubprocessFlags.STDOUT_PIPE | Gio.SubprocessFlags.STDERR_PIPE)
        const [ok, stdout, stderr] = process.communicate_utf8(null, null)
        if (!ok || !process.get_successful()) throw new Error(stderr || "NetworkManager не выполнил команду")
        return stdout || ""
    } catch (error) {
        throw new Error(String(error))
    }
}

function fields(line: string): string[] {
    const result: string[] = []
    let part = ""
    let escaped = false
    for (const char of line) {
        if (escaped) { part += char; escaped = false }
        else if (char === "\\") escaped = true
        else if (char === ":") { result.push(part); part = "" }
        else part += char
    }
    result.push(part)
    return result
}

function clearList() {
    let child = networkList.get_first_child()
    while (child) {
        const next = child.get_next_sibling()
        networkList.remove(child)
        child = next
    }
}

function showPassword(ssid: string, security: string) {
    const dialog = new Gtk.Window({
        application: app,
        title: "Подключение к Wi-Fi",
        decorated: false,
        resizable: false,
        modal: true,
        transient_for: window,
        default_width: 360,
    })
    dialog.add_css_class("sound-window")
    const panel = new Gtk.Box({ orientation: Gtk.Orientation.VERTICAL, spacing: 12 })
    panel.add_css_class("sound-panel")
    const title = new Gtk.Label({ label: `Подключение к ${ssid}`, xalign: 0 })
    title.add_css_class("window-title")
    const entry = new Gtk.PasswordEntry({ placeholder_text: "Пароль сети", show_peek_icon: true })
    entry.add_css_class("wifi-password")
    const actions = new Gtk.Box({ orientation: Gtk.Orientation.HORIZONTAL, spacing: 8, halign: Gtk.Align.END })
    const cancel = new Gtk.Button({ label: "Отмена" })
    cancel.add_css_class("wifi-button")
    cancel.connect("clicked", () => dialog.close())
    const connect = new Gtk.Button({ label: "Подключиться" })
    connect.add_css_class("wifi-button")
    connect.connect("clicked", () => {
        const password = entry.get_text()
        if (!password) { entry.grab_focus(); return }
        connect.set_sensitive(false)
        statusLabel.set_label(`Подключение к «${ssid}»…`)
        const process = Gio.Subprocess.new(
            ["nmcli", "--wait", "25", "--ask", "device", "wifi", "connect", ssid, "ifname", interfaceName],
            Gio.SubprocessFlags.STDIN_PIPE | Gio.SubprocessFlags.STDOUT_PIPE | Gio.SubprocessFlags.STDERR_PIPE,
        )
        process.communicate_utf8_async(`${password}\n`, null, (_proc, result) => {
            try {
                const [, stdout, stderr] = process.communicate_utf8_finish(result)
                if (process.get_successful()) {
                    statusLabel.set_label(`Подключено к «${ssid}»`)
                    dialog.close()
                    refresh(false)
                } else {
                    statusLabel.set_label((stderr || stdout || "Не удалось подключиться").trim().split("\n").at(-1) || "Ошибка подключения")
                    connect.set_sensitive(true)
                }
            } catch (error) {
                statusLabel.set_label(String(error))
                connect.set_sensitive(true)
            }
        })
    })
    actions.append(cancel)
    actions.append(connect)
    panel.append(title)
    panel.append(entry)
    panel.append(actions)
    dialog.set_child(panel)
    dialog.present()
    entry.grab_focus()
}

function refresh(rescan: boolean) {
    if (!rescan) clearList()
    statusLabel.set_label(rescan ? "Сканирование сетей…" : "Доступные сети")
    try {
        const process = Gio.Subprocess.new(
            ["nmcli", "-t", "-f", "IN-USE,SSID,SECURITY,SIGNAL", "device", "wifi", "list", "--rescan", rescan ? "yes" : "no"],
            Gio.SubprocessFlags.STDOUT_PIPE | Gio.SubprocessFlags.STDERR_PIPE,
        )
        process.communicate_utf8_async(null, null, (_proc, result) => {
            try {
                const [, output, stderr] = process.communicate_utf8_finish(result)
                if (!process.get_successful()) throw new Error(stderr || "Не удалось получить список сетей")
                renderNetworks(output || "", rescan)
            } catch (error) {
                statusLabel.set_label(String(error))
            }
        })
    } catch (error) {
        statusLabel.set_label(String(error))
    }
}

function renderNetworks(output: string, rescan: boolean) {
    clearList()
    try {
        const strongest = new Map<string, { active: boolean, ssid: string, security: string, signal: number }>()
        for (const line of output.split("\n")) {
            if (!line) continue
            const [active, ssid, security, rawSignal] = fields(line)
            if (!ssid) continue
            const network = { active: active === "*", ssid, security, signal: Number(rawSignal) || 0 }
            const previous = strongest.get(ssid)
            if (!previous || network.active || network.signal > previous.signal) strongest.set(ssid, network)
        }
        const networks = [...strongest.values()].sort((a, b) => Number(b.active) - Number(a.active) || b.signal - a.signal || a.ssid.localeCompare(b.ssid))
        if (!networks.length) {
            const empty = new Gtk.Label({ label: "Сети не найдены", xalign: 0 })
            empty.add_css_class("wifi-empty")
            networkList.append(empty)
        }
        for (const network of networks) {
            const row = new Gtk.Box({ orientation: Gtk.Orientation.HORIZONTAL, spacing: 12 })
            row.add_css_class("wifi-row")
            const icon = new Gtk.Label({ label: network.active ? "" : "󰤨" })
            icon.add_css_class(network.active ? "device-icon" : "wifi-icon")
            const details = new Gtk.Box({ orientation: Gtk.Orientation.VERTICAL, spacing: 3, hexpand: true })
            const name = new Gtk.Label({ label: network.ssid, xalign: 0, ellipsize: 3 })
            name.add_css_class("wifi-name")
            const subtitle = new Gtk.Label({ label: `${network.active ? "Подключено  ·  " : ""}${network.security || "Открытая сеть"}  ·  ${network.signal}%`, xalign: 0 })
            subtitle.add_css_class("wifi-subtitle")
            details.append(name)
            details.append(subtitle)
            row.append(icon)
            row.append(details)
            const button = new Gtk.Button({ label: network.active ? "Отключить" : "Подключить" })
            button.add_css_class("wifi-button")
            button.connect("clicked", () => {
                if (network.active) {
                    try {
                        run(["nmcli", "device", "disconnect", interfaceName])
                        statusLabel.set_label(`Отключено от «${network.ssid}»`)
                        refresh(false)
                    } catch (error) { statusLabel.set_label(String(error)) }
                } else if (network.security) showPassword(network.ssid, network.security)
                else {
                    statusLabel.set_label(`Подключение к «${network.ssid}»…`)
                    try {
                        run(["nmcli", "--wait", "25", "device", "wifi", "connect", network.ssid, "ifname", interfaceName])
                        statusLabel.set_label(`Подключено к «${network.ssid}»`)
                        refresh(false)
                    } catch (error) { statusLabel.set_label(String(error)) }
                }
            })
            row.append(button)
            networkList.append(row)
        }
        if (!rescan) statusLabel.set_label(`${networks.length} сетей поблизости`)
    } catch (error) {
        statusLabel.set_label(String(error))
    }
}

function createWindow() {
    if (window) { window.present(); return }
    window = new Gtk.Window({ application: app, title: "Wi-Fi", decorated: false, resizable: false, default_width: 500, default_height: 560 })
    window.add_css_class("sound-window")
    const panel = new Gtk.Box({ orientation: Gtk.Orientation.VERTICAL, spacing: 12 })
    panel.add_css_class("sound-panel")
    const header = new Gtk.Box({ orientation: Gtk.Orientation.HORIZONTAL, spacing: 10 })
    const heading = new Gtk.Label({ label: "Wi-Fi", xalign: 0, hexpand: true })
    heading.add_css_class("window-title")
    const refreshButton = new Gtk.Button({ label: "Обновить" })
    refreshButton.add_css_class("mixer-button")
    refreshButton.connect("clicked", () => refresh(true))
    const closeButton = new Gtk.Button({ label: "×" })
    closeButton.add_css_class("close-button")
    closeButton.connect("clicked", () => window?.close())
    header.append(heading)
    header.append(refreshButton)
    header.append(closeButton)
    statusLabel = new Gtk.Label({ label: "Доступные сети", xalign: 0 })
    statusLabel.add_css_class("wifi-subtitle")
    networkList = new Gtk.Box({ orientation: Gtk.Orientation.VERTICAL, spacing: 8 })
    const scroll = new Gtk.ScrolledWindow({ min_content_height: 420, hscrollbar_policy: Gtk.PolicyType.NEVER, vscrollbar_policy: Gtk.PolicyType.AUTOMATIC, vexpand: true })
    scroll.set_child(networkList)
    panel.append(header)
    panel.append(statusLabel)
    panel.append(scroll)
    window.set_child(panel)
    window.connect("close-request", () => { window = null; return false })
    window.present()
    refresh(false)
    GLib.timeout_add(GLib.PRIORITY_DEFAULT, 900, () => {
        if (window) refresh(true)
        return GLib.SOURCE_REMOVE
    })
}

app.start({ css: style, main: createWindow })
