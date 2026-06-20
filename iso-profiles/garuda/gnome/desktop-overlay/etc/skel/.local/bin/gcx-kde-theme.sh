#!/bin/bash
# Apply the KDE look for the Garuda x CachyOS ISO: the user's icons (Slot-Dark-Icons) + cursor
# (Bibata) + a dark dr460nized-spirit theme (Layan global + kvantum + dark colors). garuda-dr460nized
# itself is mutually exclusive with the garuda-gnome base, so this reproduces the dark/blurred look
# from standalone components. Runs once per user, KDE sessions only.
command -v kwriteconfig6 >/dev/null 2>&1 || exit 0
stamp="$HOME/.config/.gcx-kde-theme-applied"
[ -f "$stamp" ] && exit 0
# icons + cursor (user's COSMIC look)
kwriteconfig6 --file kdeglobals --group Icons --key Theme Slot-Dark-Icons
kwriteconfig6 --file kcminputrc --group Mouse --key cursorTheme Bibata-Modern-Classic
kwriteconfig6 --file kcminputrc --group Mouse --key cursorSize 24
# dark dr460nized-spirit: kvantum widget style + dark color scheme
kwriteconfig6 --file kdeglobals --group KDE --key widgetStyle kvantum
# best-effort: apply the Layan dark global theme + cursor live if a Plasma session is up
command -v plasma-apply-lookandfeel >/dev/null 2>&1 && \
  { plasma-apply-lookandfeel -a com.github.vinceliuice.Layan-dark 2>/dev/null \
    || plasma-apply-lookandfeel -a com.github.vinceliuice.Layan 2>/dev/null; } || true
command -v plasma-apply-cursortheme >/dev/null 2>&1 && plasma-apply-cursortheme Bibata-Modern-Classic 2>/dev/null || true
command -v plasma-apply-colorscheme >/dev/null 2>&1 && plasma-apply-colorscheme BreezeDark 2>/dev/null || true
touch "$stamp"
