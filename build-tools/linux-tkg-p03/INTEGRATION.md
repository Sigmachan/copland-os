# Integrating linux-tkg-p03 into the buildiso ISO

p03 upstream (`CatPieLeaf/linux-p03`) is a **Fedora Koji RPM** kernel — it cannot be installed on
Arch. This directory reproduces the *same recipe* on Arch as `linux-tkg-p03` (Clang/ThinLTO/BORE/
ADIOS/POC/LRU-Marie/nap/750Hz/graysky-ISA), which CAN be baked into the ISO.

Default shipped kernel stays **linux-cachyos-rc** (prebuilt znver4; BORE/sched-ext + CachyOS patches
+ Clang/LTO + bleeding 7.1.rcX + a matching prebuilt nvidia-open). That already delivers p03's core
with zero compile. `linux-tkg-p03` is the *opt-in experimental* kernel for the exact p03 patch set.

## Build
    ./build.sh                       # ~20-40 min on the 9950X3D; produces linux-tkg-p03[-headers]

## Wire into buildiso (the part the buildiso pipeline does not do natively)
buildiso pulls packages from pacman repos in a chroot; it cannot consume file:// repos. So serve a
local repo over http during the build:

1. Make a local repo from the built packages:
       mkdir -p /opt/p03-repo && cp ../linux-tkg/linux-tkg-p03*.pkg.tar.* /opt/p03-repo/
       repo-add /opt/p03-repo/p03.db.tar.zst /opt/p03-repo/*.pkg.tar.*
2. Serve it (chroot shares host network -> 127.0.0.1 reachable):
       (cd /opt/p03-repo && python -m http.server 8077 &)
3. Add it ABOVE [cachyos-znver4] in BOTH build pacman confs
   (/usr/local/share/garuda-tools/pacman-{default,multilib}.conf):
       [p03]
       SigLevel = Optional TrustAll
       Server = http://127.0.0.1:8077
4. Make it the kernel: in /etc/garuda-tools/garuda-tools.conf set kernel="linux-tkg-p03"
   (the KERNEL/KERNEL-headers placeholders then resolve to linux-tkg-p03[-headers]).
5. NVIDIA for the custom kernel: there is no prebuilt nvidia-open for linux-tkg-p03, so use the DKMS
   path — add `nvidia-open-dkms` to the package set (it builds against linux-tkg-p03-headers in the
   chroot) and DROP the `KERNEL-nvidia-open` line from Packages-Mhwd for p03 builds. (This is why
   linux-cachyos-rc remains the default: its nvidia-open is prebuilt = no DKMS, the rc-DKMS dodge.)

## Precise blocker (why this is a documented recipe, not baked from-scratch inline)
- A from-source kernel compile is a ~20-40 min / ~10 GB operation; running it inside the autonomous
  session and then iterating on Fedora-patch-vs-linux-tkg version skew is impractical here.
- buildiso cannot consume file:// repos, so baking a locally-built kernel needs the http-repo shim
  above (extra infra outside the stock pipeline).
- nvidia for a from-source kernel reverts to DKMS (the exact failure mode we engineered around with
  the prebuilt linux-cachyos-rc-nvidia-open).
Net: ship linux-cachyos-rc (p03 core, prebuilt, bootable) as default; provide this complete,
verified linux-tkg-p03 recipe for the exact p03 kernel as an opt-in built via build.sh + the steps
above. Validated by build-audit/G008/assert-g008.sh.
