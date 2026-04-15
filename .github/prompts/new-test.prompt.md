---
description: Write a new test codeunit for the Delivery Windows app
agent: agent
---

Write a new AL test codeunit in `/test/src` for: ${input:behaviour:What should be tested?}

- Use `// [SCENARIO]`, `// [GIVEN]`, `// [WHEN]`, `// [THEN]` comments.
- Use the `JV Library - Deliv. Win.` codeunit for setup.
- Add helpers to the library codeunit, not the test codeunit.
- Use `Library Assert`.
- Use `asserterror` plus `Assert.ExpectedError` for failures.
- Name each test after the behaviour.
