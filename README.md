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
| `simple-linux-gui.iso` | 1.7 GB | the same plus a niri + Noctalia desktop, Zen, Thunar, GParted, PipeWire, with a graphical installer |
| `simple-linux-stage3-amd64-openrc.tar.xz` | 240 MB | the stage3 the installer unpacks (also already inside both ISOs) |
| `simple-linux-kernel-7.1.8.vmlinuz` | 13 MB | the live kernel |
| `simple-linux-kernel-7.1.8-modules.tar.xz` | 12 MB | its modules (`lib/modules/7.1.8-cachyos1`) |
| `simple-linux-kernel-store.tar` | 271 MB | the per-hardware kernel store the installer picks from: 10 builds (generic x86-64 v2/v3 and Raptor Lake, by GPU vendor and laptop/desktop) with their modules, plus the `Packages` index |
| `SHA256SUMS`, `SHA256SUMS.sig` | | checksums and their signature (see below) |

Both ISOs boot on BIOS and UEFI (Limine). Current version: **0.2.1**. Versions before 0.1.2 are withdrawn: they did not boot on the first laptop they were tried on.

### Verifying the download

The checksums are signed with an ssh key; its public half is in `signing/allowed_signers`. With the files, `SHA256SUMS` and `SHA256SUMS.sig` in one directory:

```
sh signing/verify.sh .
```

This checks the signature and then the files. The signing key (`SHA256:mvyK27nZZuGrO5vkK+yW+dVJSclojy3sPV1QZjZaZiw`) is the author's; if a release ever fails this check, do not use it.

### Secure Boot

Both ISOs are Secure Boot capable but **not Microsoft-signed**: a stock firmware refuses them ("Access Denied"). Either turn Secure Boot off, or enrol `secureboot/simple-linux-db.cer` in the firmware's `db` (setup menu → Secure Boot → Key Management). Limine is signed with that key and pins its config, the kernel and the initramfs by hash. Checked under OVMF: boots with the key enrolled, refused with Microsoft's keys. The *installed* system is not set up for Secure Boot.

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

## Booting from Ventoy

Copy the `.iso` onto a Ventoy stick and pick it in the Ventoy menu, then choose **Boot in grub2 mode**: it works on BIOS
and on UEFI (Ventoy reads the image's `boot/grub/grub.cfg`, loads the kernel itself and makes the ISO visible to the
live system). On UEFI, *Boot in normal mode* also works. On **BIOS, normal mode does not work** (Limine in the image stops
with "Could not determine boot drive"), so use grub2 mode there. Tested with Ventoy 1.1.17 in QEMU (BIOS and UEFI); not on real hardware. 0.2.0 and older
had no `grub.cfg` and could not be started from Ventoy this way.

## If it does not start on your machine

Limine shows a menu for 5 seconds. Try the entries in this order and note which one works:

1. **Simple Linux (live)** - the default, screen only, kernel and dracut messages visible.
2. **USB workaround** - for `usb X-Y: device descriptor read/64, error -71`, the classic enumeration failure
   (it helps most when the boot stick sits in the failing port; also try another port, USB 2 if you have one).
3. **safe graphics (nomodeset)** - if the screen goes black after the kernel starts; you get the text installer.
4. **verbose** - every kernel and initramfs message, and a shell if the live medium is not found.
5. **serial console** - only if you have a serial cable.

`[Firmware Bug]: TSC_DEADLINE disabled ... please update microcode` and `error -71` on some USB port are
warnings on their own; if boot stops, the lines *after* them (use entry 4) say why. Early versions had a
console setting that hid those lines on laptops with a phantom serial port; that is fixed and CPU
microcode now loads early. **No image has been run on real hardware by the author yet** - reports of what the verbose
entry prints on a failing machine are the most useful thing you can send.

## What 0.2.1 changed

- The images carry a `boot/grub/grub.cfg`, which is what makes them bootable from Ventoy (see above).

## What 0.2.0 changed

- **One install path.** The text and graphical installers run the same phase pipeline as `--headless`, and a failed install can be **resumed** (`r` in the text installer, a button in the GUI, `--resume`): done steps are skipped, the rest continue. The VM test of this found that the base-system step could not run twice (it now remembers an unpacked stage and re-fetches the overlay); fixed.
- **Graphics.** Every graphics adapter is detected, `VIDEO_CARDS` covers all of them (hybrid laptops used to get only the discrete GPU's driver; the values are now Gentoo's: `amdgpu radeonsi`, `intel`, `nvidia`, `virgl` in a VM), and the compositor renders on the discrete GPU unless asked otherwise (`GENTOO_INSTALLER_RENDER=integrated`): niri's `render-drm-device`, `WLR_DRM_DEVICES`/`AQ_DRM_DEVICES` for the others, and Noctalia's shared GL context is switched off for the proprietary NVIDIA driver.
- **Language and time zone** follow the keyboard layout (a `ua` keyboard gives `uk_UA` + `en_US` and `Europe/Kyiv`); only unambiguous countries get a zone.
- **Kernels.** The installer picks from a real per-hardware store (`simple-linux-kernel-store.tar`); a full install from the minimal image used `generic-x86-64-v3-none-desktop` from it.
- **Images** are about 8 % smaller (squashfs zstd level 19, 1 MiB blocks); both were booted as a USB stick on BIOS, UEFI and Secure Boot. The GUI image without 3D falls back to a cage-hosted graphical installer, or the text one.
- **Signing**: signed checksums and Secure Boot as above. `GENTOO_INSTALLER_WM=none` installs no desktop.

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
| `SHA256SUMS`, `SHA256SUMS.sig` | checksums of the release files and their signature |
| `signing/` | the public key (`allowed_signers`), `verify.sh`, and the maintainer's `sign.sh` |
| `secureboot/simple-linux-db.cer` | the certificate to enrol for Secure Boot |

## What has and has not been tested

Tested, in QEMU/KVM: both ISOs boot on BIOS and UEFI, as a CD and as a USB stick (minimal); the GUI image
reaches the niri session with the installer, Thunar, Zen and PipeWire running on a virtual 3D GPU; a full
headless install from the minimal image onto a blank virtual disk, after which the installed system boots
on its own, and the created user logs in with fish, btrfs subvolumes and `/boot` mounted, `doas` installed.

The 0.2.0 install test: a console-only install (`GENTOO_INSTALLER_WM=none`) from the minimal image with a kernel from the store, interrupted at the base-system step, resumed to the end, and the installed disk booted to a login with the right `make.conf`.

**Not tested: any real hardware.** Also not done: the desktop and GPU-driver steps on a real target (a compile of niri and Noctalia was not part of the test), the Wi-Fi screen against a real `iwd`, LUKS in the installer, Secure Boot for the installed system. Treat it as an early build.

## Licence

See [NOTICE.md](NOTICE.md). The files in this repository (configuration and documentation) are
GPL-2.0-or-later, like the installer; the images contain many packages under their own licences.
