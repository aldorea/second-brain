---
name: triage
description: Analyze an existing Obsidian vault and propose how to map it onto this system's structure. Use once, when adopting a vault that predates these conventions.
---

# Triage

Map an existing vault onto the structure in `CLAUDE.md`.

Run once, when adopting a vault built under different conventions.

**Propose. Move nothing until the user approves the plan.**

## 1. Discover what is actually there

Do not assume a structure. Measure it:

- Folder layout, and note count per folder
- Frontmatter keys in use, and how consistently they appear
- Tags in use, with frequency
- Link density — how many notes link out, how many are isolated
- Last-modified spread — is this vault alive or abandoned?
- Naming patterns — dates, spaces, accents, title case

**Report this before proposing anything.** The user may be surprised by their
own vault, and being surprised changes what they want done with it.

## 2. Classify every note

| Destination | What goes there |
| --- | --- |
| `30-sources/` | Notes *about* something read — book, article, talk |
| `40-notes/` | Notes making a claim of the user's own |
| `10-projects/` | Anything with a deadline or a deliverable |
| `20-areas/` | Ongoing responsibilities |
| `90-archive/` | Finished, superseded, or dead |

When a note does not fit, say so rather than forcing it. A note that resists
classification is usually two notes wearing one filename.

## 3. Flag discard candidates

Everything is kept by default — deleting is irreversible and a bad note costs
almost nothing to keep. But list what looks dead:

- Under ~50 words with no links
- Fragments with no context — a bare URL, a stray sentence
- Near-duplicates: say which one to keep and why
- Empty notes, and templates left unfilled

Present a list the user reviews. Do not delete.

## 4. Report conflicts with the conventions

Name what has to change, **with volumes** — "rename 340 files" and "rename 12
files" are different decisions:

- Filenames with accents, spaces, or dates
- Topic tags that should become notes with inbound links
- Frontmatter keys outside the four allowed
- Note titles that are topics rather than claims

## 5. Propose a plan

Ordered, reversible, smallest first. Each step is one commit that can be
inspected and rolled back on its own.

Then stop and wait for approval.

## Safety

The vault is the user's accumulated thinking and may not be backed up anywhere
else. Before the first step of any approved plan, confirm the working tree is
clean and committed. If it is not, stop and say so.
