# PostToolUse hook. After Claude edits an .al file, compile.
# Clean compile: say nothing. Errors or warnings: exit 2, and Claude gets them on stderr.
$payload = [Console]::In.ReadToEnd() | ConvertFrom-Json
$file = "$($payload.tool_input.file_path)"
if ($file -notlike '*.al') { exit 0 }

# A change in /test only needs /test. A change in /app needs both.
$project = if ($file -match '[\\/]test[\\/]') { 'test' } else { 'app', 'test' }

$output = & "$PSScriptRoot\..\..\scripts\compile.ps1" -Project $project
if ($LASTEXITCODE -eq 0) { exit 0 }

[Console]::Error.WriteLine($output -join "`n")
exit 2
