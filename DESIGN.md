# Second Brain — Design

A personal knowledge system built on Obsidian and Claude Code.

This document records **what was decided and why**. The *why* matters more than
the *what*: when a decision feels wrong in six months, the rationale here tells
you whether the reasoning was flawed or the circumstances changed.

## Purpose

Capture work notes, reading, and ideas; distill them into linked atomic notes;
surface connections that would otherwise be lost.

The system optimizes for one thing above all: **the inbox gets emptied**. Most
personal knowledge systems fail at processing, not at capture. Every design
decision below defers to that.

## Architecture

Two layers, each doing exactly one job.

| Layer | Job | Where |
| --- | --- | --- |
| Obsidian Sync | Move the vault between Mac, iPhone, iPad | End-to-end encrypted, Standard plan |
| Git | Version history; the surface Claude reads and writes | Mac only, private repo |

Git is not a sync layer. Committing from a phone is friction enough to stop
capture, and capture that stops kills the system. Sync never versions; git never
touches mobile.

### Repository split

- **Tooling repo** (this one) — skills, scripts, this design document.
- **Vault repo** (separate, private) — the notes.

They have different lives. The vault makes thousands of trivial commits and is
never shared; tooling may eventually be. One repo would force the same rules on
both and leave an unusable history.

### Why not iCloud

Hosting a `.git` directory inside iCloud Drive is a documented failure mode:
iCloud syncs files without understanding that `.git` is a stateful database.
The `obsidian-git` plugin docs state plainly: *do not select "Store in iCloud"
on iOS*. There are filed issues of object corruption.

### Why not git on mobile

The `obsidian-git` docs describe the mobile implementation as *very unstable*
and recommend against it: no SSH, no rebase, crashes on clone. Resolving merge
conflicts from an iPad is exactly the friction this design avoids.

## Vault structure

```
00-inbox/      Tray. Gets emptied, never accumulates
10-sources/    Books, articles, papers — the raw material
20-notes/      Atomic permanent notes — the knowledge
30-private/    Excluded from Claude via .claudeignore
```

Pure Zettelkasten. This vault holds knowledge, not work — permanent notes that
want to be linked, not actionable material with an end date. Actionable/project
work is deliberately out of scope and lives in whatever system already tracks
it; mixing the two breaks the one thing this vault optimizes for, which is
notes finding each other.

A note that is superseded is never moved to an archive folder — it stays in
place and gets linked as `supersedes` / `superseded-by`. Moving it would hide
the fact that you changed your mind, which is exactly the signal a folder-based
archive destroys and a link preserves.

## Flows

### Capture

| Source | Path |
| --- | --- |
| Web article | Obsidian Web Clipper (Safari on macOS/iOS) → `00-inbox/` |
| Quick capture | Apple Notes folder `Inbox` → flushed on distill |
| PDF | Local folder, git-ignored → converted on distill |

Apple Notes is the capture buffer for quick captures because **Obsidian Sync
does not run in the background on iOS** — the app must be open to sync. Notes
syncs natively in the background via iCloud. The folder is dedicated and holds
ideas only, never anything else.

### Distill — on demand

1. Flush the Apple Notes `Inbox` folder into `00-inbox/`
2. Convert pending PDFs with `marker`; set `conversion: suspect` on bad output
3. For each raw item, produce:
   - a **source note** in `10-sources/` — summary, key claims, verbatim quotes
   - one or more **atomic notes** in `20-notes/` — one idea each, titled as a
     claim, linked to the source
   - **suggested links** to existing notes: what this contradicts, extends,
     or exemplifies
4. Delete the raw capture — git holds the history
5. Commit

For books, distill the reader's `==highlights==`, not the full text. **A summary
of a book you did not read is worthless here.** The value of a note is not the
book's content — that is in the book — but what caught your attention and what
it connected to.

Distillation is manual, not automatic on capture. Automatic processing distills
things you never actually read and fills the vault with noise.

Claude writes directly rather than proposing note by note. Approving each note
reintroduces the friction the system exists to remove; the git diff is the
safety net and reviewing a commit is faster than twenty approvals.

### Query

Natural-language questions answered against the vault, citing notes.

### Weekly review

Pending inbox, orphan notes (no links in or out), and **connections Claude
proposes** between notes that have not yet met. The third is the only moment the
system returns something you did not put in. A second brain that only returns
what you filed is a filing cabinet.

## Conventions

