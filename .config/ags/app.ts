import app from "ags/gtk4/app"
import Gtk from "gi://Gtk?version=4.0"
import GLib from "gi://GLib"
import Wp from "gi://AstalWp"
import style from "./style.scss"

const wp = Wp.get_default()
const audio = wp.audio

let window: Gtk.Window | null = null

function deviceName(device: any): string {
    return device?.description || device?.name || "Audio device"
}

function createVolumeSection(
    title: string,
    icon: string,
    devices: any[],
    current: any,
): Gtk.Box {
    const section = new Gtk.Box({
        orientation: Gtk.Orientation.VERTICAL,
        spacing: 10,
    })
    section.add_css_class("audio-section")

    const heading = new Gtk.Box({
        orientation: Gtk.Orientation.HORIZONTAL,
        spacing: 10,
    })

    const iconLabel = new Gtk.Label({ label: icon })
    iconLabel.add_css_class("device-icon")

    const titleLabel = new Gtk.Label({
        label: title,
        halign: Gtk.Align.START,
        hexpand: true,
    })
    titleLabel.add_css_class("section-title")

    const muteButton = new Gtk.Button({ label: "Mute" })
    muteButton.add_css_class("mute-button")

    const slider = Gtk.Scale.new_with_range(
        Gtk.Orientation.HORIZONTAL,
        0,
        1,
        0.01,
    )
    slider.set_hexpand(true)
    slider.set_draw_value(false)
    slider.add_css_class("volume-slider")

    const valueLabel = new Gtk.Label({ label: "0%", width_chars: 4 })
    valueLabel.add_css_class("volume-value")

    let device = current ?? devices.find((item) => item.is_default) ?? devices[0] ?? null
    let volumeHandler = 0
    let muteHandler = 0
    let descriptionHandler = 0

    const updateDevice = (next: any) => {
        if (!next) return

        if (device) {
            if (volumeHandler) device.disconnect(volumeHandler)
            if (muteHandler) device.disconnect(muteHandler)
            if (descriptionHandler) device.disconnect(descriptionHandler)
        }

        device = next
        slider.set_value(device.volume || 0)
        valueLabel.set_label(`${Math.round((device.volume || 0) * 100)}%`)
        muteButton.set_label(device.mute ? "Unmute" : "Mute")
        muteButton.set_sensitive(true)

        volumeHandler = device.connect("notify::volume", () => {
            const value = device.volume || 0
            if (Math.abs(slider.get_value() - value) > 0.001) {
                slider.set_value(value)
            }
            valueLabel.set_label(`${Math.round(value * 100)}%`)
        })

        muteHandler = device.connect("notify::mute", () => {
            muteButton.set_label(device.mute ? "Unmute" : "Mute")
            muteButton.set_css_classes(
                device.mute ? ["mute-button", "muted"] : ["mute-button"],
            )
        })

        descriptionHandler = device.connect("notify::description", () => {
            const index = devices.findIndex(
                (item) => String(item.id) === String(device.id),
            )
            if (index >= 0) selector.set_selected(index)
        })
    }

    slider.connect("value-changed", () => {
        if (!device) return
        const value = slider.get_value()
        device.volume = value
        valueLabel.set_label(`${Math.round(value * 100)}%`)
    })

    muteButton.connect("clicked", () => {
        if (device) device.mute = !device.mute
    })

    const selectorModel = Gtk.StringList.new(
        devices.length > 0
            ? devices.map((item) => deviceName(item))
            : ["Устройство не найдено"],
    )
    const selector = Gtk.DropDown.new(selectorModel, null) as Gtk.DropDown
    selector.add_css_class("device-select")
    selector.set_hexpand(true)
    selector.set_sensitive(devices.length > 1)
    const currentIndex = Math.max(
        devices.findIndex(
            (item) => String(item.id) === String(device?.id),
        ),
        0,
    )
    selector.set_selected(currentIndex)

    selector.connect("notify::selected", () => {
        const selected = devices[selector.get_selected()]
        if (!selected) return
        updateDevice(selected)
        selected.is_default = true
    })

    if (device) updateDevice(device)
    else {
        slider.set_sensitive(false)
        muteButton.set_sensitive(false)
        selector.set_sensitive(false)
    }

    heading.append(iconLabel)
    heading.append(titleLabel)
    heading.append(muteButton)
    section.append(heading)
    section.append(selector)

    const controls = new Gtk.Box({
        orientation: Gtk.Orientation.HORIZONTAL,
        spacing: 12,
    })
    controls.add_css_class("volume-controls")
    controls.append(slider)
    controls.append(valueLabel)
    section.append(controls)

    return section
}

function createSoundWindow() {
    if (window) {
        window.present()
        return
    }

    const speakers: any[] = Array.from(audio.speakers || [])
    const microphones: any[] = Array.from(audio.microphones || [])

    window = new Gtk.Window({
        application: app,
        title: "Sound",
        decorated: false,
        resizable: false,
        default_width: 460,
        default_height: 390,
    })
    window.add_css_class("sound-window")

    const panel = new Gtk.Box({
        orientation: Gtk.Orientation.VERTICAL,
        spacing: 14,
    })
    panel.add_css_class("sound-panel")

    const header = new Gtk.Box({
        orientation: Gtk.Orientation.HORIZONTAL,
        spacing: 10,
    })

    const title = new Gtk.Label({
        label: "Звук и микрофон",
        halign: Gtk.Align.START,
        hexpand: true,
    })
    title.add_css_class("window-title")

    const mixerButton = new Gtk.Button({ label: "Микшер" })
    mixerButton.add_css_class("mixer-button")
    mixerButton.connect("clicked", () => {
        GLib.spawn_command_line_async("pavucontrol")
    })

    const closeButton = new Gtk.Button({ label: "×" })
    closeButton.add_css_class("close-button")
    closeButton.connect("clicked", () => window?.close())

    header.append(title)
    header.append(mixerButton)
    header.append(closeButton)
    panel.append(header)

    panel.append(
        createVolumeSection(
            "Вывод звука",
            "󰓃",
            speakers,
            audio.default_speaker,
        ),
    )

    panel.append(
        createVolumeSection(
            "Микрофон",
            "󰍬",
            microphones,
            audio.default_microphone,
        ),
    )

    window.set_child(panel)
    window.connect("close-request", () => {
        window = null
        return false
    })
    window.present()
}

app.start({
    css: style,
    main() {
        const hasDevices =
            Array.from(audio.speakers || []).length > 0 ||
            Array.from(audio.microphones || []).length > 0

        if (hasDevices) {
            createSoundWindow()
            return
        }
        wp.connect("ready", () => createSoundWindow())
    },
})
