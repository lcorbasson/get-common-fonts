#!/bin/bash
set -eE -o pipefail

DESTDIR="/usr/local/share/fonts/Apple"
TMPDIR="$(mktemp --tmpdir -d "$(basename "$0").XXXXXX")"

mkdir -p "$DESTDIR"

pushd "$TMPDIR"
wget -O- "https://developer.apple.com/fonts/" | sed -n \
	-e 's:<:\n<:g' -e 's:.*href="\([^"]*\)dmg".*:\1:' | while read dmg_url; do
		wget "$dmg_url"
	done
find . -maxdepth 1 -name "*.dmg" -exec 7z x {} \;
find . -maxdepth 1 -type d -name "*Fonts" | while read d; do
	pushd "$d"
	find . -maxdepth 1 -name "*.pkg" -exec xar -xvf {} \;
	find . -name "Payload" | while read payload_file; do
		gunzip < "$payload_file" | cpio -idmv
	done
	popd
done
popd

find . -iname "*.ttf" -o -iname "*.otf" -exec mv -v {} "$DESTDIR/" \;

rm -rf "$TMPDIR"
