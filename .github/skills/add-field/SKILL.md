---
name: add-field
description: Add a field end to end in /app, covering the table or table extension, pages, permissions, translations and a test. Use when a request says "add a field", "store X on the order" or similar.
---

# Add a field end to end

1. **Table.** On a standard table, use the app's `tableextension` for it and
   name the field `JV <Name>`. On our own tables, use a plain name.
   Set `Caption` and `DataClassification`. The ID comes from `app/app.json`.
2. **Logic.** If the field validates something, `OnValidate` calls a procedure
   in the feature's Mgt. codeunit. No logic in the trigger itself.
3. **Pages.** Add the field to every page users edit it on, next to a related
   field (`addafter`). Give it `ApplicationArea = All` and a "Specifies..." ToolTip.
4. **Permissions.** For a new table, add it to the `JV Delivery`
   permission set. A field on an existing table needs nothing.
5. **Translations.** Build, then run `refreshXlf` from the `nab-al-tools`
   MCP server to update the target XLIFF files.
6. **Test.** If the field has validation, add a test using the
   `write-al-test` skill.

## Done when

- The field shows on the page with a caption and a ToolTip.
- The target XLIFF files contain the new caption and ToolTip.
- Any validation is covered by a test that passes.
