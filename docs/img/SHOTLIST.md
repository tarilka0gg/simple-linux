# Screenshots for the 0.2.22 changelog

Files go in `docs/img/0.2.22/` under exactly these names (the changelog already links them). PNG for stills, GIF for the one animation.
Keep every file under ~2 MB (GIF under ~5 MB).

## Setup, once

- Image: the newest `simple-linux-gui.iso` (the one with the installer centring fix and Zen tiling).
- VM, fullscreen on a 16:9 screen (2560x1440 or 1920x1080), **no window frame, no host menu bar, no terminal visible** unless the shot says so.
  Disk must be NVMe or SATA (the kernels have no virtio): `~/gentoo-installer-test/vm/sl-test/run.sh` does that.
- Boot takes ~2 minutes. Wait until the installer window is in the middle of the screen.
- Wallpaper: use the blue glowing Gentoo logo, `~/Pictures/Wallpapers/simple/wallhaven-497j8w.jpg`
  (picker: Ctrl+Alt+T, or `noctalia msg wallpaper-set <path>` in a terminal). Second wallpaper for `two-wallpapers.png`: `wallhaven-43jw2v.png` (lavender).
- Caution: the installer window takes keyboard focus. Typing while it has focus goes into the installer, not a terminal.
  Close it first (Mod+Q) when you need a terminal; reopen with `live-installer`.
- Host screenshot of just the VM window with niri: `niri msg action screenshot-window`.

## Shots

| File | What is on the screen | How |
|---|---|---|
| `welcome.png` | Installer welcome page, centred, wallpaper = blue Gentoo logo. Bar and dock visible, nothing else. | Fresh boot, nothing touched. |
| `two-wallpapers.png` | Two desktops side by side (left blue wallpaper, right lavender): same installer, different colours. | Take the welcome shot with each wallpaper (reopen with `live-installer` after changing it), join them with ImageMagick: `magick a.png b.png +append -resize 2000x two-wallpapers.png`. |
| `software.png` | The Software page (list of switches), all on. | Press Start (or Enter on the welcome page). |
| `partitions.png` | The summary page with the partition bar: ESP, swap, `/`, `/home`. | Walk the wizard to the summary with a 60 GiB disk. Do **not** start the install. |
| `progress.gif` | The Installing page, steps ticking, bar rising, log scrolling. ~40 s, 10-12 fps, 1280 px wide. | Close the installer, then in a terminal: `GENTOO_INSTALLER_SIMULATE_SLOW=8 live-installer --debug-progress` and close the terminal (`exit`) before recording. Record the VM window (`wf-recorder -g "$(slurp)" -f p.mp4`), then `ffmpeg -i p.mp4 -vf "fps=12,scale=1280:-1:flags=lanczos,split[a][b];[a]palettegen[p];[b][p]paletteuse" progress.gif`. |
| `bar.png` | Close-up of the floating capsule bar (crop of the top 90 px, full width). Wallpaper behind it. | Any desktop shot, crop: `magick desk.png -crop 100%x90+0+0 bar.png`. |
| `overview.png` | Niri overview (Mod+Tab) with the blurred wallpaper behind the workspaces; installer window in it. | Press Mod+Tab. |
| `terminal.png` | One ghostty window, centred, running `fastfetch`, the tide prompt (icon, path, dotted line, clock) visible. Nothing else on screen. | Close the installer, Mod+Return, type `fastfetch`. |
| `portage-store.png` | Portage Store, explore page with the coloured category tiles; some icons loaded. | Launcher -> Portage Store. First start downloads the tree (88 MB, 1-2 min); wait for the grid to fill. |
| `zen.png` | Zen Browser full width, tiled (not a small floating window). Any start page. | Launcher -> Zen. The first start downloads the browser (~100 MB). |

## Checks before you keep a shot

- No personal data: host desktop, notifications, clipboard, your username.
- The clock and the date in the bar are fine, but no Noctalia warning toast in a corner.
- Same wallpaper and palette across the shots (except `two-wallpapers.png`).
