# Shared settings for the scripts in this folder. Dot-source it; don't run it.
# ASCII only: Windows PowerShell 5.1 reads .ps1 files in the OEM code page.
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$RepoRoot = Split-Path $PSScriptRoot -Parent

# Local overrides and the container password live in a git-ignored .env file.
# Real environment variables win over the file.
$envFile = Join-Path $RepoRoot '.env'
if (Test-Path $envFile) {
    foreach ($line in Get-Content $envFile) {
        if ($line -match '^\s*([A-Za-z_]\w*)\s*=\s*(.*)$' -and -not (Test-Path "env:$($Matches[1])")) {
            Set-Item "env:$($Matches[1])" $Matches[2].Trim()
        }
    }
}

function Get-Setting([string] $Name, [string] $Default) {
    $value = [Environment]::GetEnvironmentVariable($Name)
    if ($value) { $value } else { $Default }
}

$ContainerName = Get-Setting 'BC_CONTAINER' 'bcclass'
$BcVersion = Get-Setting 'BC_VERSION' '28.0'
$BcCountry = Get-Setting 'BC_COUNTRY' 'w1'
$BcUser = Get-Setting 'BC_CONTAINER_USER' 'admin'
$OutputFolder = Join-Path $RepoRoot '.output'

function Get-BcCredential {
    if (-not $env:BC_CONTAINER_PASSWORD) {
        throw 'BC_CONTAINER_PASSWORD is not set. Copy .env.example to .env and fill it in.'
    }
    $password = ConvertTo-SecureString $env:BC_CONTAINER_PASSWORD -AsPlainText -Force
    New-Object System.Management.Automation.PSCredential ($BcUser, $password)
}

function Import-BcHelper {
    Import-Module BcContainerHelper -DisableNameChecking *> $null
}

# alc.exe and symbols for the container's BC build, so compile runs on the host.
# Needs Import-BcHelper first.
function Get-CompilerFolder {
    Join-Path $bcContainerHelperConfig.hostHelperFolder "compiler\$ContainerName"
}

# One word for the container: missing, stopped, starting, unhealthy or healthy.
function Get-ContainerState {
    $state = docker inspect $ContainerName --format '{{.State.Status}}/{{if .State.Health}}{{.State.Health.Status}}{{end}}' 2>$null
    if ($LASTEXITCODE -ne 0) { return 'missing' }
    $status, $health = "$state".Split('/')
    if ($status -ne 'running') { return 'stopped' }
    if ($health) { $health } else { 'healthy' }
}
