#!/usr/bin/env bash
#
# Shared helpers. Source, do not execute.
#

# Turn arbitrary text into an ASCII kebab-case slug.
#
# Accents are folded with one literal substitution per character rather than
# `iconv //TRANSLIT`: iconv emits "?" on some Linux builds and behaves
# differently again on macOS. Bracket classes like [áéíóú] are no good either —
# in the C locale sed matches them byte by byte, and every one of these
# characters shares a UTF-8 lead byte, so "ó" comes out as "ao".
slugify() {
  printf '%s' "$1" \
    | sed -e 's/á/a/g; s/à/a/g; s/ä/a/g; s/â/a/g; s/ã/a/g' \
          -e 's/é/e/g; s/è/e/g; s/ë/e/g; s/ê/e/g' \
          -e 's/í/i/g; s/ì/i/g; s/ï/i/g; s/î/i/g' \
          -e 's/ó/o/g; s/ò/o/g; s/ö/o/g; s/ô/o/g; s/õ/o/g' \
          -e 's/ú/u/g; s/ù/u/g; s/ü/u/g; s/û/u/g' \
          -e 's/ñ/n/g; s/ç/c/g' \
          -e 's/Á/A/g; s/À/A/g; s/Ä/A/g; s/Â/A/g; s/Ã/A/g' \
          -e 's/É/E/g; s/È/E/g; s/Ë/E/g; s/Ê/E/g' \
          -e 's/Í/I/g; s/Ì/I/g; s/Ï/I/g; s/Î/I/g' \
          -e 's/Ó/O/g; s/Ò/O/g; s/Ö/O/g; s/Ô/O/g; s/Õ/O/g' \
          -e 's/Ú/U/g; s/Ù/U/g; s/Ü/U/g; s/Û/U/g' \
          -e 's/Ñ/N/g; s/Ç/C/g' \
    | tr '[:upper:]' '[:lower:]' \
    | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//' \
    | cut -c1-60
}
