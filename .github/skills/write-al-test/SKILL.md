---
name: write-al-test
description: Write or extend an AL test in /test the way this repo does it, with Given/When/Then, the shared library codeunit and Library Assert. Use when adding tests for new or changed behaviour in /app.
---

# Write an AL test

1. State the behaviour in one sentence. It becomes the `[SCENARIO]` line and,
   in PascalCase, the procedure name.
2. Find the test codeunit for that feature area in `test/src`. Create a new
   one only for a new area, with the next free ID from `test/app.json`.
3. Check `JV Library - Deliv. Win.` for the setup you need. If a helper
   is missing, add it there, not in the test codeunit.
4. Write the test from [template.al](template.al).
5. Cover the failure path too: `asserterror`, then `Assert.ExpectedError`
   with a stable fragment of the error label.

## Before you finish

- Every `[GIVEN]` is a library call. Every `[THEN]` has an `Assert`.
- The test would fail if the code under test were removed.
- No `Commit()`, no hard-coded dates. Use `WorkDate()`-relative dates.
