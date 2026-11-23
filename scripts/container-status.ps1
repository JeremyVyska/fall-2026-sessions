# Prints one line: the container and its state. Exit 0 only when it is healthy.
. "$PSScriptRoot\_common.ps1"

$state = Get-ContainerState
Write-Output "${ContainerName}: $state"
if ($state -ne 'healthy') { exit 1 }
