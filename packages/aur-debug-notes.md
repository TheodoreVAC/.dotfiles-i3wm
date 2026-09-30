`aur-explicit.txt` excludes split `*-debug` packages. Those debug outputs are produced alongside their corresponding AUR package and are not independent sources to build.

`yay` is included explicitly so a fresh machine can bootstrap it from the AUR if no `yay` command is already installed.
