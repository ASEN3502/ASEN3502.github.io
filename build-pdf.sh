#!/usr/bin/env bash
#
# Builds syllabus.pdf from the same Markdown the website renders.
#
#   ./build-pdf.sh
#
# Needs pandoc and a LaTeX engine:
#   sudo apt install pandoc texlive-xetex texlive-fonts-recommended
#
# The PDF is deliberately not committed -- rebuild it when you need to hand a
# copy to the department.

set -euo pipefail
cd "$(dirname "$0")"

# The YAML front matter is stripped first. Jekyll needs it, but pandoc would
# read `title:` as document metadata and emit a title block on top of the H1
# that is already in the body.
sed '1{/^---$/!q;};1,/^---$/d' syllabus.md | pandoc \
	--pdf-engine=xelatex \
	-V geometry:margin=0.9in \
	-V fontsize=10pt \
	-V colorlinks=true \
	-V linkcolor='[HTML]{0A3758}' \
	-V urlcolor='[HTML]{096FAE}' \
	-o syllabus.pdf -

echo "Wrote syllabus.pdf"
