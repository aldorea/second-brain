#!/usr/bin/env bash
#
# Build a throwaway vault with fake content, to try the skills without
# touching the real one.
#
#   ./make-sandbox.sh          # builds /tmp/vault-sandbox
#   ./make-sandbox.sh ~/scratch/vault
#
# Re-running wipes and rebuilds it. That is the point: a test you cannot
# repeat from a clean state tells you nothing the second time.
#
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${1:-/tmp/vault-sandbox}"

if [ -e "$TARGET" ]; then
  # Only ever remove something this script made, never an arbitrary path.
  if [ ! -f "$TARGET/.sandbox" ]; then
    echo "make-sandbox: $TARGET exists and was not made by this script." >&2
    echo "Remove it yourself or pick another path." >&2
    exit 1
  fi
  rm -rf "$TARGET"
fi

mkdir -p "$TARGET"
cp -R "$REPO_ROOT/vault-template/." "$TARGET/"
touch "$TARGET/.sandbox"

cd "$TARGET"

# --- Raw captures, waiting to be distilled ---------------------------------

cat >00-inbox/clipped-the-attention-economy.md <<'EOF'
---
type: source
created: 2026-09-18
status: raw
source: https://example.com/attention-economy
---

# The Attention Economy Is Eating Your Tools

Every tool that competes for attention eventually optimises for engagement
rather than for the job it was hired to do. Note-taking apps are no exception:
the ones that grew fastest added social feeds, streaks and daily prompts.

The tools that survived without that turn share one trait: they are boring to
open. You open them because you need something, not because they pulled you in.

There is a second-order effect. When capture is frictionless but processing is
not, the tool accumulates. A system that never asks you to decide anything ends
up holding everything, which is the same as holding nothing.

"The measure of a knowledge system is not what it lets you save. It is what it
makes you throw away." — attributed to an unnamed archivist
EOF

cat >00-inbox/2026-09-18-081500-idea-sobre-el-inbox.md <<'EOF'
---
type: note
created: 2026-09-18
status: raw
source: reminders
---

Se me ocurre que el inbox no deberia tener contador. Si ves 47 pendientes te
rindes antes de empezar. Mejor que muestre solo el mas antiguo.
EOF

# --- Existing notes, so distill has something to link against --------------

cat >30-sources/deep-work.md <<'EOF'
---
type: source
created: 2026-08-02
status: distilled
---

# Deep Work — Cal Newport

Argues that uninterrupted concentration is both increasingly rare and
increasingly valuable, and that the two facts compound.

## Key claims

- Cognitively demanding work cannot be done in fragments
- The ability to concentrate is trainable, not fixed
- Shallow work expands to fill whatever time is left unprotected

## Quotes

> Clarity about what matters provides clarity about what does not.
EOF

cat >40-notes/context-switching-has-a-fixed-cost.md <<'EOF'
---
type: note
created: 2026-08-02
status: distilled
source: "[[deep-work]]"
---

# Context switching has a fixed cost

Resuming an interrupted task requires rebuilding the mental state it depended
on. That rebuild takes roughly the same time regardless of how long the
interruption lasted, which is why a two-minute interruption is not two minutes
lost.
EOF

cat >40-notes/frictionless-capture-shifts-work-downstream.md <<'EOF'
---
type: note
created: 2026-08-14
status: distilled
source: "[[deep-work]]"
---

# Frictionless capture shifts work downstream

Making it easier to save something does not reduce the total work — it moves the
deciding to a later moment. Systems that optimise only the capture step
accumulate a debt that comes due at review time.
EOF

# --- Legacy mess, for triage to chew on ------------------------------------

mkdir -p "Notas sueltas" "Proyectos 2025"

cat >"Notas sueltas/Reunión con diseño.md" <<'EOF'
Reunión del martes. Hablamos del rediseño del onboarding.

- Falta decidir el copy
- Marta manda mockups el jueves

#productividad #trabajo #reuniones
EOF

cat >"Notas sueltas/productividad.md" <<'EOF'
---
titulo: Productividad
autor: yo
modificado: 2025-03-11
tags: [productividad, gtd, notas]
---

Ideas sueltas sobre productividad. Pendiente de ordenar.

El cambio de contexto es caro. Cada vez que cambias de tarea pierdes tiempo
reconstruyendo dónde estabas.
EOF

cat >"Notas sueltas/sin titulo.md" <<'EOF'
mirar esto luego https://example.com/algo
EOF

cat >"Notas sueltas/Untitled 2.md" <<'EOF'
EOF

cat >"Proyectos 2025/migracion-crm.md" <<'EOF'
---
status: done
---

# Migración CRM

Cerrado en noviembre. Quedó pendiente documentar el mapeo de campos.
EOF

# --- A PDF placeholder, so the conversion path is visible ------------------

cat >pdf-originals/README.md <<'EOF'
Drop a real PDF here to exercise scripts/convert-pdf.sh.
That path needs `pip install marker-pdf` and is the one step this sandbox
cannot fake.
EOF

git init -q
git add -A
git commit -qm "Sandbox fixtures"

cat <<EOF

Sandbox ready at $TARGET

  cd $TARGET
  claude

Then try, in this order:

  /triage    proposes how the legacy mess maps onto the structure
  /distill   turns the two inbox items into linked notes
  /review    reports inbox, orphans and proposed connections

It is a git repo, so you can inspect exactly what each skill changed:

  git diff HEAD
  git reset --hard HEAD     # undo and try again

Rebuild from scratch any time with: $0 $TARGET
EOF
