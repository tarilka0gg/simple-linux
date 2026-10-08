# Licences and sources

The release images are compilations of software from Gentoo's repositories, each under its own licence
(GPL, LGPL, MIT, BSD, MPL, Apache, and redistributable firmware licences, among others). `packages/*.txt`
name every package and version that was installed when an image was built.

**Corresponding source**

- Gentoo packages: the ebuilds are in the Gentoo repository (`gentoo`, plus `guru` for niri, Noctalia,
  `gping`, `xwayland-satellite`, `zen-bin`), and their source archives are served from Gentoo's distfiles
  mirrors under the names and versions in `packages/*.txt`. `zen-bin` and `linux-firmware` are binary
  redistributions.
- Linux kernel: `sys-kernel/cachyos-sources-7.1.8-r1` (the CachyOS patch set on the mainline tree, from the
  `CachyOS-kernels` overlay), built with `kernel/config-7.1.8-cachyos1-live`. The options added by this project
  are in `kernel/kernel-live.fragment`.
- Installer, image build scripts and the custom-stage builder: https://github.com/tarilka0gg/gentoo-installer
  (GPL-2.0-or-later).
- GTK look of the graphical image: the WhiteSur icon theme (vinceliuice/WhiteSur-icon-theme, GPL-3.0) and the
  Gruvbox GTK theme (Fausto-Korpsvart/Gruvbox-GTK-Theme, GPL-3.0) are copied in unchanged from their upstream
  releases.
- Limine (the boot loader) is BSD-2-Clause; its source is in Gentoo as `sys-boot/limine`.

If you need a source archive that is no longer on Gentoo's mirrors, open an issue.

**This repository's own files** (`profile/`, `kernel/kernel-live.fragment`, documentation) are
GPL-2.0-or-later; see `LICENSE`. The Noctalia community palettes and templates under
`profile/state/noctalia/` are third-party downloads kept here as the images carry them, under their own terms.
