# Changelog

What changed in each Simple Linux release, newest first. The images, the installer and the configuration are versioned together;
the installer's own code history is in [gentoo-installer](https://github.com/tarilka0gg/gentoo-installer).
Downloads and checksums are on the [Releases](https://github.com/tarilka0gg/simple-linux/releases) page.

## 0.2.22

Built and tested in QEMU:

### In pictures

![The installer, in the colours of the wallpaper](docs/img/0.2.22/welcome.png)
*The installer starts after Noctalia has drawn the wallpaper, so it opens in the wallpaper's palette. Same image, other wallpaper: the colours follow.*

![The same desktop with a different wallpaper](docs/img/0.2.22/two-wallpapers.png)

![The Software page](docs/img/0.2.22/software.png)

![Disk summary: / and /home](docs/img/0.2.22/partitions.png)
*`/` and `/home` on separate partitions (here a 60 GiB disk: 40 % / 60 %).*

![The installing page](docs/img/0.2.22/progress.gif)
*The Installing page (simulated run): every step with its time, what is happening now, a progress bar and the live log.*

![The floating bar](docs/img/0.2.22/bar.png)

![The overview with the blurred wallpaper](docs/img/0.2.22/overview.png)

![Terminal with the tide prompt and fastfetch](docs/img/0.2.22/terminal.png)

![Portage Store](docs/img/0.2.22/portage-store.png)
*Portage Store: category tiles in the wallpaper's palette; icons come from Flathub.*

![Zen Browser, tiled](docs/img/0.2.22/zen.png)

- **Binary install.** The installer adds [simple-linux-binhost](https://github.com/tarilka0gg/simple-linux-binhost) as a second binary host (signed, higher priority than Gentoo's),
  trusts its key the way `getuto` trusts Gentoo's, and unpacks the Portage tree snapshot the packages were built against instead of the day's tree. `make.conf` no longer sets this
  machine's `CPU_FLAGS_X86` or an unusual `VIDEO_CARDS` in binary mode (they made Gentoo's binaries mismatch and Portage compiled `mesa`, `pixman`, ...), and a `cpuid2cpuflags` bug
  that put the variable's name into the value is fixed. Packages are merged in parallel (`--jobs`). Optional groups state the USE they need (Qt `opengl`, `qml`, ...); `*/*::guru ~amd64`
  fixes the install that stopped on `mangohud`'s GURU dependencies; `DONT_MOUNT_BOOT` fixes `linux-firmware` aborting in the chroot.
- **The installer shows progress.** The Installing page lists every step (tick, spinner, cross, time taken), says what is happening now (a download in MB, "package 3 of 31"), has a bar
  with percent and elapsed time, and the log is open and follows the newest line; it now includes what the commands print.
- **`/` and `/home` on separate partitions.** After ESP and swap the system gets 20 % (40 % on a disk under 128 GiB, never under 20 GiB), `/home` the rest, so a full home cannot starve the system.
  On a disk with less than 40 GiB left after swap everything stays in root.
- **The wallpaper's colours reach the programs.** niri's ring and borders, ghostty, btop, GTK 3/4 (with `adw-gtk3`), Qt programs (`qt6ct`, KDE colour scheme), yazi, fuzzel, Neovim, Zen, Telegram (the theme file is written, choosing it is one click in Telegram), micro, tmux, fastfetch, GIMP; Noctalia starts after the wallpaper is chosen,
  so there is no flash of the wrong theme. The installed system gets the same, with the project's wallpapers and a random one at every start. (`simple-linux-configs`: `apps/`, `noctalia/hooks/`.)
- **Touchpads work.** The live kernel had only `I2C_HID_ACPI`: on a laptop whose touchpad hangs off the chipset's Serial IO I2C bus (the HP Victus' `SYNA32E3`, most
  laptops since about 2019) no input device appeared at all. It now has the Intel Serial IO (`MFD_INTEL_LPSS`, `I2C_DESIGNWARE`), GPIO (`PINCTRL` Intel and AMD), `HID_MULTITOUCH`, RMI4, Elan, THC/QuickI2C
  and sensor-hub drivers (+4.6 MiB image, all of them load in a VM; **the touchpad itself is not confirmed on real hardware yet**). The generic store kernels (x86-64 v2/v3) lacked them too and are rebuilt;
  the Raptor Lake builds already had them.
