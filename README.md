# garuda-wired-repo

Custom **pacman** repository for **Garuda Wired** (Garuda GNOME × CachyOS znver4 remix).
AUR + local packages built with znver5 Clang/ThinLTO, hosted on GitHub Releases as a real
online repo (so it's reachable at build time, inside the buildiso chroot, and on the installed
system — unlike a local `file://` repo).

## Use

Add to `/etc/pacman.conf` (above `[core]`):

```ini
[blackwell-local]
SigLevel = Never
Server = https://github.com/Sigmachan/garuda-wired-repo/releases/download/pkgs
```

Then `sudo pacman -Sy`.

## Contents (release tag `pkgs`)

gamescope-git · proton-ge-custom-bin · apollo-cuda-git (NVENC AV1, Blackwell) ·
llama.cpp-blackwell (sm_120) · hiddify-next-bin · decky-loader (+python-aiohttp-jinja2/-cors) ·
google-chrome-dev · zenpower3-dkms · protonup-qt-git · discord-canary

Rebuild locally with `build-tools/local-repo/build-local-repo.sh` from the iso project.
