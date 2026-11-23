# Class 2: Claude Code for Business Central Developers

Notes for the instructor. What was set up for Class 2, what was assumed,
what was measured, and what is still open.

> Claude Code isn't a smarter chat. It's a loop you design.
> Plan, build, verify. Verify means the AL compiler and the test runner.

## Branches and tags

| Ref | Contents |
|---|---|
| tag `class1-end` | `main` as Class 1 left it |
| branch `class2-start` | `class1-end` + container, compile and test scripts + `demo/task.md` |
| branch `class2-finished` | `class2-start` + the Claude Code setup built live + the demo task done |

## The two commands

| Command | Does | Exit code |
|---|---|---|
| `scripts/compile.ps1` | Compiles `/app`, then `/test`. `app` or `test` compiles one. | 0 clean, 1 errors or warnings, 2 could not run |
| `scripts/test.ps1` | Compiles, publishes both apps, runs the tests. Optional: one test codeunit by name or ID. | 0 all passed, 1 failures, 2 could not run |

Around them:

| Command | Does |
|---|---|
| `scripts/container-up.ps1` | Creates the container, or starts it. Safe to re-run. |
| `scripts/container-status.ps1` | One line: `bcclass: healthy`, `stopped`, `starting`, `unhealthy` or `missing`. |
| `scripts/break-test.ps1` | Plants one realistic bug in `/app`. One test goes red. |
| `scripts/fix-test.ps1` | Removes that bug. |

What the output looks like:

```
> scripts/compile.ps1
app\src\JVDeliveryWindowMgt.Codeunit.al(54,14): error AL0118: The name 'BookedOrderz' does not exist in the current context.
Compile FAILED: 1 errors, 0 warnings (app, test, 4s)

> scripts/test.ps1
Compile OK: app, test (10s)
Tests: 4 passed, 1 failed, 0 skipped (22s)
FAIL JV Delivery Window Tests:MovingOrderOntoFullDateFails
  An error was expected inside an ASSERTERROR statement.
```

Warnings fail the compile on purpose. CodeCop, UICop and
PerTenantExtensionCop are on, so a page field without a ToolTip is red.

## Setup on a new machine

1. Windows with Docker running Windows containers, PowerShell 7, and the
   BcContainerHelper module.
2. Copy `.env.example` to `.env` and set `BC_CONTAINER_PASSWORD`.
3. Run `scripts/container-up.ps1`. Then `scripts/test.ps1`.

If the shell is not elevated, run this once in an elevated PowerShell:
`Check-BcContainerHelperPermissions -Fix`.

### Environment variables

Read from the environment, or from a git-ignored `.env` in the repo root.
The environment wins. No secrets are in the repo.

| Variable | Default | Purpose |
|---|---|---|
| `BC_CONTAINER_PASSWORD` | none, required | Password for the container's admin user |
| `BC_CONTAINER` | `bcclass` | Container name |
| `BC_CONTAINER_USER` | `admin` | Container user |
| `BC_VERSION` | `28.0` | BC version. The latest build of it is used. |
| `BC_COUNTRY` | `w1` | Localization |

## Timings

Measured on the instructor's machine on 2026-11-23, Hyper-V isolation, 6 GB.

| Step | Time |
|---|---|
| Pull the generic image `mcr.microsoft.com/businesscentral:ltsc2025` (once) | 640 s |
| Cold create, image and BC artifacts already on disk | 421 s |
| Create the compiler folder (once per build) | 43 s |
| Warm start from stopped | 59 s |
| `container-up` when already running | 2 s |
| `compile`, both apps | 7 to 10 s (24 s on the first run after create) |
| `compile test` only | 4 to 6 s |
| `test`, full run including compile and publish | about 30 s |
| `test` with one codeunit | about 30 s, the repo has one test codeunit |
| First test run after create, tests only | 71 s |

Cold create with nothing on disk was not measured. Add the image pull and
the artifact download to the 421 s.

## Assumptions and decisions

- **BC 28.0, W1 sandbox.** Chosen to match the major.minor of the
  instructor's existing `bcserver` container. Both `app.json` files already
  said 28.0.0.0, so nothing was changed there.
- **A dedicated container, `bcclass`.** `bcserver` is left alone so the
  class apps can't collide with anything published there.
- **Compile runs on the host, not in the container.** `container-up`
  creates a BcContainerHelper compiler folder (alc.exe plus symbols) for the
  same build as the container. `Compile-AppInBcContainer` needs the repo
  folder mounted into the container, and it is slower. The brief asked for
  compile "in a local BC container"; this is a deviation.
- **Scripts are PowerShell, `.ps1`.** The brief names them without an
  extension.
- **`test.ps1` always compiles and publishes first.** A test run against a
  stale app would be a wrong answer.
- **`-accept_eula` is passed** when the container is created. That accepts
  Microsoft's container EULA on the user's behalf.
- **The container has the test libraries only**
  (`-includeTestToolkit -includeTestLibrariesOnly`), not Microsoft's tests.
- **`break-test` changes one line** in `app/src/JVSalesHeader.TableExt.al`:
  the capacity re-check moves from `Requested Delivery Date` to
  `Promised Delivery Date`. It still compiles. Only
  `MovingOrderOntoFullDateFails` fails. The script's own output doesn't say
  where the bug is, so the agent has to read the test result.
- **`.alpackages` is filled per project** by the compile script, so the
  AL extension in VS Code finds symbols too.

## Things that went wrong, worth knowing before class

- **Stale generic image.** The first create failed with
  `Could not load file or assembly 'System.Runtime, Version=10.0.0.0'`.
  The newest 28.0 build needs .NET 10. The generic image on the machine was
  a year old (tag 1.0.2.85). Pulling the current one (tag 1.0.2.138) fixed
  it. `container-up` now passes `-alwaysPull`.
- **Test client inside the container fails** with BcContainerHelper 6.1.10
  on that newer image (`error SYSLIB0014: 'ServicePointManager' is
  obsolete`). `test.ps1` uses `-connectFromHost` instead, which needs
  PowerShell 7.
- **Docker refused a non-elevated shell** until
  `Check-BcContainerHelperPermissions -Fix` was run.

## Demo task: two options

`demo/task.md` holds option A, written as a request from the dispatch team.

**Option A: minimum lead time (in `demo/task.md`).**
A delivery window gets `Min. Lead Time (Days)`. Booking an order, or moving
its date, fails when the date is closer than that. Touches the table, the
page, the Mgt. codeunit and the table extension, plus the test library and
test codeunit.

Ways it goes red, so verify has something to catch:

- A page field without a ToolTip fails the compile (warning AA0218).
- Using `Today()` instead of `WorkDate()` fails the tests. In CRONUS the
  work date is not today.
- The existing tests book orders for tomorrow. They stay green only if
  zero means no minimum.

**Option B: a blocked window stops release.**
An order that still points at a window that has since been blocked can't be
released. Touches the Mgt. codeunit, the test library and the test
codeunit. Smaller, with fewer ways to fail. Use it if time is short.

## Open items

- `TODO(verify)` BcContainerHelper is 6.1.10 here; the gallery has 6.1.20.
  Not checked whether 6.1.20 fixes the in-container test client. If it
  does, `-connectFromHost` can go.
- `TODO(verify)` The scripts were run in PowerShell 7 only. Windows
  PowerShell 5.1 can't run `test.ps1` because of `-connectFromHost`.
- Placeholder in the brief, `[2 hours]` time-box: taken as written.
- Placeholder in the brief, `[BC-VERSION]`: resolved to 28.0, see above.
