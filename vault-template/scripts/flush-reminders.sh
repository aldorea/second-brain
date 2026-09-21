#!/usr/bin/env bash
#
# Move captured ideas from the Reminders "Inbox" list into the vault inbox.
#
# Runs on demand rather than on a timer: a scheduled daemon that stops working
# fails silently, and you find out weeks of captures later.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
. "$SCRIPT_DIR/lib.sh"

VAULT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
INBOX="$VAULT_ROOT/00-inbox"
LIST_NAME="${REMINDERS_LIST:-Inbox}"

if ! command -v osascript >/dev/null 2>&1; then
  echo "flush-reminders: osascript not found — macOS only" >&2
  exit 1
fi

mkdir -p "$INBOX"

RS=$'\036'
US=$'\037'

raw=$(osascript <<APPLESCRIPT
set rs to ASCII character 30
set us to ASCII character 31
set out to ""
tell application "Reminders"
  repeat with r in (reminders of list "$LIST_NAME" whose completed is false)
    set theBody to ""
    try
      if body of r is not missing value then set theBody to body of r
    end try
    set out to out & (name of r) & us & theBody & rs
  end repeat
end tell
return out
APPLESCRIPT
)

count=0
while IFS= read -r -d "$RS" record; do
  [ -n "$record" ] || continue

  title="${record%%"$US"*}"
  body="${record#*"$US"}"
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
    echo "source: reminders"
    echo "---"
    echo
    echo "$title"
    [ -n "$body" ] && { echo; echo "$body"; }
  } >"$file"

  count=$((count + 1))
done <<<"$raw"

if [ "$count" -eq 0 ]; then
  echo "flush-reminders: nothing pending in \"$LIST_NAME\""
  exit 0
fi

# Only after every file is written. A reminder added in between would be
# completed without being captured; the window is a few milliseconds.
osascript <<APPLESCRIPT >/dev/null
tell application "Reminders"
  repeat with r in (reminders of list "$LIST_NAME" whose completed is false)
    set completed of r to true
  end repeat
end tell
APPLESCRIPT

echo "flush-reminders: moved $count capture(s) into 00-inbox/"
