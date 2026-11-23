@AGENTS.md

This file is only a pointer. Shared rules live in AGENTS.md.

## Claude Code only

- A hook runs `scripts/compile.ps1` after every `.al` edit. Fix what it reports before moving on.
- For a test run, use the `test-runner` subagent. It returns only the failures.
- Claude Code doesn't load `.github/skills` itself. Read the `SKILL.md` that AGENTS.md routes to.
