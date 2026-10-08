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
| `simple-linux-minimal.iso` | 0.5 GB | text installer (TUI), rescue tools, firmware |
| `simple-linux-gui.iso` | 0.8 GB | the same plus a niri + Noctalia desktop, Zen, Thunar, GParted, PipeWire, with a graphical installer |
| `simple-linux-stage3-amd64-openrc.tar.xz` | 240 MB | the stage3 the installer unpacks. The images no longer contain it: the installer downloads this file from the latest release (needs network, which the install needs anyway), and checks it against the `.sha512` next to it |
| `simple-linux-stage3-amd64-openrc.tar.xz.sha512` | 170 B | its SHA-512, read by the installer |
| `simple-linux-kernel-7.1.8.vmlinuz` | 13 MB | the live kernel |
| `simple-linux-kernel-7.1.8-modules.tar.xz` | 12 MB | its modules (`lib/modules/7.1.8-cachyos1`) |
| `simple-linux-kernel-store.tar` | 271 MB | the per-hardware kernel store the installer picks from: 10 builds (generic x86-64 v2/v3 and Raptor Lake, by GPU vendor and laptop/desktop) with their modules, plus the `Packages` index |
| `SHA256SUMS`, `SHA256SUMS.sig` | | checksums and their signature (see below) |

Both ISOs boot on BIOS and UEFI (Limine). Current version: **0.2.19**. Versions before 0.1.2 are withdrawn: they did not boot on the first laptop they were tried on.

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

Copy the `.iso` onto a Ventoy stick and pick it; since 0.2.15 the default (*Boot in normal mode*) works on BIOS and on UEFI, and
*Boot in grub2 mode* works too (Ventoy then reads the image's `boot/grub/grub.cfg`, loads the kernel itself and makes the ISO visible
to the live system). On 0.2.14 and older, *normal mode* on BIOS stopped with "Could not determine boot drive": use grub2 mode with
those. Tested with Ventoy 1.1.17 in QEMU (BIOS and UEFI); not on real hardware. 0.2.0 and older had no `grub.cfg` and could not be
started from Ventoy at all.

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

## What 0.2.19 changed

- **Gruvbox in the graphical image.** Noctalia uses its built-in Gruvbox palette (light), which also recolours GTK 3/4 apps, the installer, the terminal and btop; niri's focus ring and borders use Gruvbox colours. The GTK theme is Gruvbox-Light.
- **WhiteSur icons.** The images only had Adwaita, so the installer and apps showed generic icons; the WhiteSur icon theme is now installed and set as the default (also through a GSettings default, since GTK 4 reads that before `settings.ini`). Application icons in the dock are no longer recoloured to one colour. Checked in QEMU (UEFI): the installer shows the Gruvbox colours and WhiteSur icons. The minimal image is unchanged.

## What 0.2.18 changed

- **Simple Linux wallpapers in the graphical image.** 19 wallpapers are in `~/Pictures/Wallpapers/simple` of the live session (`wallpapers/simple/` in this repo); the wallpaper picker (Ctrl+Alt+T) shows them in the `simple` folder. The minimal image is unchanged from 0.2.17.

## What 0.2.17 changed

