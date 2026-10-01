<div align="center">

# Arch Linux · i3wm · X11

Personal desktop setup focused on a dark interface, keyboard driven window management, and a compact Polybar status bar.

![Arch Linux](https://img.shields.io/badge/Arch_Linux-1793D1?style=for-the-badge&logo=arch-linux&logoColor=white)
![i3wm](https://img.shields.io/badge/i3wm-222222?style=for-the-badge&logo=i3&logoColor=white)
![X11](https://img.shields.io/badge/X11-555555?style=for-the-badge&logo=x.org&logoColor=white)

</div>

![Desktop screenshot](screenshots/desktop.png)

## ✨ What's included

| Component | Role |
| --- | --- |
| **i3** | Tiling, floating windows, key bindings and workspace behavior |
| **Polybar** | Workspaces, window title, audio, Wi-Fi and date |
| **PulseAudio Volume Control** | Standard sound and microphone mixer |
| **NetworkManager editor** | Standard Wi-Fi and connection settings |
| **LightDM GTK Greeter** | Matching dark login screen |
| **Picom** | X11 compositing, shadows and window appearance |
| **Rofi** | Application launcher with a matching dark theme |
| **Alacritty** | Terminal configuration |
| **i3status** | Retained status-line configuration |
| **Fonts** | Adwaita Mono Nerd Font plus Nerd Font symbols |

The repository also contains the Xinit entry point, GTK appearance settings, Fastfetch config, a themed Zsh setup, package manifests, and scripts to install packages and link the dotfiles.

## ⌨️ Key bindings

The main modifier is **Super**.

| Keys | Action |
| --- | --- |
| `Super + Enter` | Open terminal |
| `Super + D` | Open application launcher |
| `Super + T` | Open Thunar |
| `Super + F9` | Open NetworkManager connection settings |
| `Super + F10` | Open the sound and microphone mixer |
| `Super + F11` | Toggle the system tray |
| `Super + F12` | Toggle the active window title in Polybar |
| `Print` | Save a full-screen screenshot and copy it to clipboard |
| `Super + Print` | Select an area, save it and copy it to clipboard |
| `F2` / `F3` / `F4` | Lower / raise / mute audio |

## 🚀 Installation

Review the package manifests and hardware settings before running the scripts.

```bash
git clone https://github.com/TheodoreVAC/.dotfiles-i3wm.git ~/dotfiles
cd ~/dotfiles
./scripts/install-packages.sh --desktop
./scripts/install-configs.sh
```

`--desktop` installs only missing i3/X11, LightDM login screen, audio, network, font, and shell dependencies; it does not upgrade already-installed packages or unrelated applications. The shell profile includes Zsh, Oh My Zsh, the VIA theme, Eza, Yazi, and the configured Zsh plugins. The package script uses pacman for Arch packages and yay for AUR packages. It can bootstrap yay when needed. If pacman reports a version conflict or stale package database, update Arch separately with `sudo pacman -Syu`, then rerun the installer.

To install the broader package set captured from this machine, use `./scripts/install-packages.sh --all` after reviewing `packages/arch-explicit.txt` and `packages/aur-explicit.txt`. This includes unrelated desktop applications and hardware-specific system packages. Dependencies are resolved by pacman/yay; debug split packages and retired panel/tray packages are omitted.

The config installer backs up conflicting files with a timestamped `.pre-dotfiles.*` suffix before linking files from this repo. It installs the included fonts and does not modify `/etc`.

### LightDM login screen

LightDM GTK greeter uses the matching Dracula GTK theme, a solid `#1a202b` background, centered login form, and a compact clock/control panel. After installing the packages, apply its system-wide config with:

```bash
./scripts/apply-lightdm-greeter.sh
```

The script saves the previous greeter config beside itself before installing the new one. It is the only provided script that writes under `/etc`; the regular config linker leaves system files alone. The appearance takes effect at the next login; no reboot is needed.

## 🛠 Machine-specific settings

- The current monitor is `HDMI-A-0`, set to 1920×1080 at 165 Hz in i3 and Polybar.
- The Polybar Wi-Fi label reads the active SSID from NetworkManager; Wi-Fi management opens NetworkManager's connection editor.
- i3 applies `~/Wallpapers/default1.png` with `feh` at startup.
- Polybar gives each workspace number its own color and displays the date directly in the main bar.
- The setup expects an X11 session, NetworkManager, PipeWire/WirePlumber and the listed fonts.

## 📁 Repository map

```text
├── .config/          Active application and desktop configs
├── .local/share/     Included font files and licenses
├── inventory/        Desktop and package notes
├── packages/         Desktop profile and full package manifests
├── screenshots/      Desktop previews
├── scripts/          Package, config and manifest helpers
└── system/           Optional system-wide LightDM greeter config
```

## 🔄 Refresh package manifests

After changing installed software on this machine, run:

```bash
./scripts/capture-package-manifest.sh
```

This only updates package list files in the repository; it does not install or remove software.

## License

Configuration files are shared for personal use and adaptation. Bundled font files remain under their upstream license; see `.local/share/fonts/LICENSE` and `README.md` in that directory.
