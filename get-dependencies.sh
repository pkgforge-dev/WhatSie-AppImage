#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
	cmake		   \
	kvantum 	   \
	lxqt-qtplugin  \
    pipewire-audio \
    pipewire-jack  \
	qt6-declarative qt6-location qt6-webchannel qt6-webengine
	qt6ct

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano

# Comment this out if you need an AUR package
#make-aur-package PACKAGENAME

# If the application needs to be manually built that has to be done down here
#if [ "${DEVEL_RELEASE-}" = 1 ]; then
#	make-aur-package update-notifier-qt
#	package=whatsie-git
#else
#	package=whatsie
#fi
#make-aur-package "$package"
#pacman -Q "$package" | awk '{print $2; exit}' > ~/version
echo "Building WhatSie..."
echo "---------------------------------------------------------------"
REPO="https://github.com/keshavbhatt/whatsie"
if [ "${DEVEL_RELEASE-}" = 1 ]; then
    echo "Making nightly build of WhatSie..."
    echo "---------------------------------------------------------------"
    VERSION="$(git ls-remote "$REPO" HEAD | cut -c 1-9 | head -1)"
    git clone "$REPO" ./whatsie
else
	echo "Making stable build of WhatSie..."
	VERSION="$(git ls-remote --tags --sort="v:refname" "$REPO" | tail -n1 | sed 's/.*\///; s/\^{}//; s/^v//')"
	git clone --branch v"$VERSION" --single-branch "$REPO" ./whatsie
fi
echo "$VERSION" > ~/version

mkdir -p ./AppDir/bin
cmake -S ./ \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="/usr" \
    -Bbuild
cmake --build build -j$(nproc)
cmake --install build
