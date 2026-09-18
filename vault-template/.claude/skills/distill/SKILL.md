---
name: distill
description: Process the vault inbox into source notes and atomic notes with suggested links. Use when the user says "distill", "process the inbox", or asks to turn captures into notes.
---

# Distill

Turn raw captures into linked knowledge. Run from the vault root.

Read `CLAUDE.md` first — it holds the conventions this skill assumes.

## 1. Flush pending captures

Run `scripts/flush-reminders.sh`. It moves the Reminders `Inbox` list into
`00-inbox/` and marks those reminders done.

macOS only. If it fails, report it and continue — spoken capture is one source,
not the only one.

## 2. Convert pending PDFs

For each PDF in `pdf-originals/` with no matching note in `30-sources/`, run
`scripts/convert-pdf.sh <file>`.

Inspect the output before distilling it. If tables are mangled, headings are
lost, or the text is visibly garbled, set `conversion: suspect` in the
frontmatter and say so in your report. Do not hand-repair the Markdown — that is
work nobody sustains.

## 3. Distill each raw item

For every file in `00-inbox/` with `status: raw`, read it fully, then produce:

**A source note** in `30-sources/`

- What it argues, in a few sentences
- Its key claims
- Verbatim quotes worth keeping, **in their original language**
- Where it came from

**Atomic notes** in `40-notes/`, one per idea

- The filename states the claim:
  `capture-without-processing-creates-a-dump.md`
- If you cannot phrase the filename as a claim, the note is not atomic. Split it
- If the note needs the word "and" to describe it, it is two notes
- Each links back to its source

**Suggested links**

Search `40-notes/` before concluding a note stands alone. For each new note,
find existing notes it **contradicts**, **extends**, or **exemplifies**, and
write the link with a phrase saying which.

This is the point of the whole exercise. A note with no links is a note that
will never be found again.

### Books and long PDFs

Distill the `==highlights==` only. The highlights are what the reader thought
worth marking; the rest is context.

Never summarize an unhighlighted book. A summary of something nobody read has no
place in a second brain — its value is not the book's content but what caught
this reader's attention.

## 4. Empty the inbox

Delete each raw capture once distilled. Git holds the history.

The inbox is a tray, not a shelf. If it does not reach zero, this step did not
happen.

## 5. Commit

One commit for the batch. Say what came in and what it connected to.

## Report

- How many items distilled, into how many notes
- **The most interesting connection you found** — the one the user would not
  have expected
- Anything skipped, and why

Write directly. Do not ask for approval note by note; the commit is the review
surface.
