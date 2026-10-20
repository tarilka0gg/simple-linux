# Maintaining Simple Linux

How the project is kept going: what is pinned, how to see that it has gone stale, how to release, and where the keys are.
It is written for the person who has to do it in a year, probably the author. The conventions shared by all the repositories are in
[PROJECT-STANDARD.md](https://github.com/tarilka0gg/tarilka0gg/blob/main/docs/PROJECT-STANDARD.md).

## What is pinned, and where

| What | Where it is pinned | How you learn it is old |
|---|---|---|
| Kernel (7.1.8 at 0.2.35) | the kernel store of the release (`simple-linux-kernel-*`), built from the [kernel-matrix](https://github.com/tarilka0gg/kernel-matrix) configs | the weekly check |
| Gentoo stage3 under the custom stage | `iso/stage3.pin` in [gentoo-installer](https://github.com/tarilka0gg/gentoo-installer) | the weekly check |
| Portage tree snapshot and the binary packages built against it | the `binhost` release of [simple-linux-binhost](https://github.com/tarilka0gg/simple-linux-binhost) | the weekly check (age of the snapshot) |
| PineconeMC and the Craft apps | the ebuilds in `profiles/overlay/` of gentoo-installer | the weekly check (one GitHub release each) |
| Zen Browser, Steam | not pinned: Zen downloads itself at first start, Steam comes from its overlay at install time | nothing to do |

**The weekly check** is `iso/check-upstream.py` run by the `Upstream check` workflow of gentoo-installer every Monday. It keeps one open issue,
*Upstream updates*, with a table of pinned against latest, and closes the issue when everything is current. Run it by hand:

```
cd gentoo-installer && GITHUB_TOKEN=$(gh auth token) python3 iso/check-upstream.py
```

## Acting on the check

* **A package of the overlay has a new release:** `profiles/overlay/bump.py <category/package>` renames the ebuild, downloads the archive once and
  writes the Manifest line (it gives the same bytes as Portage's own, checked on a real package). Then `ebuild <file> clean install` on a Gentoo
  machine (see `profiles/README.md`), `cargo test -p slp-profiles`, commit.
* **The tree snapshot or the packages are old:** rebuild the binary host with `iso/binhost/build.sh`, then `make-repo.py` and `export-assets.sh`
  in the same directory prepare what goes into the `binhost` release (read the header of each script first). Check that the installer still
  resolves a full install against the new snapshot (the installer's tests use the golden spec in `slp-profiles/tests/golden/`).
* **The stage3 is old:** rebuild the custom stage with `iso/make-stage.sh` on top of the new stage3, put its date into `iso/stage3.pin`, and make a release.
* **The kernel is old:** build the new kernel and its matrix of configs ([kernel-matrix](https://github.com/tarilka0gg/kernel-matrix)),
  publish the store with `iso/binhost/publish-kernels.sh`, then make a release.

## Making a release

Everything runs on the author's PC (never on the old build server: it resets itself under load), on cores 0-7.

1. Write the version's section in `CHANGELOG.md` (headings are `## [x.y.z] - date`) and push it.
2. Build the images. `release.sh` needs a clean tree and an earlier `release-*` directory, and `PROFILE` for the GUI image:

   ```
   cd gentoo-installer
   PROFILE=~/Documents/work/gentoo-installer-test/profile/live taskset -c 0-7 nice -n 5 \
       bash iso/release.sh <x.y.z> build rootfs assemble collect offline
   ```

3. Check the result before signing: boot the GUI ISO in QEMU and look at the installer; if the change is a file in the image, read it out of the
   image (`dump.erofs --cat --path=/etc/... LiveOS/squashfs.img`, with the image taken out of the ISO by `7z e`).
4. `bash iso/release.sh <x.y.z> sign` writes `SHA256SUMS` and the signature, verifies it and bumps the version line of the README.
5. Commit `README.md`, `SHA256SUMS` and `SHA256SUMS.sig` here, then publish: `gh release create v<x.y.z> --notes-file ... <the 11 files>`.
6. Compare the uploaded sizes with the local files (`gh release view --json assets`).

Publishing is always a deliberate act; nothing publishes by itself.

## Keys

| Key | Where | If it is lost |
|---|---|---|
| Release signing key | `~/.config/simple-linux/release-signing` (public half: `signing/allowed_signers` in this repository) | old releases still verify; new ones need a new key, published here first |
| Secure Boot keys | `~/.config/simple-linux/secureboot` | the images signed with them stop booting under Secure Boot setups that enrolled them |
| Binary host signing key | its public half is `binhost-signing.asc` in the `binhost` release | the installer refuses unsigned packages, so it must be replaced in the installer too |

Keep an encrypted copy of `~/.config/simple-linux` somewhere that is not this machine. Never put these files in a repository.

## Languages

One setting, `locale.toml`, decides the language of every program: [simple-locale](https://github.com/tarilka0gg/simple-locale)
(`SPEC.md` there has the rule). A program that gets a translation joins by calling `resolve` and adds a row to the table in the spec.

## Documentation

* Screenshots are taken in the Simple Linux live session in a VM, never on the author's desktop: English locale, no personal wallpaper,
  no real data. A README shows them as a table with a title and a description under each picture, each a link to the full-size file.
* The changelog of a repository follows the standard above; the images of Simple Linux are the releases, so the installer's own file points here.

## What is not covered

* Nothing rebuilds the binary host or the images by itself. The check only says it is time.
* Four repositories have no licence file ([simple-linux-binhost](https://github.com/tarilka0gg/simple-linux-binhost),
  [simple-linux-configs](https://github.com/tarilka0gg/simple-linux-configs), power-scripts, gpu-undervolt): the licence is the author's choice.
* The GURU ebuilds of ustan and Ring-2Zero predate the dependency on `simple-locale` (a git dependency) and need it added before the next patch.
* `cargo fmt` is not enforced in Portage Store and tui-shim (hundreds of lines would change).
