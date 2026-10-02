<div align="center">

# TheodoreVAC · i3 dotfiles

Arch Linux · X11 · i3 · Polybar

**English** | [Русский](README.ru.md)

</div>

![Desktop](screenshots/desktop.png)

My dark-themed i3 desktop configuration. The repository contains the configs, the installer and the bundled fonts. Package snapshots, screenshots of installed programs and system inventory are not included.

## Contents

- [Features](#features)
- [Installation](#installation)
- [Keybindings](#keybindings)
- [Notes](#notes)
- [License](#license)

## Features

- **i3**: keybindings, US/RU layout, automatic tiling orientation, app autostart.
- **Wallpapers**: `Super+Shift+B` opens a grid of large thumbnails from `~/Wallpapers` (3 columns, card-filling images, cropped previews cached in `~/.cache/wallpaper-thumbs`); the chosen picture is applied immediately and restored on i3 startup. The wallpapers folder must be copied separately — images are not part of the repository.
- **Polybar**: workspaces, window title, keyboard layout, volume, network, date, notification counter with a Do Not Disturb toggle.
- **Notifications**: dunst styled after the theme — dark cards under the bar, rounded corners, urgency-colored frames (blue / grey / pink), progress bars, Papirus icons. History opens in Rofi (`Super+N`) with copy, clear and repeat actions. Volume and microphone show an OSD progress bar; screenshots pop up with a preview thumbnail.
- **Rofi, Picom, Dunst, Alacritty, Yazi, GTK and Fastfetch.**
- **Zsh** with Oh My Zsh and Powerlevel10k, `eza` aliases.
- **X11**: `.xinitrc` and `.Xresources`.

## Installation

### 1. Clone

```bash
git clone https://github.com/TheodoreVAC/.dotfiles-i3wm.git ~/dotfiles
cd ~/dotfiles
```

### 2. Install configs and fonts

```bash
./install.sh
```

Choose an option:

| Option | What it does |
|---|---|
| `1` | Links every config from the repo into `$HOME` and installs the bundled fonts |
| `2` | Dry run — prints the plan without changing anything |
| `3` | Installs missing packages (dunst, rofi, jq, zsh plugins, …), only after your confirmation |
| `q` | Quit |

Existing files are backed up next to their original path as `*.pre-dotfiles.<date-time>` and then replaced with symbolic links to the repository. Fonts are copied to `~/.local/share/fonts`.

The installer never touches `/etc`; the package step only runs when you pick it explicitly.

You can also run the steps directly:

```bash
./scripts/install-configs.sh          # link configs (add --dry-run for a preview)
./scripts/install-deps.sh             # check and install missing packages
./scripts/install-deps.sh --check     # only check, exit code 1 if something is missing
```

### 3. After installation

1. Restart the i3 session (`Super+Shift+r`) so the configs are re-read.
2. Put your wallpapers into `~/Wallpapers`; without them the picker shows an empty-state message, and `default1.png` is used as the fallback background.
3. Open a new terminal so the shell picks up the new `.zshrc`.

### Optional: LightDM greeter

The LightDM configuration lives in `system/`. Apply it manually:

```bash
./scripts/apply-lightdm-greeter.sh
```

The script asks for `sudo`, backs up the previous file and only changes `/etc/lightdm/lightdm-gtk-greeter.conf`.

## Keybindings

`Super` is the main modifier (i3 `Mod4`). `Alt+Shift` switches the keyboard layout between US and RU.

### System

| Key | Action |
|---|---|
| `Super+Return` | Terminal — Alacritty |
| `Super+D` | App launcher — Rofi |
| `Super+T` | File manager — Thunar |
| `Super+Shift+Q` | Close the focused window |
| `Super+Shift+E` | Exit i3 (with confirmation) |
| `Super+Shift+C` | Reload the i3 config |
| `Super+Shift+R` | Restart i3 |
| `Super+F9` | Network connections |
| `Super+F10` | Volume mixer — Pavucontrol |
| `Super+F11` | Show / hide the Polybar tray |
| `Super+F12` | Show / hide the window title in Polybar |
| `Alt+Shift` | Switch layout US ⇄ RU |

### Focus and windows

| Key | Action |
|---|---|
| `Super+J / K / L / ;` | Focus left / down / up / right |
| `Super+← / ↓ / ↑ / →` | Focus left / down / up / right |
| `Super+Shift+J / K / L / ;` | Move the window left / down / up / right |
| `Super+Shift+← / ↓ / ↑ / →` | Move the window left / down / up / right |
| `Super+H` | Split horizontally |
| `Super+V` | Split vertically |
| `Super+F` | Toggle fullscreen |
| `Super+S` | Stacking layout |
| `Super+W` | Tabbed layout |
| `Super+E` | Toggle split layout |
| `Super+Space` | Toggle focus between tiled and floating |
| `Super+Shift+Space` | Toggle floating for the current window |
| `Super+Tab` | Switch to the last workspace |
| `Super+A` | Focus the parent container |
| `Super+Ctrl+← / ↓ / ↑ / →` | Resize the window by 5 px |
| `Super+R` | Enter resize mode: `J/K/L/;` or arrows resize, `Enter`/`Esc`/`Super+R` exits |

### Workspaces

| Key | Action |
|---|---|
| `Super+1 … 0` | Switch to workspace 1–10 |
| `Super+Shift+1 … 0` | Move the current window to workspace 1–10 |
| `Super+Alt+← / →` | Previous / next workspace |

### Notifications

| Key | Action |
|---|---|
| `Super+N` | Notification history in Rofi — copy, clear, repeat the last one |
| `Super+Shift+N` | Clear the notification history |
| `Super+Ctrl+N` | Toggle Do Not Disturb |
| Left click on the Polybar bell | Toggle Do Not Disturb |
| Right click on the Polybar bell | Open the history |
| Middle click on the Polybar bell | Clear the history |
| Click on a notification | Left — run the action and close, middle — close all, right — close |

### Media and screenshots

| Key | Action |
|---|---|
| `F2` / `F3` | Volume −5% / +5% with an OSD progress bar |
| `F4` | Mute / unmute with OSD |
| `XF86AudioRaiseVolume` / `LowerVolume` | Volume ±10% with OSD |
| `XF86AudioMute` / `MicMute` | Mute sound / microphone with OSD |
| `Print` | Full-screen screenshot → `~/Pictures` + clipboard + notification with a preview |
| `Super+Print` | Area screenshot → `~/Pictures` + clipboard + notification |

### Wallpapers

| Key | Action |
|---|---|
| `Super+Shift+B` | Wallpaper picker — a grid of thumbnails from `~/Wallpapers` |

## Notes

- The main modifier is `Super`. The config targets the `HDMI-A-0` output at 1920×1080, 165 Hz — check these values when moving to another machine.
- The last chosen wallpaper is stored by feh and restored on i3 startup; without a previous choice `default1.png` is used.
- Dunst runs as a systemd user service (started automatically through D-Bus activation); the i3 config also launches it on session start.

## License

Adwaita Mono Nerd Font is distributed under the SIL Open Font License; the license text is included in `.local/share/fonts/LICENSE`.
