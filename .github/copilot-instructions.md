# Copilot instructions

You are an expert Business Central AL developer. Always follow these rules.

## Project
This repo has two AL apps: `/app` (the PTE) and `/test` (the test app).
The app lets sales orders be booked into delivery windows with a daily capacity.

## Naming
- All objects start with the prefix `JV` followed by a space.
- Fields added to standard tables also get the `JV` prefix.
- Object IDs must be inside the range in app.json.
- File names: `<ObjectName>.<ObjectType>.al`, e.g. `DeliveryWindow.Table.al`.
- Use PascalCase for variables. Record variables are named after the table.

## Code style
- Always use `Rec.` on page fields.
- Every field on a page needs a ToolTip starting with "Specifies".
- Use Labels for all user-facing text, with a Comment for every placeholder.
- Error labels end with `Err`, confirm labels with `Qst`, messages with `Msg`.
- Never use `WITH` statements.
- Prefer `SetLoadFields` when reading a few fields from large tables.
- Use `DataClassification = CustomerContent` unless told otherwise.

## Tests
- Tests live in `/test/src`.
- Every test uses `// [SCENARIO]`, `// [GIVEN]`, `// [WHEN]`, `// [THEN]` comments.
- Put shared setup in the library codeunit `JV Library - Deliv. Win.`.
- Use `Library Assert`, not `Error` calls, to check results.
- Use `asserterror` followed by `Assert.ExpectedError`.
- Test procedure names describe the behaviour, e.g. `FullWindowRejectsNextOrder`.
- Set `TestPermissions = Disabled` only when you have to.

## Adding a field
1. Add the field to the table or table extension with the prefix.
2. Add Caption and DataClassification.
3. Add it to the page or page extension with a ToolTip.
4. Add it to the permission set if it is a new table.
5. Build to regenerate the g.xlf file.
6. Update the translation files.
7. Write a test for any validation logic.

## Translations
- We ship da-DK and de-DE.
- Never edit the g.xlf file by hand.
- Keep `state="needs-review-translation"` for machine translations.

## Reviews
When asked to review code, check naming, ToolTips, labels, tests and performance.

## Tools
Use the BC Code Atlas MCP server to look up base app code.
Use BC Telemetry Buddy for production issues.
Use NAB AL Tools for translations.
