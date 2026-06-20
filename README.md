# Copland OS

A custom **Garuda GNOME × CachyOS** Linux image, tuned for a **Ryzen 9 9950X3D (Zen 5 / x86-64-v4)** +
**RTX 5090 (Blackwell)** workstation. Structurally it stays Garuda (GNOME, `dr460nized`/garuda metas,
configs intact) — the package **source** is swapped to CachyOS's `znver4` (AVX-512) repos, with a
bleeding-edge rc kernel, NVIDIA open module, a gaming/creator stack, and a SteamOS-style Game Mode.

> Name from *Serial Experiments Lain* (the Navi runs "Copland OS Enterprise").
> `os-release` keeps `ID=garuda` so garuda tooling/hooks keep working — only the branding + package
> source + hardware layer differ.

## What's in it

- **Optimized base** — `cachyos-znver4`/`-core`/`-extra` + `cachyos` repos injected **above**
  `core/extra/multilib` so prebuilt x86-64-v4 packages win by priority; garuda-* metas remain.
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
sudo buildiso -p gnome   # run from this iso-profiles dir; output to /var/cache/garuda-tools/...
```

Requires an **AVX-512 (x86-64-v4)** CPU; the image targets NVIDIA. The 197 MB `Slot-Dark-Icons`
theme is not vendored here — drop your icon theme into the desktop-overlay before building.

## Credits

Built on [Garuda Linux](https://garudalinux.org/) (`garuda-tools`, `iso-profiles`) and
[CachyOS](https://cachyos.org/) repos. Gaming/Game-Mode patterns ported from Bazzite, Nobara,
SteamOS and ChimeraOS.
