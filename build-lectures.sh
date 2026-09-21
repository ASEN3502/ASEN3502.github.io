#!/usr/bin/env bash
#
# Exports every lectures/<id>.xopp to lectures/<id>.pdf -- the annotated
# version of the slides, with the writing from class -- then concatenates them
# into lectures/all-notes.pdf, the single file linked at the top of the lecture
# notes page.
#
#   ./build-lectures.sh            # export the ones whose .xopp is newer
#   ./build-lectures.sh -f         # re-export everything
#
# Needs Xournal++ (native `xournalpp`, or the flatpak) and pdfunite (poppler-utils).

set -euo pipefail
cd "$(dirname "$0")"

force=""
[[ "${1:-}" == "-f" ]] && force=1

if command -v xournalpp >/dev/null; then
	xpp() { xournalpp "$@"; }
elif flatpak info com.github.xournalpp.xournalpp >/dev/null 2>&1; then
	# --file-forwarding is not set up for this app, so pass absolute paths and
	# grant the lectures directory explicitly.
	xpp() { flatpak run --filesystem="$PWD/lectures" com.github.xournalpp.xournalpp "$@"; }
else
	echo "Xournal++ not found (install it, or: flatpak install flathub com.github.xournalpp.xournalpp)" >&2
	exit 1
fi

shopt -s nullglob
for xopp in lectures/*.xopp; do
	pdf="${xopp%.xopp}.pdf"
	if [[ -z "$force" && -f "$pdf" && "$pdf" -nt "$xopp" ]]; then
		echo "up to date: $pdf"
		continue
	fi
	echo "exporting:  $pdf"
	xpp "$PWD/$xopp" -p "$PWD/$pdf"
done

# The combined file is built from whatever lecture PDFs exist, in id order.
# all-notes.pdf itself is excluded so rebuilds do not nest the previous copy.
all="lectures/all-notes.pdf"
pdfs=()
for pdf in lectures/*.pdf; do
	[[ "$pdf" == "$all" ]] && continue
	pdfs+=("$pdf")
done

if [[ ${#pdfs[@]} -eq 0 ]]; then
	echo "no lecture PDFs; skipping $all"
elif ! command -v pdfunite >/dev/null; then
	echo "pdfunite not found (sudo apt install poppler-utils); skipping $all" >&2
else
	echo "combining:  $all"
	pdfunite "${pdfs[@]}" "$all"
fi

echo "Done."
