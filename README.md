# Delivery Windows: agent setup demo

Demo repo for **"VS Code + GitHub Copilot: The Fall 2026 Refresh"**, Class 1.
See current offerings at [store.jeremyvyska.com](https://store.jeremyvyska.com).

The AL app is small on purpose: sales orders are booked into delivery windows
with a daily capacity. The point of the repo is the agent files around it.

> Your Copilot setup isn't a habit. It's a repo artifact.

## What to look at

| File | Principle it shows |
|---|---|
| [`AGENTS.md`](AGENTS.md) | **One source of truth.** Shared rules live here once. **Stays thin**: layout, conventions and routing, under 60 lines. |
| [`.github/copilot-instructions.md`](.github/copilot-instructions.md) | **Thin pointer.** One line pointing at `AGENTS.md`. |
| [`CLAUDE.md`](CLAUDE.md) | **Thin pointer.** `@AGENTS.md` and nothing else. |
| [`.github/instructions/`](.github/instructions/) | **AGENTS.md stays thin.** Rules for some files only (`test/**`, `**/*.xlf`) load only for those files. |
| [`.github/skills/`](.github/skills/) | **AGENTS.md stays thin.** Repeated work (`write-al-test`, `add-field`) lives in skills that load on demand. |
| [`.github/agents/`](.github/agents/) | **Tools live in custom agents.** `spec` gets read, search and BC Code Atlas. `triage` adds BC Telemetry Buddy. No tool sets. |
| [`.mcp.json`](.mcp.json) | **Only MCP servers that earn their context.** Three servers, each used by a named role or skill. |

### Before and after

The tag `spring-2026` is the old setup. Compare it with `main`:

```
git diff spring-2026 main --stat
git log --oneline spring-2026..main
```

In `spring-2026` you'll find rules duplicated in `copilot-instructions.md`
and `CLAUDE.md` (already drifting apart), a prompt file doing a skill's job,
and a `.vscode/mcp.json` with nine servers. Each later commit fixes one thing.

## How to open it

- **VS Code with GitHub Copilot**: open the repo folder. The Copilot harness
  reads `AGENTS.md`, `.github/instructions`, `.github/skills`,
  `.github/agents` and the root `.mcp.json`.
- **Claude Code**: run `claude` in the repo folder. It reads `CLAUDE.md`, which
  imports `AGENTS.md`, and it uses the same `.mcp.json`. Claude Code doesn't
  auto-load `.github/skills` or `.github/agents`. The routing in `AGENTS.md`
  names the skill paths so it can read them.

Both tools read the same rules from the same file.

### Deviation from the brief

The brief asked for `.vscode/mcp.json`. Current VS Code docs call that format
(`servers`) the deprecated Local harness's, and the Copilot harness doesn't
read it directly. The root `.mcp.json` (`mcpServers`) is the current format
and Claude Code reads it too. `.vscode/mcp.json` now appears only in the
`spring-2026` tag, as the "before".

No prompt file is included. Prompt files run only in the deprecated Local
harness, and the one in `spring-2026` became the `write-al-test` skill.

## Project settings

| Setting | Value |
|---|---|
| Prefix | `JV` |
| ID ranges | 50100-50149 (`/app`), 50150-50199 (`/test`) |
| Publisher | Jeremy Vyska Classes |
| Platform / application | 28.0.0.0 |
| Runtime | 17.0 |

## Verify before class

These are marked `TODO(verify)`. JSON can't hold comments, so they're listed here.

- `TODO(verify)` `bc-telemetry-buddy` in `.mcp.json`: confirm that
  `npx -y bc-telemetry-buddy-mcp` starts the server and that it finds a
  `.bctb-config.json` in the workspace root. That file holds the
  App Insights settings and is git-ignored.
- `TODO(verify)` That VS Code loads an existing root `.mcp.json` without
  turning on `chat.mcp.workspaceRootConfig.enabled`. The docs imply this
  but don't state it.

## Build check

Both apps compile with no errors, warnings or infos against BC 28.5 symbols,
using the AL CLI (`dotnet tool install -g Microsoft.Dynamics.BusinessCentral.Development.Tools`)
with CodeCop, UICop and PerTenantExtensionCop. Tests have not been run against
a BC server.

## Assumptions

- The scenario, object IDs and target languages (da-DK, de-DE) are invented
  for the demo.
- The repo is browsable without compiling. It compiles once symbols are
  downloaded.
- No CI, packaging or BCQuality review here. Those are covered in class.

## License

MIT. See [LICENSE](LICENSE).