| Element | Rule |
| --- | --- |
| File and folder names | English, `kebab-case`, no dates |
| Atomic note titles | A claim, not a topic: `capture-without-processing-creates-a-dump.md` |
| Note content | English (canonical) |
| Verbatim quotes | **Original language, always** |
| Frontmatter | `type`, `created`, `status`, `source`. Nothing else |
| Folder | What *kind* of note it is. Exactly one |
| Link `[[ ]]` | How ideas *relate*. Unlimited — this is where the value lives |
| Tag | *State* only: `#distill`, `#reread`. **Never topics** |

### Frontmatter

```yaml
---
type: note          # source | note
created: 2026-09-17
status: distilled   # raw | distilled
source: "[[deep-work]]"   # atomic notes only
---
```

`modified` is what git is for. `author` belongs on the source note, not on every
atomic note. Fields you never query are noise that drifts out of sync. Adding a
field later is free; removing one from 3,000 notes is not.

### No topic tags

The temptation is `#productivity`, `#ai`, `#management`. Resist it. A tag is a
flat list that tells you nothing. A link to `[[productivity]]` is a note where
you can write *why* those things relate.

### Language

Capture happens in whatever language comes out — friction at the entry point is
what kills the system. Distillation normalizes notes to English. Translation is
available on request when reading.

Verbatim quotes are the exception and stay in their original language. A
translated quote is a paraphrase wearing quotation marks.

## PDF handling

PDFs are converted to Markdown rather than stored as binaries. This solves three
problems at once: Sync's 5 MB per-file limit on the Standard plan, the absence of
a working PDF annotation plugin (Annotator is abandoned and broken on iOS 16.3+),
and git's inability to diff binaries. The vault stays plain text.

`marker` is the converter: best quality among the tools that run on Apple
Silicon, and fully local — nothing leaves the machine.

Conversion is lossy on complex layouts, tables, figures, and scanned documents.
Bad output is marked `conversion: suspect` rather than hand-corrected; manually
fixing the Markdown of a 300-page book is work nobody does. The original PDF
stays in a git-ignored folder as a fallback.

### Converter comparison

| Tool | Quality* | Runs on Apple Silicon |
| --- | --- | --- |
| olmOCR | 82.4 | No — needs 12 GB VRAM |
| **marker** | **76.0** | Yes |
| MinerU | 72.7–75.2 | Yes — better on scans, formulas, tables |
| docling | 50.3 | Yes, but quality is disqualifying |

<sub>*olmOCR-bench, 1,403 PDFs. All tools run fully local; none require an
external API.</sub>

Switch to MinerU if the real corpus turns out to be scans or formula-heavy.

Note: `marker`'s model weights carry a restricted license. Fine for personal
use; revisit before any commercial use.

## Privacy

Data is private. Two consequences:

- Distillation sends note content to the API. Material that must never leave the
  machine goes in `30-private/`, excluded via `.claudeignore`. A folder is a
  physical gesture; a frontmatter flag gets forgotten on the day it matters.
- Obsidian Sync uses **end-to-end encryption**. This is chosen when the remote
  vault is created and **cannot be changed afterwards** without recreating it.
  Losing the password means losing the remote vault — acceptable, because git is
  the real backup. Sync is transport, not backup.

## Migrating the existing vault

The existing vault holds fewer than 500 notes. At that scale, migration is cheap
and reversible: Claude classifies everything in one pass and git allows a
rollback. Whether it is organized or abandoned stops mattering.

Everything is imported by default — deleting is irreversible and the cost of
keeping a bad note is near zero. Claude flags likely-dead notes (one-liners,
context-free fragments, duplicates) as a review list.

## Out of scope, deliberately

- **Work connectors** (Notion, Drive, Jira, Slack) — a later phase. Connecting a
  firehose before the system works is how vaults become dumps.
- **Content generation** (blog drafts from notes) — needs critical mass first.
  Without a few hundred good notes the output is generic.

## Phases

| Phase | Deliverable |
| --- | --- |
| 0 | Vault repo, structure, `CLAUDE.md`, Sync with E2E |
| 1 | Capture working — Web Clipper and Apple Notes bridge |
| 2 | Distillation — skill and `marker` pipeline |
| 3 | Triage of the existing vault |
| 4 | Weekly review |

Capture comes before distillation on purpose. A system with nothing in it has
nothing to distill.

## Open risks

| Risk | Status |
| --- | --- |
| Obsidian Sync pricing | **Unverified** — vendor page was unreachable during research |
| `marker` quality on the real corpus | Untested until Phase 2 |
| E2E encryption choice | **Irreversible** once the remote vault exists |
| Apple Notes bridge | macOS-only; needs rebuilding on a new machine |
