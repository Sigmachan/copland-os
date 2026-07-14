# Copland OS — AI Handoff

Handoff for the next AI agent (or Kira on the build host). Read `AGENTS.md` first for the
dev-environment + toolchain rules; this file is the *product* handoff: state, scope, and the exact
wiring of Kira's own builds into the OS.

## 0. TL;DR

- **Copland OS** = Garuda × CachyOS custom ISO for Kira's rig (Ryzen 9 9950X3D / RTX 5090 / ASUS
  X870E Hero). Flagship DE: **KDE Plasma 6 + Layan**. Optimized packages: **CachyOS znver4 + ALHP
  x86-64-v4 + Garuda + AUR**.
- Work branch: `cursor/setup-dev-environment-0c29` → PR
  [#1](https://github.com/Sigmachan/copland-os/pull/1).
- **Hard constraint:** the ISO can only be *built/booted on an Arch/CachyOS host* (needs pacman /
  archiso / AVX-512 / root). This Ubuntu Cloud VM can only **build `garuda-tools`**, **lint**, and
  **`buildiso -q` parse** profiles. Anything that must *compile packages* is delegated to the host.
- Flagship profile: `iso-profiles/garuda/dr460nized` (KDE + Layan). GNOME
  (`iso-profiles/garuda/gnome`) kept as an alternative.

## 1. Current state (done)

| Area | State |
|---|---|
| Dev env (this VM) | `make` builds garuda-tools; lint + `buildiso -q` validated. See `AGENTS.md`. |
| Optimized base | CachyOS znver4 + `[*-x86-64-v4]` ALHP + Garuda injected in `garuda-tools/data/pacman-{default,multilib}.conf`; keyrings/mirrorlists in `iso-profiles/shared/Packages-Root`. |
| KDE + Layan flagship | `dr460nized/{profile.conf,Packages-Desktop,desktop-overlay}` — SDDM, Layan (global+kvantum+aurorae), kwin blur/rounded, Slot-Dark icons + Bibata. |
| Copland base layer | RTX 5090 + Zen5 tuning, gaming + Game Mode session, Blackwell AI, snapshots — ported into the KDE overlay + `Packages-Desktop`. |
| Docs | `README.md`, `PROMPT.md`, `AGENTS.md` updated for KDE + Layan + ALHP. |

Validate any profile change: `sudo buildiso -q -p dr460nized` (exits 1 on success for `-q`) and
`cd iso-profiles && bash .ci/lint.sh`.

## 2. Kira's builds → real packages (the "tie my builds to real packages" map)

Legend — **WIRED**: already in the package set / build-local-repo. **PKGBUILD**: needs a real
PKGBUILD built into `blackwell-local` (via `build-tools/build-local-repo.sh`) on the Arch host.
**FIRST-BOOT**: provisioned from the real repo on first login (like `claw-code`). **OOS**: out of
scope for the KDE flagship (COSMIC-only / not an OS component).

| Kira repo | Real source | Package / target | Mechanism | Status | Prio |
|---|---|---|---|---|---|
| `llama.cpp-blackwell` | `build-tools/llama-cpp-blackwell/PKGBUILD` | `llama.cpp-blackwell` | local PKGBUILD | **WIRED** | P0 |
| `gamescope` (fork) | github.com/Sigmachan/gamescope | `gamescope-git` (Provides gamescope) | build-local-repo (AUR clone) | **WIRED** — repoint to fork if it diverges | P1 |
| `claw-code` | github.com/Sigmachan/claw-code | `gajae-code` via `bun` | `etc/skel/.local/bin/claw-code-setup.sh` | **WIRED** (FIRST-BOOT) | P1 |
| `perfmax` | github.com/Sigmachan/perfmax | `perfmax` (Rust/egui, KDE tray) | PKGBUILD → blackwell-local | **PKGBUILD** | P1 |
| `wired-toys` | github.com/Sigmachan/wired-toys | `wired-toys` (LinuxToys fork) | PKGBUILD → blackwell-local | **PKGBUILD** | P1 |
| `loadout` | github.com/Sigmachan/loadout | `loadout` (Rust/libcosmic) | PKGBUILD → blackwell-local | **PKGBUILD** | P1 |
| `sidewire` | github.com/Sigmachan/sidewire | `sidewire` (KDE Plasma 6 / KRDP) | PKGBUILD or FIRST-BOOT | PENDING | P2 |
| `dexwire` | github.com/Sigmachan/dexwire | `dexwire` (scrcpy DeX, KDE) | PKGBUILD or FIRST-BOOT | PENDING | P2 |
| `kms-hdr` | github.com/Sigmachan/kms-hdr | `kms-hdr-git` (KMS CTM injector) | PKGBUILD | PENDING | P2 |
| `wayscope-dbus` | github.com/Sigmachan/wayscope-dbus | `wayscope-dbus` | PKGBUILD | PENDING | P2 |
| `reclock-nv50` | github.com/Sigmachan/reclock-nv50 | `reclock-nv50` (NVIDIA reclock) | PKGBUILD/script | PENDING | P2 |
| `amd-hdmi-audio-fix` | github.com/Sigmachan/amd-hdmi-audio-fix | script/PKGBUILD (iGPU HDMI audio) | overlay script or PKGBUILD | PENDING | P2 |
| `apollo-cuda-git`, `proton-ge-custom-bin`, `hiddify-next-bin`, `decky-loader`, `zenpower3-dkms`, `google-chrome-dev`, `discord-canary`, `layan-gtk-theme-git`, `tela-circle-icon-theme-git`, `alhp-keyring`, `alhp-mirrorlist` | AUR | same names | `build-tools/build-local-repo.sh` `AUR_PKGS` | **WIRED** | P0/P1 |
| `wlgame`, `hackcode`, `monocular-parallax` | GitHub | apps | optional add later | OOS/P3 | — |
| `kms-hdr-panel`, `cosmic-applet-vrammon`, `cosmic-applet-system-monitor`, `cosmic-comp`, `cosmic-settings` | GitHub | COSMIC-only | only if a COSMIC session is added | **OOS** | P3 |

> The P1 `PKGBUILD` items must be **compiled on the Arch host** (this VM has no pacman/makepkg). Add
> each to `LOCAL_PKGBUILDS` (with a real `build-tools/<name>/PKGBUILD`) or `AUR_PKGS` in
> `build-tools/build-local-repo.sh`, then add the package name to
> `iso-profiles/garuda/dr460nized/Packages-Desktop` under a "Kira's own stack" section. Do not commit
> a guessed PKGBUILD — derive it from each repo's actual build system (cargo / meson / just).

## 3. Important parts of the OS (scope / priority)

- **P0 — core (DONE):** optimized repos + keyrings; `linux-cachyos-rc` + prebuilt `nvidia-open`; KDE +
  Layan DE; gaming stack + Game Mode; hardware tuning (`scx_lavd`, zram, sysctls, udev, `asusctl`,
  `zenpower3`, `mesa-tkg`); Blackwell AI; Btrfs snapshots.
- **P1 — critical remaining:** (1) real ISO build on the Arch host (see §4); (2) wire `perfmax`,
  `wired-toys`, `loadout` via real PKGBUILDs; (3) confirm Kira's exact Windows-taskbar app list and
  reconcile the dock; (4) vendor the `Slot-Dark-Icons` theme into the overlay (referenced but not
  shipped).
- **P2 — nice-to-have:** package the remaining KDE-relevant Kira tools (§2); SDDM Layan theme polish;
  optional in-ISO `linux-tkg-p03`.
- **P3 / OOS:** COSMIC-only tools, niche apps.

## 4. How to build & validate

**On this / any dev VM (no ISO):**

```sh
cd garuda-tools && make && sudo make install     # build + install the toolchain
cd ../iso-profiles && bash .ci/lint.sh           # lint (must pass)
sudo buildiso -q -p dr460nized                   # parse-only; exits 1 on success
```

**On Kira's Arch/CachyOS host (real ISO):**

```sh
# 1. Host must TRUST the extra keyrings before pacstrap can verify optimized packages:
sudo pacman -S cachyos-keyring alhp-keyring && sudo pacman-key --populate cachyos alhp
# 2. Build Kira's + AUR packages into blackwell-local (see build-tools/build-local-repo.sh):
bash build-tools/build-local-repo.sh
# 3. Build the flagship ISO from this iso-profiles dir:
sudo buildiso -p dr460nized                      # -k linux-tkg-p03 for the opt-in tkg kernel
# 4. Smoke-test: run_archiso / qemu before flashing.
```

Notes: `buildiso` cannot read `file://` repos as `DownloadUser=alpm` under `/home` — the local repo
is deployed to world-readable `/var/cache/blackwell-local` (handled by `build-local-repo.sh`). For an
in-ISO `linux-tkg-p03` kernel follow `build-tools/linux-tkg-p03/INTEGRATION.md` (http-repo shim +
`nvidia-open-dkms`).

## 5. Concrete next steps (each: file to touch → acceptance)

1. **Package `perfmax`/`wired-toys`/`loadout`** → add `build-tools/<name>/PKGBUILD` + append to
   `build-local-repo.sh` + add names to `dr460nized/Packages-Desktop`. Accept: `makepkg` succeeds on
   the host and the names appear in `blackwell-local`.
2. **Confirm Kira's taskbar apps** → reconcile the "DAILY DRIVER SOFTWARE" block in
   `dr460nized/Packages-Desktop`. Accept: Kira signs off on the list.
3. **Vendor `Slot-Dark-Icons`** → drop the theme into
   `dr460nized/desktop-overlay/usr/share/icons/Slot-Dark-Icons/`. Accept: `gcx-kde-theme.sh` finds it.
4. **First real build** → run §4 on the host; capture the `buildiso` log. Accept: bootable ISO in
   `/var/cache/garuda-tools/...`.

## 6. Conventions & gotchas

- Commit messages: **Conventional Commits** (CI runs `cz check`). Lint scope: `iso-profiles/.ci/lint.sh`
  covers `iso-profiles/*.md`, `.ci/*.sh`, `.*.yml`.
- The DE-agnostic Copland overlay is **duplicated by copy** in `gnome/` and `dr460nized/` — edit both,
  or refactor to a shared overlay.
- `os-release` keeps `ID=garuda` on purpose (garuda-* tooling/hooks). Branding is `Copland OS`,
  codename `lain`.
- `buildiso -q` exiting `1` is **success** (pretend mode), not an error.
