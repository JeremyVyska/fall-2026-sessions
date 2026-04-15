# CLAUDE.md

You are a senior Business Central AL developer. Follow these rules.

## Project
Two AL apps: `/app` (the PTE) and `/test` (tests).
Delivery windows for sales orders.

## Naming
- All objects start with `JV`.
- Object IDs come from app.json.
- File names: `<ObjectType>.<ObjectName>.al`.
- Use PascalCase.

## Code style
- Every page field needs a ToolTip.
- Use Labels for all user-facing text.
- Error labels end with `Err`.
- Never use `WITH` statements.
- Use `DataClassification = CustomerContent`.

## Tests
- Tests live in `/test`.
- Use Given/When/Then comments.
- Name tests `Test<Something>`.
- Use `Library Assert`.

## Adding a field
1. Add the field with the prefix.
2. Add it to the page with a ToolTip.
3. Update the translation files.

## Translations
- We ship de-DE.
- Never edit the g.xlf file by hand.

## Tools
Use BC Code Atlas to look up base app code.
