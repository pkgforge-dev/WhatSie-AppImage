#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
	cmake		    \
	kvantum 	    \
	lxqt-qtplugin   \
    pipewire-audio  \
    pipewire-jack   \
	qt6-declarative \
	qt6-location    \
	qt6-webchannel  \
	qt6-webengine   \
	qt6ct

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano

echo "Building WhatSie..."
echo "---------------------------------------------------------------"
REPO="https://github.com/keshavbhatt/whatsie"
if [ "${DEVEL_RELEASE-}" = 1 ]; then
    echo "Making nightly build of WhatSie..."
    echo "---------------------------------------------------------------"
    VERSION="$(git ls-remote "$REPO" HEAD | cut -c 1-9 | head -1)"
    git clone --depth 1 "$REPO" ./whatsie
else
	echo "Making stable build of WhatSie..."
	VERSION="$(git ls-remote --tags --sort="v:refname" "$REPO" | tail -n1 | sed 's/.*\///; s/\^{}//; s/^v//')"
	git clone --branch v"$VERSION" --single-branch --depth 1 "$REPO" ./whatsie
fi
echo "$VERSION" > ~/version

cd ./whatsie
cmake ./ \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="/usr" \
    -Bbuild
cmake --build build -j$(nproc)
cmake --install build
