# Compiles, publishes both apps to the container and runs the tests.
# Optional argument: one test codeunit, by name or ID. Wildcards work.
# Exit 0 = all passed. Exit 1 = failures. Exit 2 = could not run.
param([string] $Codeunit = '*')

. "$PSScriptRoot\_common.ps1"

& "$PSScriptRoot\compile.ps1"
if ($LASTEXITCODE -ne 0) { exit 2 }

if ((Get-ContainerState) -ne 'healthy') {
    Write-Output "Container $ContainerName is not healthy. Run scripts/container-up.ps1 first."
    exit 2
}

Import-BcHelper
$timer = [Diagnostics.Stopwatch]::StartNew()
$credential = Get-BcCredential
$results = Join-Path $bcContainerHelperConfig.hostHelperFolder "Extensions\$ContainerName\test-results.xml"
Remove-Item $results -ErrorAction SilentlyContinue

try {
    foreach ($name in 'app', 'test') {
        $manifest = Get-Content (Join-Path $RepoRoot "$name\app.json") -Raw | ConvertFrom-Json
        $appFile = Join-Path $OutputFolder "$($manifest.publisher)_$($manifest.name)_$($manifest.version).app"
        # ForceSync and Ignore: switching branches can remove a field that the
        # test app already in the container still uses. Fine in a dev container.
        Publish-BcContainerApp -containerName $ContainerName -appFile $appFile `
            -credential $credential -useDevEndpoint -syncMode ForceSync `
            -dependencyPublishingOption Ignore 6> $null 3> $null
    }
    # $manifest is now the test app: run only its tests, not Microsoft's.
    # -connectFromHost needs PowerShell 7. BcContainerHelper 6.1.10's in-container
    # test client fails on the .NET 10 generic image.
    Run-TestsInBcContainer -containerName $ContainerName -credential $credential `
        -extensionId $manifest.id -testCodeunit $Codeunit -connectFromHost `
        -XUnitResultFileName $results 6> $null 3> $null | Out-Null
}
catch {
    Write-Output "Test run could not start: $_"
    exit 2
}

$tests = @()
if (Test-Path $results) { $tests = @(([xml](Get-Content $results -Raw)).SelectNodes('//test')) }
if (-not $tests) {
    Write-Output "No tests ran. Is '$Codeunit' a test codeunit in /test?"
    exit 2
}

$failed = @($tests | Where-Object { $_.result -eq 'Fail' })
$skipped = @($tests | Where-Object { $_.result -eq 'Skip' })
$passed = $tests.Count - $failed.Count - $skipped.Count
Write-Output "Tests: $passed passed, $($failed.Count) failed, $($skipped.Count) skipped ($([int]$timer.Elapsed.TotalSeconds)s)"
foreach ($test in $failed) {
    Write-Output "FAIL $($test.name)"
    # Keep the message; drop the .NET exception type and the stack trace.
    $message = ("$($test.failure.message)" -split '\\\s+at ')[0] -replace '^[\w.]+Exception: ', ''
    Write-Output "  $message"
}
if ($failed) { exit 1 }
