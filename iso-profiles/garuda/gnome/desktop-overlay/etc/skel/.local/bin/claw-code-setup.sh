#!/bin/bash
# First-login provisioning for "claw code" (gajae-code / gajae-code (GJC)).
# Self-guards: exits if already installed, or if bun/network are unavailable.
set -u
command -v gjc >/dev/null 2>&1 && exit 0
command -v bun >/dev/null 2>&1 || exit 0
# Need a network connection; bail quietly if offline (will retry next login).
ping -c1 -W2 registry.npmjs.org >/dev/null 2>&1 || curl -sI --max-time 4 https://registry.npmjs.org >/dev/null 2>&1 || exit 0
notify-send "Claw Code" "Installing gajae-code ()…" 2>/dev/null || true
bun install -g gajae-code >/dev/null 2>&1 \
  && notify-send "Claw Code" "gjc is ready — run 'gjc' in a terminal." 2>/dev/null || true
