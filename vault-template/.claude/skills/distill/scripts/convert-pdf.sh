#!/usr/bin/env bash
#
# Convert a PDF to Markdown in 10-sources/ using marker.
#
# marker runs fully local — nothing is uploaded. Install with:
#   pip install marker-pdf
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
. "$SCRIPT_DIR/lib.sh"

VAULT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
SOURCES="$VAULT_ROOT/10-sources"

if [ $# -ne 1 ]; then
  echo "usage: convert-pdf.sh <file.pdf>" >&2
  exit 2
fi

pdf="$1"
[ -f "$pdf" ] || { echo "convert-pdf: not found: $pdf" >&2; exit 1; }

if ! command -v marker_single >/dev/null 2>&1; then
  echo "convert-pdf: marker_single not found — pip install marker-pdf" >&2
  exit 1
fi

mkdir -p "$SOURCES"

base=$(basename "$pdf")
slug=$(slugify "${base%.*}")
[ -n "$slug" ] || slug="document"

out="$SOURCES/$slug.md"
if [ -e "$out" ]; then
  echo "convert-pdf: $out already exists — skipping"
  exit 0
fi

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

marker_single "$pdf" --output_dir "$tmp" --output_format markdown

converted=$(find "$tmp" -name '*.md' -type f | head -1)
[ -n "$converted" ] || { echo "convert-pdf: marker produced no markdown" >&2; exit 1; }

{
  echo "---"
  echo "type: source"
  echo "created: $(date +%Y-%m-%d)"
  echo "status: raw"
  echo "source: \"$(basename "$pdf")\""
  echo "---"
  echo
  cat "$converted"
} >"$out"

echo "convert-pdf: wrote $out"
echo "Review the output. If tables, headings, or text came out garbled, set"
echo "conversion: suspect in the frontmatter rather than repairing it by hand."
