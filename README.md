# .dotfiles-i3wm

My personal dotfiles for Arch Linux and i3wm.

This is the setup I use on my desktop. Nothing here is meant to be a universal configuration — it's just what works for me.

## What's here

* **i3** — window manager
* **Polybar** — status bar
* **Rofi** — application launcher
* **Alacritty** — terminal
* **Picom** — compositor
* **i3status** — system status
* **Fastfetch** — system info
* **Stalonetray** — system tray

## Structure

```text
.config/
├── alacritty/
├── fastfetch/
├── i3/
├── i3status/
├── picom/
├── polybar/
├── rofi/
└── stalonetray/
```

## Install

Clone the repo:

```bash
git clone https://github.com/TheodoreVAC/.dotfiles-i3wm.git ~/dotfiles
```

Copy the configs:

```bash
cp -r ~/dotfiles/.config/* ~/.config/
```

That's it.

If you already have configs in `~/.config`, make a backup first.

## Updating

After changing something:

```bash
cd ~/dotfiles
git add .
git commit -m "Update config"
git push
```

## Notes

These configs are made for my own setup, so some things may need to be changed depending on your hardware, monitor layout, installed fonts, and applications.

Use whatever you need and change the rest.
