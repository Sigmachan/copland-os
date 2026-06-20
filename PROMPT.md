# Project: Garuda GNOME × CachyOS — custom optimized ISO

## Goal (one line)
Build a **Garuda GNOME** live/installer ISO that is **not modified Garuda** structurally —
dr460nized/garuda meta-packages, configs, GNOME stay intact — but packages are pulled from
**CachyOS znver4 repos** (x86-64-v4 / AVX-512 prebuilt), with a **bleeding-edge rc kernel**,
**Zen5-native Clang/ThinLTO** for anything built locally, **RTX 5090 drivers**, and Kira's software
baked in. "Garuda не ломается, просто пакеты эффективнее + мой софт и дрова."

## Host
CachyOS (Arch), Ryzen 9 9950X3D (Zen5), RTX 5090. Build dir: `~/dev/garuda-cachyos-iso/`.
`buildiso` (garuda-tools) installed from gitlab source → `/usr/local/bin/buildiso`.

## LOCKED SPEC
| Layer | Choice |
|---|---|
| Base distro | Garuda **GNOME** (`iso-profiles/garuda/gnome`) — not KDE |
| Package repos | **CachyOS znver4** (`cachyos-znver4`/`-core`/`-extra` + `cachyos`) injected ABOVE arch/garuda in the build pacman.conf → optimized pkgs win by priority; garuda-* metas stay |
| Kernel | **`linux-cachyos-rc`** (7.1.rcX, znver4) + headers |
| GPU (5090) | **`linux-cachyos-rc-nvidia-open`** (prebuilt module for rc — NO DKMS, dodges the rc-DKMS-fail) + nvidia-utils/lib32/settings, via `garuda-hardware-profile-nvidia` (mhwd) |
| Local/AUR toolchain | **Clang 22 + lld + ThinLTO, `-march=znver5 -O3`** (repo pkgs stay znver4 prebuilt) |
| Software (default, tweakable) | chrome, vscode-insiders, steam, lutris, gamescope, mangohud, discord, ayugram, docker, ansible, zsh, starship, bibata-cursor-theme, catppuccin |

## DONE
- [x] `buildiso` (garuda-tools) built+installed from gitlab; archiso/arch-install-scripts/squashfs/libisoburn deps in
- [x] `iso-profiles` cloned (gitlab.com/garuda-linux/tools/iso-profiles), GNOME profile present
- [x] CachyOS znver4 repo blocks injected into `/usr/local/share/garuda-tools/pacman-default.conf` + `pacman-multilib.conf` (above `[core]`); host keyring already trusts cachyos → pacstrap signatures verify
- [x] gnome `Packages-Root` += cachyos-keyring, cachyos-mirrorlist, linux-cachyos-rc(+headers), clang, llvm, lld
- [x] gnome `Packages-Mhwd` += `linux-cachyos-rc-nvidia-open`
- [x] `/etc/garuda-tools/make.conf.d/x86_64.conf` → Clang/lld/ThinLTO znver5 (CC=clang, RUSTFLAGS target-cpu=znver5)

## TODO
1. Add Kira's software list to `iso-profiles/garuda/gnome/Packages-Desktop` (default set above — confirm/trim).
2. Point garuda-tools at this profiles dir (run dir / `-p gnome`), set output dir.
3. **Run the build:** `sudo buildiso -p gnome` (downloads GBs, builds squashfs, ~30–60 min).
   Register on dashboard: `eprog` (parse buildiso log).
4. **Expected iteration:** frankendistro (CachyOS repos in Garuda buildiso) may fail first run on
   version-skew between CachyOS-v4 and Arch packages, or a profile pkg not in cachyos → fix repo
   priority / drop the offending pin / `pacman -Sy` refresh, re-run.
5. Test the ISO in qemu (`run_archiso`/qemu-system-x86_64) before flashing to USB.

## Notes / gotchas
- Repo pkgs are **prebuilt znver4**, NOT znver5 — that's intentional (90% of the gain, zero compile).
  True "recompile everything for znver5" = Gentoo-class, separate project.
- linux-cachyos-rc-nvidia-open must match the exact rc kernel version in the repo at build time.
- Kira's daily kernel is custom `linux*-tkg-*-llvm` (not repo) — can be added post-install, not in ISO.
- Watch for trailing-space in injected `[cachyos-*]` headers (from awk extract) — pacman trims, fine.
