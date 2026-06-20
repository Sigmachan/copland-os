#!/usr/bin/env bash
# build.sh — reproduce the starred CatPieLeaf/linux-p03 kernel on Arch as `linux-tkg-p03`,
# built strictly with Clang/LLVM + ThinLTO (matches p03's LLVM+O3 build and the user's rule).
#
# p03 upstream is a Fedora Koji RPM kernel (NOT Arch-installable). This rebuilds the SAME recipe
# (TKG + CachyOS + Clear + Firelzrd BORE/ADIOS/POC/LRU-Marie/nap + graysky ISA + 750Hz) via the
# Frogging-Family linux-tkg framework that p03 itself derives from.
#
# Output: linux-tkg-p03 + linux-tkg-p03-headers packages in ../linux-tkg/. Then see INTEGRATION.md
# to wire them into the buildiso ISO via a local http repo + build a matching nvidia-open module.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
TKG="$HERE/../linux-tkg"
[ -d "$TKG" ] || { echo "linux-tkg not found at $TKG (git clone https://github.com/Frogging-Family/linux-tkg)"; exit 1; }

# 1. p03 customization (clang/thinlto/bore/zen4/750Hz) + p03 patches auto-applied (*.mypatch).
cp "$HERE/customization.cfg" "$TKG/customization.cfg"
for p in "$HERE"/patches/*.patch; do cp "$p" "$TKG/$(basename "${p%.patch}").mypatch"; done
echo "Staged $(ls "$TKG"/*.mypatch 2>/dev/null | wc -l) p03 *.mypatch + customization.cfg into linux-tkg."

# 2. Build non-interactively with Clang. _NUKR=true keeps linux-tkg from prompting.
cd "$TKG"
_NUKR=true makepkg -s --noconfirm --skippgpcheck CC=clang CXX=clang++ LLVM=1 LLVM_IAS=1
echo "Done. Packages:"; ls -1 "$TKG"/linux-tkg-p03*.pkg.tar.* 2>/dev/null || echo "(check $TKG for *.pkg.tar.zst)"
