#!/bin/bash
# SPDX-License-Identifier: MIT
set -eE -o pipefail

DESTDIR="/usr/local/share/fonts/Microsoft"
SRCDIRS=("$(dirname "$0")/Microsoft" "$@")
TMPDIR="$(mktemp --tmpdir -d "$(basename "$0").XXXXXX")"

mkdir -p "$DESTDIR"

pushd "$TMPDIR"
for SRCDIR in "${SRCDIRS[@]}"; do
	if [ ! -e "$SRCDIR" ]; then
		echo "$SRCDIR doesn't exist, skipping" >&2
		continue
	fi
	find "$SRCDIR" -maxdepth 1 -iname "*.iso" | while read iso_path; do
		iso_dir="$(dirname "$iso_path")"
		iso_file="$(basename "$iso_path")"
		7z x "$iso_dir/$iso_file" -o"$iso_file.dir"
		pushd "$iso_file.dir"
		mkdir -p fonts/boot-fonts
		find . \( -iname "*.tt?" -o -iname "*.otf" \) \
			-exec mv -v {} fonts/boot-fonts/ \;
		find . \( -ipath "./sources/install.wim" -o -ipath "./sources/install.esd" \) | while read install_package; do
			7z x "$install_package" -o"install.dir/"
			find . -ipath "./install.dir/*Windows/Fonts" | while read fonts_dir; do
				find "$fonts_dir" -type f | while read font; do
					mv "$font" fonts/
				done
			done
		done
		mv fonts "../$iso_file.fonts"
		popd
		rm -rf "$iso_file.dir"
	done
done
find . -maxdepth 1 -name "*.fonts" \
	-exec mv -v {} "$DESTDIR/" {} \;
popd

rm -rf "$TMPDIR"

