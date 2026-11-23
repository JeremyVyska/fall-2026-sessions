# Demo helper: plants one realistic bug in /app so one test goes red.
# Undo it with scripts/fix-test.ps1. Pass -Undo to do the same from here.
# The message stays vague on purpose: the agent should find the bug from the test result.
param([switch] $Undo)

. "$PSScriptRoot\_common.ps1"

$file = Join-Path $RepoRoot 'app\src\JVSalesHeader.TableExt.al'
$good = 'modify("Requested Delivery Date")'
$bad = 'modify("Promised Delivery Date")'
if ($Undo) { $from, $to, $done = $bad, $good, 'Fixed: the planted bug is gone.' }
else { $from, $to, $done = $good, $bad, 'Broken: one bug planted in /app. Run scripts/test.ps1 to see it.' }

$text = [IO.File]::ReadAllText($file)
if (-not $text.Contains($from)) {
    Write-Output 'Nothing to change: the app is already in that state.'
    exit 0
}
[IO.File]::WriteAllText($file, $text.Replace($from, $to))
Write-Output $done