- **Ghostty takes the wallpaper's colours.** Its starting config also loads Noctalia's theme file as a `config-file`, which wins over colours set by hand, and the Noctalia start script
  creates the ghostty config if a system lacks one.
- **Enter works on the account page** (username, password, confirmation, Continue).
- **Secure Boot for the installed system** (off by default): a key made on the machine, Limine and its config signed and pinned; the certificate is put in `/boot/secureboot/` to enrol.
  **`simple-linux-update`** updates the kernel (the old one stays as a boot entry) and runs `emerge` for the system.
- **Live image.** The look no longer pins the author's palette, wallpaper folder or niri colours: everything is generated from the wallpaper.
  - The installer starts after Noctalia has drawn the wallpaper, so it comes up in the wallpaper's colours; it is titled "Simple Linux Installer".
  - The bar floats (Noctalia 5.2 names its margins `margin_edge`/`margin_ends`; the old `margin_h`/`margin_v` were silently ignored) and uses the capsule layout; the overview shows the blurred wallpaper.
  - Zen opens tiled and maximized, and its dock entry is the one that downloads the browser.
  - Portage Store is in the launcher. On its first start it downloads the Portage tree snapshot (88 MB) and builds its search index; its category tiles follow the wallpaper palette. App icons come from Flathub, so only apps that exist there get one.
  - The terminal prompt is [tide](https://github.com/IlanCosman/tide) in the palette's colours with a JetBrainsMono Nerd Font; the hostname is `simple-linux-live`.
  - On real hardware every monitor is set to its highest resolution and refresh rate at start (not in a VM).
  - One wallpaper (the penguin with stripes) is removed.
- **Smaller image:** build-only tools (cmake, cargo-c, ...), static libraries, development data, phone/router-only Wi-Fi firmware and a second copy of the CPU microcode are no longer in the live image (about 125 MiB).

Checked: headless installs in a VM (default groups and every group, 261 and 263 binary merges, nothing compiled), the installed system booting and starting niri on a virtual 3D GPU with
the terminal, Thunar, fastfetch and the panel in the wallpaper's colours. The GUI image is 636 MiB (0.2.21: 760), the minimal 434, the kernel store 248 (the generic builds are now configs for real hardware: NVMe/SATA built in, no virtio, so a VM disk must be NVMe or SATA).
**Nothing has to be configured.** The kernels are the assets of the `kernels` release of [simple-linux-binhost](https://github.com/tarilka0gg/simple-linux-binhost) (ten builds and a `Packages` index), the packages and the Portage tree snapshot are there too, and the configs come from simple-linux-configs: all defaults of the installer (`GENTOO_STORE_BINHOST_URL` and the others only override them). A headless install from the released GUI image on an NVMe disk with only the disk and the user set took the kernel and packages from GitHub, compiled nothing, and the installed system booted to a login. **Not checked:** the graphical wizard end to end with these changes (the headless run uses the same phases, not the same
screens), Secure Boot of the installed system under OVMF, any real hardware.

## 0.2.21

- **Launcher and dock.** The dock pins the Zen Browser entry that downloads the browser (not the empty `zen-zen-bin` one); Noctalia, Panel, About Xfce, the Thunar helpers and the console tools (btop, Micro) are hidden from the launcher. Application icons are glyph-style (symbolic) and Noctalia recolours them to the wallpaper palette; the full-colour icon sets only gave solid blobs when recoloured.
- **Colours follow the wallpaper everywhere:** the focus ring and window borders of niri come from the same palette (`noctalia.kdl`). The random wallpaper is requested until Noctalia has really applied one (it could be missed at start). The deprecated `middle_click_opens_widget_settings` line, which showed a notification, is gone.
- **Wallpapers:** 17 left (the Dragon Ball one and a 5120x1440 ultrawide are removed). Checked in QEMU only. The minimal image is unchanged.

## 0.2.20

- **A different wallpaper on every start, and the colours follow it.** The graphical session picks a random wallpaper from `~/Pictures/Wallpapers/simple` when it starts, and Noctalia generates the palette from it (Material You, `m3-tonal-spot`, light); GTK 3/4 apps and the installer use that palette. Replaces the fixed Gruvbox look of 0.2.19: the GTK theme is plain Adwaita, the niri borders are neutral.
- **The installer has a launcher entry** (`Install Simple Linux`, with an icon), so the dock and launcher no longer show the raw app id. Icons are WhiteSur. Checked in QEMU only: the random pick itself was seen to run, a change of palette between starts was not looked at on screen. The minimal image is unchanged.

## 0.2.19

- **Gruvbox in the graphical image.** Noctalia uses its built-in Gruvbox palette (light), which also recolours GTK 3/4 apps, the installer, the terminal and btop; niri's focus ring and borders use Gruvbox colours. The GTK theme is Gruvbox-Light.
- **WhiteSur icons.** The images only had Adwaita, so the installer and apps showed generic icons; the WhiteSur icon theme is now installed and set as the default (also through a GSettings default, since GTK 4 reads that before `settings.ini`). Application icons in the dock are no longer recoloured to one colour. Checked in QEMU (UEFI): the installer shows the Gruvbox colours and WhiteSur icons. The minimal image is unchanged.

## 0.2.18

- **Simple Linux wallpapers in the graphical image.** 19 wallpapers are in `~/Pictures/Wallpapers/simple` of the live session (`wallpapers/simple/` in this repo); the wallpaper picker (Ctrl+Alt+T) shows them in the `simple` folder. The minimal image is unchanged from 0.2.17.

## 0.2.17

- **ustan 0.2.2 is in both images** (it was a build from before 0.2.1): AppImages start without FUSE 2 and a launcher that dies right away shows its last output instead of failing silently.
- **Ventoy normal mode finds the image by itself.** If no device carries the label `GENTOO_LIVE` (a bootloader that Ventoy chain-loads, a kernel that only sees the USB stick), the initramfs now mounts the drives read-only, looks for an `.iso` with that volume label (up to three directories deep) and attaches it as a loop device, saying so on the console instead of waiting silently. Nothing changes when the label is already there (a real CD, Ventoy's grub2 mode). `rd.iso.autoscan=0` turns it off. Checked in QEMU on a real Ventoy 1.1.17 exFAT stick image and with Ventoy's own menu in UEFI; not yet confirmed on the laptop that showed the stall.

## 0.2.16

- **The installer inside the images is the current one.** The 0.2.14 and 0.2.15 images were built from an older build of the graphical installer, without the later changes (the software step in the normal flow, working search in the keyboard and timezone lists, uniform icon badges). Nothing else differs from 0.2.15. Checked in QEMU: both images boot from Ventoy (BIOS and UEFI, normal mode) and written straight to a stick (BIOS, UEFI, Secure Boot).

## 0.2.15

- **Ventoy works in BIOS without choosing a mode.** The BIOS stage of Limine in the images is rebuilt with a one-line patch (`iso/patches/limine-12.3.3-ventoy-bios.patch` in gentoo-installer; `iso/build-limine-bios.sh` makes it): Ventoy's virtual CD is a 2048-byte-sector drive that is neither flagged removable nor ATAPI, so stock Limine skipped it and stopped with "Could not determine boot drive". The BIOS config also no longer pins file hashes (only Secure Boot on UEFI needs them), which fixes the `Blake2b hash … does not match` panic that one tester saw when starting the image from Ventoy on BIOS. Checked in QEMU with Ventoy 1.1.17: BIOS and UEFI, normal mode and grub2 mode, for both images; and written straight to a stick on BIOS, UEFI and Secure Boot.
- **Zen Browser downloads in the background** as soon as the graphical session starts (no terminal window any more); opening it earlier just waits for the download.

## 0.2.14

- **portage-store is in the GUI image and in an installed desktop.** The installer copies it from the live system (programs under `/usr/local`, the helper in `/usr/libexec/portage-store/`). It adds one passwordless `doas` rule for the wheel group, limited to that helper: `permit nopass :wheel cmd /usr/libexec/portage-store/priv-helper`. `GENTOO_INSTALLER_STORE=0` skips the whole thing. The minimal image does not have it (no GTK).

## 0.2.13

- **The installed system matches the GUI image.** The default package groups now include everything the GUI live image has (file manager, audio, desktop utilities, disk tools, hardware tools, Gentoo tools). The browser group installs Zen, as the image does. Expect a much larger default install (about 186 packages, ~800 MB of downloads, some compiling); untick groups you do not want.
- **`btop` instead of `htop`, and `fastfetch`,** in both images and in the installed system.

## 0.2.12

- **root has fish as its login shell** on the installed system (and, when the desktop presets are installed, the same fish setup as the user). The account is still locked: this is the shell for `su`, `doas -s` or a rescue login. Checked in a VM: `/etc/passwd` of the installed system has `root:…:/usr/bin/fish`.

## 0.2.11

- **Your fish is installed with the system.** The installer copies the author's fish setup (the tide prompt with his settings, fisher, sponge, autopair, `config.fish`) into the new user's `~/.config/fish` when the system has fish. The configs live in [simple-linux-configs](https://github.com/tarilka0gg/simple-linux-configs) (the repository that used to be `gentoo-wm-configs`; the old address redirects). The live image uses it by default, so a desktop install no longer needs `GENTOO_WM_CONFIGS_URL` to be set by hand.
- tide draws its icons with a Nerd Font: use a terminal with one (the plain Linux console shows squares).

## 0.2.10

- **ustan is also installed on the system you install.** The installer copies it from the live image into `/usr/local` of the new system (the `ustan` command always; the window and its menu entry when a desktop was installed). Skip it with `GENTOO_INSTALLER_USTAN=0` in the headless mode. It is not part of Portage, so it is not updated with the system.

## 0.2.9

- **ustan is in the images.** [ustan](https://github.com/tarilka0gg/ustan) installs a .deb, an AppImage, a Flatpak bundle or a Windows .exe from a window (or `ustan install <file>`). The GUI image has `ustan-gui` with a menu entry, the minimal image the `ustan` command.

## 0.2.8

- **The graphical installer starts much sooner on machines without 3D** (old or unsupported GPUs, most VMs): ~9 s after the kernel starts instead of ~31 s (measured in QEMU). The live session used to wait a fixed 25 s for niri; it now checks for a 3D-capable GPU driver and goes straight to the software-rendered window when there is none. With a 3D GPU nothing changes except that it no longer waits.
- The boot menu waits 3 s instead of 5.

## 0.2.7

- **Smaller again** (minimal 652 → 514 MiB, gui 880 → 734 MiB): the root image no longer holds a second copy of the initramfs and the microcode images; Intel microcode for the newest server-only CPUs (Granite/Sierra/Emerald Rapids, Grand Ridge) is gone (Sapphire Rapids and everything older stays; such a CPU still boots on the firmware's microcode); Python keeps only what `equery` needs.

## 0.2.6

- **EROFS instead of squashfs for the root image** (LZMA, 1 MiB clusters): about 120 MiB smaller. The live kernel has EROFS built in (the kernel file in this release replaces the earlier one). Boot is about 2 s slower to reach the services, measured in a VM.
- **OpenRC starts services in parallel** (`rc_parallel`), which gives back about 1.5 s of that.

## 0.2.5

- **Smaller again** (minimal 851 → 747 MiB, gui 1227 → about 1000 MiB): Zen Browser and the NVIDIA GSP firmware are no longer on the medium.
- **Zen is downloaded on first use.** The GUI image has a "Zen Browser" entry (and `get-zen`) that fetches the current release from Zen's GitHub page (~110 MB, HTTPS, no checksum is published there) and runs it. Without that firmware the live GUI on RTX 20xx and newer cards runs in software (the cage fallback); the installed system is not affected.

## 0.2.4

- **The stage3 is downloaded, not shipped** (minimal 1091 → 851 MiB, gui 1467 → 1227 MiB). The images set `GENTOO_INSTALLER_STAGE3_URL` to the latest release's stage3 and the installer verifies it against the `.sha512` published next to it. A full install in a VM did this, and the installed system had fish, eza and micro, no nano. For use without a network you need your own image: `STAGE_TARBALL=… iso/assemble-iso.sh` (see the installer repository).

## 0.2.3

- **Smaller:** the Rust and Zig toolchains that were only needed to build the image are no longer in it (minimal 1202 → 1091 MiB, gui 1634 → 1467 MiB, even with the additions below).
- **More tools** (also in the GUI image), picked from the official Gentoo minimal CD's list: `gptfdisk` (gdisk/sgdisk), `iw` and `wpa_supplicant`, `nmap` (with ncat and nping) and `traceroute`, `eix` and `gentoolkit` (`equery`; Python is in the image for it), `screen`, and **Memtest86+** (two boot-menu entries, BIOS and UEFI; under Secure Boot the UEFI one is refused by the firmware since it is unsigned). The Portage tree is not on the medium, so `eix`/`equery` are only useful once you have one.

## 0.2.2

- **The installer now starts on older CPUs.** `installer-cli`/`installer-gui` were linked on a machine whose libc is built for x86-64-v3, so the binaries carried a "v3 needed" note and the live system refused to run them on anything older than Haswell (Westmere, Sandy/Ivy Bridge Xeons: "CPU ISA level is lower than required"). The images booted fine; only the installer did not start. Fixed, and checked in QEMU with Westmere, Sandy Bridge and a plain `qemu64` CPU, BIOS and UEFI, both images, 1 to 4 CPUs, 1 to 3 GB of RAM.

## 0.2.1

- The images carry a `boot/grub/grub.cfg`, which is what makes them bootable from Ventoy (see above).

## 0.2.0

- **One install path.** The text and graphical installers run the same phase pipeline as `--headless`, and a failed install can be **resumed** (`r` in the text installer, a button in the GUI, `--resume`): done steps are skipped, the rest continue. The VM test of this found that the base-system step could not run twice (it now remembers an unpacked stage and re-fetches the overlay); fixed.
- **Graphics.** Every graphics adapter is detected, `VIDEO_CARDS` covers all of them (hybrid laptops used to get only the discrete GPU's driver; the values are now Gentoo's: `amdgpu radeonsi`, `intel`, `nvidia`, `virgl` in a VM), and the compositor renders on the discrete GPU unless asked otherwise (`GENTOO_INSTALLER_RENDER=integrated`): niri's `render-drm-device`, `WLR_DRM_DEVICES`/`AQ_DRM_DEVICES` for the others, and Noctalia's shared GL context is switched off for the proprietary NVIDIA driver.
- **Language and time zone** follow the keyboard layout (a `ua` keyboard gives `uk_UA` + `en_US` and `Europe/Kyiv`); only unambiguous countries get a zone.
- **Kernels.** The installer picks from a real per-hardware store (`simple-linux-kernel-store.tar`); a full install from the minimal image used `generic-x86-64-v3-none-desktop` from it.
- **Images** are about 8 % smaller (squashfs zstd level 19, 1 MiB blocks); both were booted as a USB stick on BIOS, UEFI and Secure Boot. The GUI image without 3D falls back to a cage-hosted graphical installer, or the text one.
- **Signing**: signed checksums and Secure Boot as above. `GENTOO_INSTALLER_WM=none` installs no desktop.

## 0.1.2 (installer)

A full install through the text installer was run in a VM for the first time (network → disk → account → confirm, with the
desktop and the Wi-Fi group), rebooted, and the installed disk booted and logged in. That found and fixed: the text installer had
**no screen to create a user** (now it has one); it **hid errors** (a failed step left the screen frozen on the last line); it
read the wm-configs URL from the wrong variable; the **reboot button called `systemctl`** (this system is OpenRC; now `reboot`);
**no service was enabled on the installed system** (`dbus`, `seatd`, `iwd` now are, with the user in `seat`, `video`, `render`,
`input`, `audio`); **fish ignored the desktop autostart** and **`/run/user/<uid>` was never created**. Still unseen: a picture of the
installed desktop (the VM's virtual GPU has no driver in the installed Mesa) and any real hardware.
