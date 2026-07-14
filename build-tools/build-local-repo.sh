#!/usr/bin/env bash
# build-local-repo.sh -- build the v2 AUR + custom packages into a local pacman repo
# that buildiso can install from. Repo packages (xpadneo-dkms, xone-dkms, cuda,
# upscayl-desktop-git, asusctl, libva-utils, linux-firmware-mediatek) come from
# cachyos/chaotic directly and are NOT built here.
#
# AUR/custom built here:
#   llama.cpp-blackwell   (local PKGBUILD, CUDA sm_120a)
#   gamescope-git         (user's own gamescope, Provides gamescope)
#   proton-ge-custom-bin  (user's own proton, GE)
#   apollo-cuda-git       (Sunshine fork, CUDA/NVENC -- replaces sunshine)
#   xone-dongle-firmware  (Xbox Wireless Adapter firmware)
#   hiddify-next-bin      (DPI-resistant proxy/VPN client)
set -uo pipefail

HERE="$(dirname "$(readlink -f "$0")")"
REPO_DIR="$HERE/repo"
DB="blackwell-local"
WORK="$HERE/work"
mkdir -p "$REPO_DIR" "$WORK"

LOCAL_PKGBUILDS=("$HERE/../llama-cpp-blackwell")
# AUR set restored after the no-AUR constraint was lifted (decky-loader = Bazzite Game Mode plugin
# loader; google-chrome-dev = canary channel; zenpower3-dkms = Zen power/voltage sensors).
# NOTE: xone-dongle-firmware is NOT built here — it's prebuilt in chaotic-aur (2.0.0-1) and its
# local prepare() pulls firmware from Microsoft (fragile/non-reproducible); resolve it from chaotic.
# python-aiohttp-jinja2 + python-aiohttp-cors are decky-loader's AUR-only deps (must precede it).
# bleeding swaps (user: rawest/beta everywhere): protonup-qt-git, discord-canary.
# (bottles-git is broken upstream right now — stale prepare() sed — so bottles stays stable from chaotic.)
AUR_PKGS=(gamescope-git proton-ge-custom-bin apollo-cuda-git hiddify-next-bin python-aiohttp-jinja2 python-aiohttp-cors decky-loader google-chrome-dev zenpower3-dkms protonup-qt-git discord-canary)
FAILED=()

build_dir() {
    local d="$1" name; name="$(basename "$d")"
    echo "==== building $name ===="
    if ( cd "$d" && makepkg -Cdf --skippgpcheck --nocheck --noconfirm --needed -s ); then
        cp "$d"/*.pkg.tar.zst "$REPO_DIR"/ 2>/dev/null && echo "OK  $name"
    else
        echo "FAIL $name"; FAILED+=("$name")
    fi
}

for d in "${LOCAL_PKGBUILDS[@]}"; do build_dir "$d"; done

for p in "${AUR_PKGS[@]}"; do
    rm -rf "$WORK/$p"
    if git clone --depth 1 "https://aur.archlinux.org/$p.git" "$WORK/$p" 2>/dev/null; then
        build_dir "$WORK/$p"
    else
        echo "FAIL clone $p"; FAILED+=("$p(clone)")
    fi
done

repo-add -n -R "$REPO_DIR/$DB.db.tar.zst" "$REPO_DIR"/*.pkg.tar.zst 2>/dev/null

# Deploy to a world-readable system path. The buildiso pacman.conf sets DownloadUser=alpm, and the
# sandboxed alpm user CANNOT traverse /home (mode 700) to read a file:// repo there — so the repo
# MUST live somewhere alpm can read. /var/cache/blackwell-local is world +rx.
DEPLOY=/var/cache/blackwell-local
sudo mkdir -p "$DEPLOY"
sudo cp -f "$REPO_DIR"/*.pkg.tar.zst "$DEPLOY"/ 2>/dev/null
( cd "$DEPLOY" && sudo repo-add -n -R "$DB.db.tar.zst" ./*.pkg.tar.zst >/dev/null 2>&1 )
sudo chmod -R a+rX "$DEPLOY"

echo "================================================"
echo "BUILD DIR  : $REPO_DIR"
echo "DEPLOYED   : $DEPLOY  (file:// repo for buildiso; world-readable for DownloadUser=alpm)"
ls -1 "$DEPLOY"/*.pkg.tar.zst 2>/dev/null | sed 's#.*/#  #'
echo "FAILED     : ${FAILED[*]:-none}"
echo
echo "Already wired in garuda-tools/data/pacman-{default,multilib}.conf as:"
echo "  [$DB]"
echo "  SigLevel = Optional TrustAll"
echo "  Server = file://$DEPLOY"