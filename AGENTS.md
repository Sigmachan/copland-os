# AGENTS.md

## Cursor Cloud specific instructions

This repo is the **Copland OS** distro-build project: a fork of Garuda Linux's `garuda-tools`
(shell/m4 ISO build toolchain) plus `iso-profiles` (profile definitions) and `build-tools`
(custom Arch packages). The "product" is a bootable Arch/CachyOS ISO, not a long-running service.

For product state, scope/priorities, and how Kira's own repos map to real packages, see `HANDOFF.md`.

### Key constraint: no full ISO build here
The cloud VM is Ubuntu, but a real build (`sudo buildiso -p gnome`) targets an **Arch/CachyOS host**
and needs `pacman`/`archiso`, root, and multi-GB downloads. **Do not attempt a full ISO build on this
VM** — it will fail at pacstrap/`check_requirements`. Likewise `build-tools/*.sh`
(`build-local-repo.sh`, `llama-cpp-blackwell/PKGBUILD`, `linux-tkg-p03/build.sh`) need Arch
`makepkg`/`pacman` and are not runnable here.

### What IS runnable (dev loop)
- **Build the toolchain:** `cd garuda-tools && make` — m4 generates `bin/*` from `bin/*.in`; docbook2x
  builds man pages. The `xsltproc` "invalid redeclaration of predefined entity" lines are **non-fatal
  warnings** (make still exits 0). To actually invoke the tools, install them: `sudo make install`
  (into `/usr/local/bin`); the generated scripts hard-code `/usr/local/{lib,share}/garuda-tools`, so
  they only work after install, not from the build tree.
- **Lint (the real CI check):** `cd iso-profiles && bash .ci/lint.sh` (shellcheck, shfmt, markdownlint,
  yamllint). See `.gitlab-ci.yml`.
- **Commit messages** must follow Commitizen / Conventional Commits; CI runs `cz check`.

### Exercising the toolchain without building an ISO
`buildiso` looks for profiles in `/var/cache/garuda-tools/iso-profiles` (and otherwise tries to clone
from gitlab). To point it at the in-repo profiles, write a user config once:

```sh
mkdir -p ~/.config/garuda-tools
echo 'run_dir=/workspace/iso-profiles' > ~/.config/garuda-tools/iso-profiles.conf
```

Then `sudo buildiso -q -p <profile>` runs **query/pretend** mode: it parses the profile and prints its
settings, then **intentionally exits 1** (this is success for `-q`, not an error). Copland flagship
profiles: **`dr460nized`** (KDE Plasma 6 + Layan, the daily driver) and **`gnome`** (alternative).
Both live under `iso-profiles/garuda/`. The DE-agnostic Copland layer (branding, hardware, gaming, AI)
is currently **duplicated by copy** in each profile's `desktop-overlay/` (edit both, or refactor to a
shared overlay later); only the desktop layer differs. Validate profile edits with
`sudo buildiso -q -p dr460nized` and lint with `cd iso-profiles && bash .ci/lint.sh`.

### Environment notes
- Dependency install is handled by the startup update script (apt: `m4 make shellcheck shfmt yamllint
  xsltproc docbook2x gettext-base`; npm: `markdownlint-cli`; pip: `commitizen`). `gettext-base` matters:
  without the `gettext` command `buildiso` spams `gettext: command not found`.
- `markdownlint` and `cz` install under `~/.local/bin`, which is added to `PATH` via `~/.bashrc`.
