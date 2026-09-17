# Vault template

Scaffolding for the second-brain vault. The vault lives in its **own private
repository**, separate from this tooling repo — see `DESIGN.md` for why.

## Bootstrap

```bash
# 1. Create a new private repo on GitHub, then:
git clone git@github.com:<you>/<vault-repo>.git ~/vault
cp -R vault-template/. ~/vault/
cd ~/vault && git add -A && git commit -m "Initialize vault structure"
```

## Then, by hand

1. Open the folder as a vault in Obsidian.
2. Enable Sync and create the remote vault **with end-to-end encryption**.
   This is chosen at creation and cannot be changed later without recreating it.
   Store the password somewhere you will not lose it.
3. Install the Obsidian Web Clipper in Safari (macOS and iOS).
4. Create a Reminders list named `Inbox`, used for captured ideas only — never
   tasks.

Git runs on the Mac only. Sync moves files between devices; git keeps history.
Never commit from mobile.

## Layout

| Folder | Holds |
| --- | --- |
| `00-inbox/` | Raw captures awaiting distillation |
| `10-projects/` | Actionable work with an end date |
| `20-areas/` | Ongoing responsibilities |
| `30-sources/` | Books, articles, papers |
| `40-notes/` | Atomic permanent notes |
| `50-private/` | Excluded from Claude |
| `90-archive/` | Closed work |
| `pdf-originals/` | Source PDFs, git-ignored, fallback only |
