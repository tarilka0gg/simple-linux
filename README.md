# Simple Linux

A small Gentoo-based live system with its own installer. Two bootable images, the stage3 they
install from, the kernel, and the desktop setup the GUI image boots into.

The installer and the scripts that build all of this live in
[gentoo-installer](https://github.com/tarilka0gg/gentoo-installer) (GPL-2.0-or-later). This repository
holds what comes out of that build, and the parts that are configuration rather than code.

## Downloads

Everything large is attached to the **Releases** page (GitHub will not take files over 100 MB in git).
`SHA256SUMS` lists all of them.

| File | Size | What it is |
|---|---|---|
| `simple-linux-minimal.iso` | 1.3 GB | text installer (TUI), rescue tools, firmware |
| `simple-linux-gui.iso` | 1.8 GB | the same plus a niri + Noctalia desktop, Zen, Thunar, GParted, PipeWire, with a graphical installer |
| `simple-linux-stage3-amd64-openrc.tar.xz` | 240 MB | the stage3 the installer unpacks (also already inside both ISOs) |
| `simple-linux-kernel-7.1.8.vmlinuz` | 13 MB | the live kernel |
| `simple-linux-kernel-7.1.8-modules.tar.xz` | 12 MB | its modules (`lib/modules/7.1.8-cachyos1`) |

Both ISOs boot on BIOS and UEFI (Limine). Current version: **0.1.2**. (0.1.0 did not start on the first laptop it was tried on; 0.1.1 fixed the boot; 0.1.2 fixes the installer itself, see below.) There is no Secure Boot support and nothing is signed.

## Try it

In a VM: `qemu-system-x86_64 -enable-kvm -m 4096 -cdrom simple-linux-minimal.iso` (add an OVMF pflash for UEFI).

On a stick (this erases the stick — check the device name first):

```
sha256sum -c --ignore-missing SHA256SUMS
sudo dd if=simple-linux-gui.iso of=/dev/sdX bs=4M status=progress conv=fsync
```

The live system logs in as `root` automatically (empty password) and starts the installer. The GUI image
starts a niri session with the installer window; **niri refuses software rendering**, so on a machine
without hardware-accelerated graphics the GUI image falls back to the text installer after ~25 seconds
(log: `/var/log/niri-session.log`). DHCP runs at boot; Wi-Fi is `iwd` (`iwctl`, the Noctalia network
widget, or the TUI's network screen).

## If it does not start on your machine

Limine shows a menu for 5 seconds. Try the entries in this order and note which one works:

1. **Simple Linux (live)** - the default, screen only, kernel and dracut messages visible.
2. **USB workaround** - for `usb X-Y: device descriptor read/64, error -71`, the classic enumeration failure
   (it helps most when the boot stick sits in the failing port; also try another port, USB 2 if you have one).
3. **safe graphics (nomodeset)** - if the screen goes black after the kernel starts; you get the text installer.
4. **verbose** - every kernel and initramfs message, and a shell if the live medium is not found.
5. **serial console** - only if you have a serial cable.

`[Firmware Bug]: TSC_DEADLINE disabled ... please update microcode` and `error -71` on some USB port are
warnings on their own; if boot stops, the lines *after* them (use entry 4) say why. Version 0.1.0 had a
console setting that hid those lines on laptops with a phantom serial port; 0.1.1 fixes that and loads CPU
microcode early. **No image has been run on real hardware by the author yet** - reports of what the verbose
entry prints on a failing machine are the most useful thing you can send.

## What 0.1.2 changed (installer)

A full install through the text installer was run in a VM for the first time (network → disk → account → confirm, with the
desktop and the Wi-Fi group), rebooted, and the installed disk booted and logged in. That found and fixed: the text installer had
**no screen to create a user** (now it has one); it **hid errors** (a failed step left the screen frozen on the last line); it
read the wm-configs URL from the wrong variable; the **reboot button called `systemctl`** (this system is OpenRC; now `reboot`);
**no service was enabled on the installed system** (`dbus`, `seatd`, `iwd` now are, with the user in `seat`, `video`, `render`,
`input`, `audio`); **fish ignored the desktop autostart** and **`/run/user/<uid>` was never created**. Still unseen: a picture of the
installed desktop (the VM's virtual GPU has no driver in the installed Mesa) and any real hardware.

## What is in the images

- **Base**: Gentoo stage3 (OpenRC, 2026-09-27), kernel 7.1.8 (the CachyOS-patched tree, a generic config), dracut
  live boot with OverlayFS, `fish` as root's shell with `eza`/`dust`/`gping`/`micro` aliases, no `nano`.
- **Firmware and rescue kit**: `linux-firmware` (pruned to laptop/desktop hardware), `sof-firmware`,
  microcode; `xfsprogs`, `ntfs-3g`, `exfatprogs`, `f2fs-tools`, `cryptsetup`, `lvm2`, `mdadm`, `testdisk`,
  `ddrescue`, `smartmontools`, `nvme-cli`, `hdparm`, `usbutils`, `dmidecode`, `htop`, `tmux`, `tcpdump`, ….
- **GUI image only**: niri 26.04, Noctalia 5.2.0, Zen Browser, Thunar (gvfs, tumbler), GParted, PipeWire +
  WirePlumber, ghostty, `btop`, `imv`, `wl-clipboard`.
- Package lists (`category/name-version`, from the image's package database): `packages/minimal.txt`,
  `packages/gui.txt`. They include packages that were needed to *build* the image; their compilers, headers
  and documentation were left out of the squashfs, so the list is longer than what is on disk.

## Files in this repository

| Path | |
|---|---|
| `profile/` | the desktop setup the GUI image boots into: niri config, Noctalia config and settings (bar, dock, theme), community palettes. Derived from the author's own setup with machine- and person-specific parts removed (start-up services and scripts, monitors, home address, wallpaper paths, history) |
| `kernel/config-7.1.8-cachyos1-live` | the full kernel `.config` of the shipped kernel |
| `kernel/kernel-live.fragment` | the options added on top of `x86_64_defconfig` |
| `packages/` | installed-package lists |
| `SHA256SUMS` | checksums of the release files |

## What has and has not been tested

Tested, in QEMU/KVM: both ISOs boot on BIOS and UEFI, as a CD and as a USB stick (minimal); the GUI image
reaches the niri session with the installer, Thunar, Zen and PipeWire running on a virtual 3D GPU; a full
headless install from the minimal image onto a blank virtual disk, after which the installed system boots
on its own, and the created user logs in with fish, btrfs subvolumes and `/boot` mounted, `doas` installed.

**Not tested: any real hardware.** Also not done: a real package store with real per-hardware kernels (the
install test used this same generic kernel), the desktop/GPU-driver steps of the installer on a real
target, LUKS in the installer, Secure Boot. Treat it as an early build.

## Licence

See [NOTICE.md](NOTICE.md). The files in this repository (configuration and documentation) are
GPL-2.0-or-later, like the installer; the images contain many packages under their own licences.