- **ustan 0.2.2 is in both images** (it was a build from before 0.2.1): AppImages start without FUSE 2 and a launcher that dies right away shows its last output instead of failing silently.
- **Ventoy normal mode finds the image by itself.** If no device carries the label `GENTOO_LIVE` (a bootloader that Ventoy chain-loads, a kernel that only sees the USB stick), the initramfs now mounts the drives read-only, looks for an `.iso` with that volume label (up to three directories deep) and attaches it as a loop device, saying so on the console instead of waiting silently. Nothing changes when the label is already there (a real CD, Ventoy's grub2 mode). `rd.iso.autoscan=0` turns it off. Checked in QEMU on a real Ventoy 1.1.17 exFAT stick image and with Ventoy's own menu in UEFI; not yet confirmed on the laptop that showed the stall.

## What 0.2.16 changed

- **The installer inside the images is the current one.** The 0.2.14 and 0.2.15 images were built from an older build of the graphical installer, without the later changes (the software step in the normal flow, working search in the keyboard and timezone lists, uniform icon badges). Nothing else differs from 0.2.15. Checked in QEMU: both images boot from Ventoy (BIOS and UEFI, normal mode) and written straight to a stick (BIOS, UEFI, Secure Boot).

## What 0.2.15 changed

- **Ventoy works in BIOS without choosing a mode.** The BIOS stage of Limine in the images is rebuilt with a one-line patch (`iso/patches/limine-12.3.3-ventoy-bios.patch` in gentoo-installer; `iso/build-limine-bios.sh` makes it): Ventoy's virtual CD is a 2048-byte-sector drive that is neither flagged removable nor ATAPI, so stock Limine skipped it and stopped with "Could not determine boot drive". The BIOS config also no longer pins file hashes (only Secure Boot on UEFI needs them), which fixes the `Blake2b hash … does not match` panic that one tester saw when starting the image from Ventoy on BIOS. Checked in QEMU with Ventoy 1.1.17: BIOS and UEFI, normal mode and grub2 mode, for both images; and written straight to a stick on BIOS, UEFI and Secure Boot.
- **Zen Browser downloads in the background** as soon as the graphical session starts (no terminal window any more); opening it earlier just waits for the download.

## What 0.2.14 changed

- **portage-store is in the GUI image and in an installed desktop.** The installer copies it from the live system (programs under `/usr/local`, the helper in `/usr/libexec/portage-store/`). It adds one passwordless `doas` rule for the wheel group, limited to that helper: `permit nopass :wheel cmd /usr/libexec/portage-store/priv-helper`. `GENTOO_INSTALLER_STORE=0` skips the whole thing. The minimal image does not have it (no GTK).

## What 0.2.13 changed

- **The installed system matches the GUI image.** The default package groups now include everything the GUI live image has (file manager, audio, desktop utilities, disk tools, hardware tools, Gentoo tools). The browser group installs Zen, as the image does. Expect a much larger default install (about 186 packages, ~800 MB of downloads, some compiling); untick groups you do not want.
- **`btop` instead of `htop`, and `fastfetch`,** in both images and in the installed system.

## What 0.2.12 changed

- **root has fish as its login shell** on the installed system (and, when the desktop presets are installed, the same fish setup as the user). The account is still locked: this is the shell for `su`, `doas -s` or a rescue login. Checked in a VM: `/etc/passwd` of the installed system has `root:…:/usr/bin/fish`.

## What 0.2.11 changed

- **Your fish is installed with the system.** The installer copies the author's fish setup (the tide prompt with his settings, fisher, sponge, autopair, `config.fish`) into the new user's `~/.config/fish` when the system has fish. The configs live in [simple-linux-configs](https://github.com/tarilka0gg/simple-linux-configs) (the repository that used to be `gentoo-wm-configs`; the old address redirects). The live image uses it by default, so a desktop install no longer needs `GENTOO_WM_CONFIGS_URL` to be set by hand.
- tide draws its icons with a Nerd Font: use a terminal with one (the plain Linux console shows squares).

## What 0.2.10 changed

- **ustan is also installed on the system you install.** The installer copies it from the live image into `/usr/local` of the new system (the `ustan` command always; the window and its menu entry when a desktop was installed). Skip it with `GENTOO_INSTALLER_USTAN=0` in the headless mode. It is not part of Portage, so it is not updated with the system.

## What 0.2.9 changed

- **ustan is in the images.** [ustan](https://github.com/tarilka0gg/ustan) installs a .deb, an AppImage, a Flatpak bundle or a Windows .exe from a window (or `ustan install <file>`). The GUI image has `ustan-gui` with a menu entry, the minimal image the `ustan` command.

## What 0.2.8 changed

- **The graphical installer starts much sooner on machines without 3D** (old or unsupported GPUs, most VMs): ~9 s after the kernel starts instead of ~31 s (measured in QEMU). The live session used to wait a fixed 25 s for niri; it now checks for a 3D-capable GPU driver and goes straight to the software-rendered window when there is none. With a 3D GPU nothing changes except that it no longer waits.
- The boot menu waits 3 s instead of 5.

## What 0.2.7 changed

- **Smaller again** (minimal 652 → 514 MiB, gui 880 → 734 MiB): the root image no longer holds a second copy of the initramfs and the microcode images; Intel microcode for the newest server-only CPUs (Granite/Sierra/Emerald Rapids, Grand Ridge) is gone (Sapphire Rapids and everything older stays; such a CPU still boots on the firmware's microcode); Python keeps only what `equery` needs.

## What 0.2.6 changed

- **EROFS instead of squashfs for the root image** (LZMA, 1 MiB clusters): about 120 MiB smaller. The live kernel has EROFS built in (the kernel file in this release replaces the earlier one). Boot is about 2 s slower to reach the services, measured in a VM.
- **OpenRC starts services in parallel** (`rc_parallel`), which gives back about 1.5 s of that.

## What 0.2.5 changed

- **Smaller again** (minimal 851 → 747 MiB, gui 1227 → about 1000 MiB): Zen Browser and the NVIDIA GSP firmware are no longer on the medium.
- **Zen is downloaded on first use.** The GUI image has a "Zen Browser" entry (and `get-zen`) that fetches the current release from Zen's GitHub page (~110 MB, HTTPS, no checksum is published there) and runs it. Without that firmware the live GUI on RTX 20xx and newer cards runs in software (the cage fallback); the installed system is not affected.

## What 0.2.4 changed

- **The stage3 is downloaded, not shipped** (minimal 1091 → 851 MiB, gui 1467 → 1227 MiB). The images set `GENTOO_INSTALLER_STAGE3_URL` to the latest release's stage3 and the installer verifies it against the `.sha512` published next to it. A full install in a VM did this, and the installed system had fish, eza and micro, no nano. For use without a network you need your own image: `STAGE_TARBALL=… iso/assemble-iso.sh` (see the installer repository).

## What 0.2.3 changed

- **Smaller:** the Rust and Zig toolchains that were only needed to build the image are no longer in it (minimal 1202 → 1091 MiB, gui 1634 → 1467 MiB, even with the additions below).
- **More tools** (also in the GUI image), picked from the official Gentoo minimal CD's list: `gptfdisk` (gdisk/sgdisk), `iw` and `wpa_supplicant`, `nmap` (with ncat and nping) and `traceroute`, `eix` and `gentoolkit` (`equery`; Python is in the image for it), `screen`, and **Memtest86+** (two boot-menu entries, BIOS and UEFI; under Secure Boot the UEFI one is refused by the firmware since it is unsigned). The Portage tree is not on the medium, so `eix`/`equery` are only useful once you have one.

## What 0.2.2 changed

- **The installer now starts on older CPUs.** `installer-cli`/`installer-gui` were linked on a machine whose libc is built for x86-64-v3, so the binaries carried a "v3 needed" note and the live system refused to run them on anything older than Haswell (Westmere, Sandy/Ivy Bridge Xeons: "CPU ISA level is lower than required"). The images booted fine; only the installer did not start. Fixed, and checked in QEMU with Westmere, Sandy Bridge and a plain `qemu64` CPU, BIOS and UEFI, both images, 1 to 4 CPUs, 1 to 3 GB of RAM.

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
  `ddrescue`, `smartmontools`, `nvme-cli`, `hdparm`, `usbutils`, `dmidecode`, `htop`, `tmux`, `screen`, `tcpdump`, `nmap`, `gptfdisk`, `iw`, `wpa_supplicant`, `Memtest86+`, ….
- **GUI image only**: niri 26.04, Noctalia 5.2.0, ustan (with its menu entry; the minimal image has the `ustan` command), Zen Browser (downloaded on first use), Thunar (gvfs, tumbler), GParted, PipeWire +
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
