import app from "ags/gtk4/app"
import { Astal, Gtk } from "ags/gtk4"
import { createBinding, createState } from "ags"
import AstalWp from "gi://AstalWp"

const { TOP, RIGHT, BOTTOM, LEFT } = Astal.WindowAnchor

const wp = AstalWp.get_default()
const audio = wp.audio

const [volume, setVolume] = createState(audio.defaultSpeaker?.volume ?? 0)
const [muted, setMuted] = createState(audio.defaultSpeaker?.mute ?? false)

function VolumeSlider() {
    return (
        <slider
            hexpand
            min={0}
            max={1}
            value={volume}
            onChangeValue={(self) => {
                const speaker = audio.defaultSpeaker
                if (speaker) {
                    speaker.volume = self.value
                    setVolume(self.value)
                }
            }}
        />
    )
}

function AudioMenu() {
    return (
        <box
            class="audio-menu"
            orientation={Gtk.Orientation.VERTICAL}
            spacing={16}
        >
            <box>
                <label
                    class="title"
                    label="Sound"
                    hexpand
                    halign={Gtk.Align.START}
                />

                <button
                    class="mute-button"
                    onClicked={() => {
                        const speaker = audio.defaultSpeaker
                        if (speaker) {
                            speaker.mute = !speaker.mute
                            setMuted(speaker.mute)
                        }
                    }}
                >
                    <label
                        label={muted((value) => value ? "Muted" : "Unmuted")}
                    />
                </button>
            </box>

            <box orientation={Gtk.Orientation.VERTICAL} spacing={8}>
                <box>
                    <label
                        label="Output"
                        halign={Gtk.Align.START}
                        hexpand
                    />

                    <label
                        label={volume((value) =>
                            `${Math.round(value * 100)}%`
                        )}
                    />
                </box>

                <VolumeSlider />
            </box>
        </box>
    )
}

function AudioWindow() {
    return (
        <window
            name="audio"
            class="audio-window"
            anchor={TOP | RIGHT}
            marginTop={60}
            marginRight={20}
            visible
        >
            <AudioMenu />
        </window>
    )
}

app.start({
    requestHandler(request, response) {
        if (request === "toggle") {
            const window = app.get_window("audio")

            if (window) {
                window.visible = !window.visible
                response("toggled")
            }

            return
        }

        response("unknown command")
    },

    main() {
        AudioWindow()
    },
})
