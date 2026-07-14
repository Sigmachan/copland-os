# Copland UPM

Copland's package manager for official repositories, local Copland
repositories and the AUR. It keeps pacman-compatible operations and Paru's
resolver while adding an EPM-style command vocabulary, recipes and automatic
LLVM-first AUR builds.

## Installation

```sh
cd build-tools/upm
makepkg -si
```

## Commands

- `upm` or `upm -Syu`: full repository and AUR upgrade.
- `upm -S package` / `upm install package`: install repository or AUR packages.
- `upm search term`, `upm info package`, `upm status package`: EPM-style aliases.
- `upm play recipe`: install the pacman package set from a built-in or user recipe.
- `upm service status unit`: control systemd services.
- `upm doctor --json`: verify the Copland package-management environment.
- `upm toolchain --json`: show the compiler selected for AUR builds.

Existing pacman and Paru flags remain available, including PKGBUILD review,
development-package tracking, chroot builds, news, clean and statistics.

## Toolchain policy

`UPM_TOOLCHAIN=auto` is the default. UPM compile-links a probe and prefers
Clang/LLVM/lld, then retries a failed LLVM `makepkg` build once with GCC after
a clean rebuild. It selects GCC immediately for CUDA or explicitly GCC-bound
PKGBUILDs. Existing `CC`, `CXX`, `AR`, `RANLIB` and `LD` are never overridden.

Set `UPM_TOOLCHAIN=llvm`, `gcc` or `system` to force a policy. The selected
toolchain is exported to builds as `UPM_SELECTED_TOOLCHAIN`.

## Recipes

Recipes are loaded in this order:

1. `$UPM_RECIPE_DIR`
2. `$XDG_CONFIG_HOME/upm/recipes`
3. `/usr/share/upm/recipes`
4. the source-tree `recipes` directory

For Copland, `[packages].pacman` is authoritative. If no recipe exists,
`upm play name` safely falls back to resolving `name` from repositories/AUR.

See `upm(8)`, `upm.conf(5)` and [NOTICE.md](NOTICE.md) for complete usage and
source provenance.
