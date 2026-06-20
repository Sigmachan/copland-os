#!/bin/bash

swaynag \
-m '   Welcome to the Garuda Sway live environment! Click the "launch" button to start the installer. 󰁔' \
-Z "Launch the installer" 'sudo -E calamares' \
-e bottom \
-y overlay \
-f jetbrainsmono \
-s "Close" \
--background 2b2d32bb \
--border eceff4ff \
--border-bottom 2b2d32bb \
--button-background bf616add \
--text eceff4ff \
--button-text eceff4ff \
--message-padding 20 \
--button-border-size 1 \
--button-gap 10 \
--button-dismiss-gap 20 \
--button-margin-right 60 \
--button-padding 15
