# AGENTS.md

Delivery Windows: a Business Central per-tenant extension that books sales
orders into delivery windows with a daily capacity. Class demo repo, kept
small on purpose.

## Layout

- `/app`: the PTE. Source in `app/src`.
- `/test`: the test app. Depends on `/app`. Source in `test/src`.

## Conventions

- Prefix every object, and every field added to a standard table, with `JV `.
- Object IDs come from `idRanges` in that app's `app.json`.
- Namespace `JeremyVyskaClasses.DeliveryWindows`; tests add `.Test`.
- File names follow CodeCop AA0215: `JVDeliveryWindow.Table.al`.
- User-facing text goes in Labels. Suffixes: `Err`, `Qst`, `Msg`, `Lbl`.
  Every placeholder gets a `Comment`.
- Every page field has a ToolTip that starts with "Specifies".
- Business logic lives in codeunits, not in triggers or pages.
- New behaviour in `/app` gets a test in `/test`.
- Look up base app events and signatures. Don't guess them.

## Rules for some files only

`.github/instructions/*.instructions.md` hold rules scoped by `applyTo`:
tests (`test/**`) and translations (`**/*.xlf`). Copilot loads them for
matching files. Other agents: read the matching file before you edit.

## Routing

Skills live in `.github/skills/<name>/SKILL.md`. Load one when its task comes up:

- Writing or changing tests: `write-al-test`.
- Adding a field to a table and its pages: `add-field`.
