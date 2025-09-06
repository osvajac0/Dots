#!/bin/bash
# reload-dwm-colors.sh
wal -i "$1"  # Apply new wallpaper/colors
xrdb ~/.Xresources  # Reload X resources
