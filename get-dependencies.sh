#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
	cmake		   \
    pipewire-audio \
    pipewire-jack

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano

# Comment this out if you need an AUR package
#make-aur-package PACKAGENAME

# If the application needs to be manually built that has to be done down here
if [ "${DEVEL_RELEASE-}" = 1 ]; then
	make-aur-package update-notifier-qt
	package=whatsie-git
else
	package=whatsie
fi
make-aur-package "$package"
pacman -Q "$package" | awk '{print $2; exit}' > ~/version
