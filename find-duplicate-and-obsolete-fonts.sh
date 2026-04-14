#!/bin/bash
set -eE -o pipefail

echo "Get all fonts and their characteristics"
time find . -type f \
	| pv -l --size "$(find . -type f | wc -l)" \
	| while read f; do
		fc-scan --format "%{family}\t%{slant}\t%{weight}\t%{width}\t%{fontversion}\t%{postscriptname}\t%{file}\n" "$f"
	done \
	| sort -V \
	> fonts.txt
wc -l fonts.txt

echo "Find duplicates"
cut -d'	' -f1-4 < fonts.txt \
	| pv -l --size "$(wc -l < fonts.txt)" \
	| uniq -d > fonts.duplicates.txt
wc -l fonts.duplicates.txt

echo "Find uniques"
cut -d'	' -f1-4 < fonts.txt \
	| pv -l --size "$(wc -l < fonts.txt)" \
	| uniq -u > fonts.uniques.txt
wc -l fonts.uniques.txt

echo "Find the latest version for each variant"
cut -d'	' -f1-4 < fonts.txt \
	| pv -l --size "$(wc -l < fonts.txt)" \
	| uniq | while read variant; do
	grep -e '^'"$variant" < fonts.txt | tail -1
done > fonts.latest.txt
wc -l fonts.latest.txt
# TODO: check e.g. "Roboto Mono,Roboto Mono Light": alternative names?

echo "Sort files to keep and files to delete"
cut -d'	' -f7 < fonts.latest.txt \
	| pv -l --size "$(wc -l < fonts.latest.txt)" \
	| sort -k 1b,1 -u > fonts.latest.files.txt
wc -l fonts.latest.files.txt
cut -d'	' -f7 < fonts.txt \
	| pv -l --size "$(wc -l < fonts.txt)" \
	| sort -k 1b,1 -u > fonts.files.txt
wc -l fonts.files.txt
join -t '	' -v 1 fonts.files.txt fonts.latest.files.txt \
	| pv -l --size "$(wc -l < fonts.files.txt)" \
	> fonts.obsolete.files.txt
wc -l fonts.obsolete.files.txt

#while IFS=$'\t' read family slant weight width
#time find . -type f \
#	| while read fontfile; do
#	mainfontname="$(otfinfo -p "$fontfile")"
#	if [ -z "$mainfontname" ]; then
#		continue
#	fi
#	fontversion="$(otfinfo -v "$fontfile")"
#	fc-scan --format="%{postscriptname}\n" "$fontfile" \
#		| while read fontname; do
#		echo "$fontname	$fontversion	$fontfile"
#	done
#done 2> fonts.err.txt \
#	| sort -rV \
#	| tee fonts.txt
