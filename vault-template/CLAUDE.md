# Vault conventions

This is a personal knowledge vault. Notes are the product; everything here
serves getting the inbox emptied and ideas linked.

Full rationale lives in `DESIGN.md` in the tooling repo. This file is the
operating manual.

## Layout

| Folder | Holds |
| --- | --- |
| `00-inbox/` | Raw captures awaiting distillation. Gets emptied |
| `10-projects/` | Actionable work with an end date |
| `20-areas/` | Ongoing responsibilities |
| `30-sources/` | Books, articles, papers |
| `40-notes/` | Atomic permanent notes |
| `50-private/` | **Never read or write here.** Excluded via `.claudeignore` |
| `90-archive/` | Closed work |

## Naming

- Files and folders: English, `kebab-case`, no dates.
- Atomic notes are titled as a **claim**, not a topic:
  `capture-without-processing-creates-a-dump.md`, never `notes-on-capture.md`.
  If the filename does not state what the note argues, the note is not atomic
  yet.

## Frontmatter

Exactly these fields. Do not add others.

```yaml
---
type: note          # source | note | project | area
created: 2026-09-17
status: distilled   # raw | distilled
source: "[[deep-work]]"   # atomic notes only
---
```

## Links and tags

- **Folder** — what kind of note it is. Exactly one.
- **Link `[[ ]]`** — how ideas relate. Unlimited. This is where the value is.
- **Tag** — state only: `#distill`, `#reread`. **Never topics.** A topic gets a
  note and inbound links, not a tag.

## Language

- Notes are written in English.
- Captures arrive in any language. Normalize to English when distilling.
- **Verbatim quotes keep their original language.** A translated quote is a
  paraphrase in quotation marks. Mark the language when it is not English.
- Translate on request when reading. Do not store translations as separate
  notes.

## Distilling

For each item in `00-inbox/` with `status: raw`:

1. Write a **source note** in `30-sources/` — summary, key claims, verbatim
   quotes worth keeping.
2. Write **atomic notes** in `40-notes/` — one idea per note, titled as a claim,
   each linking back to its source.
3. Propose **links to existing notes** — what this contradicts, extends, or
   exemplifies. Search the vault before concluding a note is unconnected.
4. Delete the raw capture. Git holds the history.
5. Commit.

For books and long PDFs, distill the reader's `==highlights==`, not the full
text. The highlights are the signal; the rest is context. A summary of an unread
book does not belong here.

Write notes directly. Do not ask for approval note by note — the commit is the
review surface.

## Converted PDFs

Output carrying `conversion: suspect` came out of a lossy conversion. Read it
with suspicion and say so rather than distilling garbage silently. The original
PDF is available as a fallback.

## Weekly review

Report three things:

1. What is still sitting in `00-inbox/`.
2. **Orphan notes** — no links in or out.
3. **Proposed connections** between notes that have not yet met. This is the
   point of the review; the first two are housekeeping.
