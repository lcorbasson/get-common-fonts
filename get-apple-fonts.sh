#!/bin/bash
set -eE -o pipefail

DESTDIR="/usr/local/share/fonts/Apple"
TMPDIR="$(mktemp -d)"

mkdir -p "$DESTDIR"

pushd "$TMPDIR"
wget -O- "https://developer.apple.com/fonts/" | sed -n \
	-e 's:<:\n<:g' -e 's:.*href="\([^"]*\)dmg".*:\1:' | while read dmg_url; do
		wget "$dmg_url"
	done
for dmg_file in *.dmg; do
	7z x "$dmg_file"
done
for d in *Fonts; do
	pushd "$d"
	for pkg_file in *.pkg; do
		xar -xvf "$pkg_file"
	done
	find . -name "Payload" | while read payload_file; do
		gunzip < "$payload_file" | cpio -idmv
	done
	popd
done
popd

find . -iname "*.ttf" -o -iname "*.otf" -exec cp -av {} "$DESTDIR/" \;

