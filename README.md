# Copland OS

A custom **Garuda × CachyOS** Linux image, tuned for a **Ryzen 9 9950X3D (Zen 5 / x86-64-v4)** +
**RTX 5090 (Blackwell)** workstation. Structurally it stays Garuda (garuda metas, configs, hooks
intact) — the package **source** is swapped to CachyOS's `znver4` (AVX-512) repos, with a
bleeding-edge rc kernel, NVIDIA open module, a gaming/creator stack, and a SteamOS-style Game Mode.

**Flagship DE: KDE Plasma 6 + Layan** (`iso-profiles/garuda/dr460nized`) — dark, blurred, rounded,
Kira's daily driver. The **GNOME** profile (`iso-profiles/garuda/gnome`) is kept as a fully-built
alternative. Both share the same CachyOS/hardware/gaming/AI base; only the desktop layer differs.

> Name from *Serial Experiments Lain* (the Navi runs "Copland OS Enterprise").
> `os-release` keeps `ID=garuda` so garuda tooling/hooks keep working — only the branding + package
> source + hardware layer differ.

## What's in it

- **Desktop (flagship)** — **KDE Plasma 6** themed with **Layan** (dark global theme + kvantum +
  aurorae) instead of the default dragonized meta, plus `kwin` blur + rounded-corners effects, SDDM,
  Slot-Dark icons and Bibata cursor. GNOME profile stays available.
- **Optimized base** — `cachyos-znver4`/`-core`/`-extra` + `cachyos` repos injected **above**
  `core/extra/multilib` so prebuilt x86-64-v4 packages win by priority; garuda-* metas remain. Ships
  the CachyOS tuning set (`cachyos-settings`, `ananicy-cpp` + `cachyos-ananicy-rules`) and
  `cachyos-kernel-manager` for building custom CachyOS/tkg-style kernels post-install.
- **Distro feature ports** — Garuda Btrfs snapshots + boot-into-snapshot rollback (`snapper`,
  `snapper-support`, `grub-btrfs`, `btrfs-assistant`); Nobara-style GPU control (`lact`); PikaOS/Bazzite
  `scx_lavd` scheduler.
- **Kernel / GPU** — `linux-cachyos-rc` + matching prebuilt `linux-cachyos-rc-nvidia-open`
  (no DKMS), `nvidia-utils`/`lib32`, DRM KMS early-load, `nvidia_drm.modeset=1`.
- **Gaming (Bazzite/Nobara/SteamOS/ChimeraOS ports)** — `cachyos-gaming-meta` (proton-cachyos, wine,
  umu), `proton-ge-custom`, `gamescope`, `lutris`, `heroic`, `bottles`, `gamemode`, `vkbasalt`,
  `decky-loader`, controller support (`xpadneo`/`xone`). **RTX/DXR + DX12 + DLSS on by default**
  (modern Proton + vkd3d-proton; NVAPI + NGX updater set system-wide) plus a `dlss-swapper` launch
  wrapper. SteamOS-style **Game Mode** via `gamescope-session` (GDM-selectable, NVIDIA-corrected).
- **Creator** — `obs-studio` + `obs-vkcapture`, `easyeffects`, full codec set.
- **Hardware tuning** — `scx_lavd` (sched_ext) for the dual-CCD X3D, `zram`, gaming sysctls
  (`vm.max_map_count`, `split_lock_mitigate=0`), I/O scheduler udev rules, `zenpower3`, `asusctl`.
- **AI stack** — `llama.cpp` built for Blackwell (CUDA `sm_120`), CUDA runtime; vLLM provisioned first-boot.

## Layout

| Path | What |
|---|---|
| `iso-profiles/garuda/dr460nized/` | **flagship KDE Plasma 6 + Layan profile**: `Packages-*` + `desktop-overlay/` |
| `iso-profiles/garuda/gnome/` | the GNOME profile: package lists (`Packages-*`) + `desktop-overlay/` |
| `iso-profiles/shared/` | shared package lists + overlays |
| `garuda-tools/data/` | build `pacman-*.conf` (repo priority) + `make.conf.d` (znver5 Clang/ThinLTO for local builds) |
| `build-tools/build-local-repo.sh` | builds the AUR/custom packages into the `blackwell-local` repo |
| `build-tools/llama-cpp-blackwell/` | `llama.cpp` PKGBUILD (CUDA sm_120) |
| `build-tools/linux-tkg-p03/` | optional `linux-tkg` p03 kernel config |

## Custom package repo (`blackwell-local`)

AUR/locally-built packages (`gamescope-git`, `proton-ge-custom-bin`, `apollo-cuda-git`,
`llama.cpp-blackwell`, `decky-loader`, `discord-canary`, `google-chrome-dev`, `zenpower3-dkms`, …) are
built with `build-tools/build-local-repo.sh` and published to this repo's **GitHub Releases** (tag
`pkgs`) — a real online repo, reachable at build time and on the installed system.

```ini
[blackwell-local]
SigLevel = Never
Server = https://github.com/Sigmachan/copland-os/releases/download/pkgs
```

## Build

Repo packages stay prebuilt `znver4` (90% of the gain, zero compile). Build with garuda-tools:

```bash
sudo buildiso -p dr460nized   # KDE + Layan flagship (run from this iso-profiles dir)
sudo buildiso -p gnome        # GNOME alternative
# output to /var/cache/garuda-tools/...
```

Requires an **AVX-512 (x86-64-v4)** CPU; the image targets NVIDIA. The `Slot-Dark-Icons`
theme is not vendored here — drop your icon theme into the desktop-overlay before building.

### Kernel (linux-tkg)

Default shipped kernel is **`linux-cachyos-rc`** (prebuilt znver4; BORE/sched-ext + Clang/LTO + a
matching prebuilt `nvidia-open`, no DKMS). For the full **linux-tkg** experience:

- **Post-install:** `cachyos-kernel-manager` (shipped) builds custom CachyOS/tkg-style kernels with a
  GUI (scheduler, LTO, patch-set choices) — the "whole tkg set" without baking many kernels into the ISO.
- **In the ISO (opt-in):** build `build-tools/linux-tkg-p03` via its `build.sh` and wire it in per
  `build-tools/linux-tkg-p03/INTEGRATION.md`, then `sudo buildiso -p dr460nized -k linux-tkg-p03`.

## Credits

Built on [Garuda Linux](https://garudalinux.org/) (`garuda-tools`, `iso-profiles`) and
[CachyOS](https://cachyos.org/) repos. Gaming/Game-Mode patterns ported from Bazzite, Nobara,
SteamOS and ChimeraOS.
