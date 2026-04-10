#!/bin/bash
set -eE -o pipefail

DESTDIR="/usr/local/share/fonts/Google"
SRCURL="https://github.com/google/fonts/archive/main.tar.gz"
TMPDIR="$(mktemp --tmpdir -d "$(basename "$0").XXXXXX")"

mkdir -p "$DESTDIR"

pushd "$TMPDIR"
archive_file="google-fonts.tar.gz"
wget -O "$archive_file" \
	"$SRCURL"
tar -zxf "$archive_file"
grep --include '*METADATA.pb' -H -e '^category: ' -R "fonts-main/" \
	| sed -e 's|^\([^:]*\)/METADATA\.pb:category: "\([^"]*\)"$|\2\t\1|' \
	| sort -u \
	| while IFS=$'\t' read category fontdir; do
	mkdir -p "$DESTDIR/$category/"
	find "$fontdir" \( -iname "*.ttf" -o -iname "*.otf" \) \
		-exec mv -v {} "$DESTDIR/$category/" \;
done
popd

rm -rf "$TMPDIR"
