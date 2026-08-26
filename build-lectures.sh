#!/usr/bin/env bash
#
# Exports every lectures/<id>.xopp to lectures/<id>.pdf -- the annotated
# version of the slides, with the writing from class.
#
#   ./build-lectures.sh            # export the ones whose .xopp is newer
#   ./build-lectures.sh -f         # re-export everything
#
# Needs Xournal++ (native `xournalpp`, or the flatpak).

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

echo "Done."
