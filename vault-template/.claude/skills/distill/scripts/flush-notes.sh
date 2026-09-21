#!/usr/bin/env bash
#
# Move captured ideas from the Apple Notes "Inbox" folder into the vault inbox.
#
# Runs on demand rather than on a timer: a scheduled daemon that stops working
# fails silently, and you find out weeks of captures later.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
. "$SCRIPT_DIR/lib.sh"

VAULT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
INBOX="$VAULT_ROOT/00-inbox"
FOLDER_NAME="${NOTES_INBOX_FOLDER:-Inbox}"
ARCHIVE_FOLDER_NAME="${NOTES_ARCHIVE_FOLDER:-Archived}"

if ! command -v osascript >/dev/null 2>&1; then
  echo "flush-notes: osascript not found — macOS only" >&2
  exit 1
fi

mkdir -p "$INBOX"

RS=$'\036'
US=$'\037'

raw=$(osascript <<APPLESCRIPT
set rs to ASCII character 30
set us to ASCII character 31
set out to ""
tell application "Notes"
  set inboxFolder to folder "$FOLDER_NAME"
  repeat with n in (notes of inboxFolder)
    set theBody to ""
    try
      set theBody to plaintext of n
    end try
    set out to out & (id of n as string) & us & (name of n) & us & theBody & rs
  end repeat
end tell
return out
APPLESCRIPT
)

count=0
ids_processed=()
while IFS= read -r -d "$RS" record; do
  [ -n "$record" ] || continue

  note_id="${record%%"$US"*}"
  rest="${record#*"$US"}"
  title="${rest%%"$US"*}"
  body="${rest#*"$US"}"

  # `name of n` is the note's first line, so the body already repeats the
  # title — drop that first line to avoid capturing it twice.
  body="${body#"$title"}"
  body="${body#$'\n'}"

  [ -n "$title" ] || continue

  slug=$(slugify "$title")
  [ -n "$slug" ] || slug="capture"

  # Captures are transient and deleted once distilled, so the timestamp is for
  # uniqueness only — it does not contradict the no-dates naming convention.
  file="$INBOX/$(date +%Y-%m-%d-%H%M%S)-$slug.md"
  n=2
  while [ -e "$file" ]; do
    file="$INBOX/$(date +%Y-%m-%d-%H%M%S)-$slug-$n.md"
    n=$((n + 1))
  done

  {
    echo "---"
    echo "type: note"
    echo "created: $(date +%Y-%m-%d)"
    echo "status: raw"
    echo "source: apple-notes"
    echo "---"
    echo
    echo "$title"
    [ -n "$body" ] && { echo; echo "$body"; }
  } >"$file"

  ids_processed+=("$note_id")
  count=$((count + 1))
done <<<"$raw"

if [ "$count" -eq 0 ]; then
  echo "flush-notes: nothing pending in \"$FOLDER_NAME\""
  exit 0
fi

# Only after every file is written. A note added in between would be archived
# without being captured; the window is a few milliseconds.
id_list=$(printf '"%s", ' "${ids_processed[@]}")
id_list="{${id_list%, }}"

osascript <<APPLESCRIPT >/dev/null
set idList to $id_list
tell application "Notes"
  if not (exists folder "$ARCHIVE_FOLDER_NAME") then
    make new folder with properties {name:"$ARCHIVE_FOLDER_NAME"}
  end if
  set archiveFolder to folder "$ARCHIVE_FOLDER_NAME"
  repeat with anId in idList
    move (note id anId) to archiveFolder
  end repeat
end tell
APPLESCRIPT

echo "flush-notes: moved $count capture(s) into 00-inbox/, archived in Notes"
