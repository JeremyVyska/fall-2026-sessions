# Creates the BC container, or starts it if it already exists. Safe to re-run.
# Cold create downloads artifacts and takes many minutes. Warm start is quick.
. "$PSScriptRoot\_common.ps1"

$timer = [Diagnostics.Stopwatch]::StartNew()
Import-BcHelper
$state = Get-ContainerState

if ($state -eq 'missing') {
    $credential = Get-BcCredential
    $artifactUrl = Get-BCArtifactUrl -type Sandbox -country $BcCountry -version $BcVersion -select Latest
    if (-not $artifactUrl) { throw "No sandbox artifact found for $BcCountry $BcVersion." }
    Write-Output "Creating $ContainerName from $artifactUrl"
    # -alwaysPull: a stale generic image can't run newer BC builds.
    New-BcContainer `
        -accept_eula `
        -containerName $ContainerName `
        -artifactUrl $artifactUrl `
        -auth UserPassword `
        -Credential $credential `
        -includeTestToolkit `
        -includeTestLibrariesOnly `
        -alwaysPull `
        -memoryLimit 6G
}
elseif ($state -ne 'healthy') {
    # stopped, starting or unhealthy: (re)start and wait for the health check
    Start-BcContainer -containerName $ContainerName 6> $null | Out-Null
}

# Compile runs on the host: alc.exe and symbols for the same build as the container.
if (-not (Test-Path (Get-CompilerFolder))) {
    $artifactUrl = Get-BcContainerArtifactUrl -containerName $ContainerName
    New-BcCompilerFolder -artifactUrl $artifactUrl -containerName $ContainerName | Out-Null
}

$state = Get-ContainerState
Write-Output "${ContainerName}: $state after $([int]$timer.Elapsed.TotalSeconds)s"
if ($state -ne 'healthy') { exit 1 }
