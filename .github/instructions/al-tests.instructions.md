---
name: AL tests
description: Rules for code in the test app.
applyTo: 'test/**'
---

- Test codeunits use `Subtype = Test`. One codeunit per feature area, tagged `// [FEATURE]`.
- Every test reads `// [SCENARIO]`, then `// [GIVEN]`, `// [WHEN]`, `// [THEN]`.
- Setup goes through `JV Library - Deliv. Win.`. Don't build records inline.
- Prefer Microsoft test libraries (`Library - Sales`, `Library - Inventory`) for standard data.
- Check results with `Library Assert`. Expected failures: `asserterror`, then `Assert.ExpectedError`.
- Name tests after the behaviour: `FullWindowRejectsNextOrder`, not `TestCapacity1`.
- No `Commit()` in tests.
