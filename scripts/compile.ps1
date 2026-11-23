# Compiles /app, then /test. Pass "app" or "test" to compile just one.
# Prints one line per error or warning, then one summary line.
# Exit 0 = clean. Exit 1 = errors or warnings. Exit 2 = could not run.
param([ValidateSet('app', 'test')] [string[]] $Project = @('app', 'test'))

. "$PSScriptRoot\_common.ps1"
Import-BcHelper

$compilerFolder = Get-CompilerFolder
if (-not (Test-Path $compilerFolder)) {
    Write-Output 'No compiler folder. Run scripts/container-up.ps1 first.'
    exit 2
}

$timer = [Diagnostics.Stopwatch]::StartNew()
$diagnostics = @()

foreach ($name in $Project) {
    $folder = Join-Path $RepoRoot $name
    $script:lines = @()
    try {
        $appFile = Compile-AppWithBcCompilerFolder `
            -compilerFolder $compilerFolder `
            -appProjectFolder $folder `
            -appOutputFolder $OutputFolder `
            -appSymbolsFolder (Join-Path $folder '.alpackages') `
            -EnableCodeCop -EnableUICop -EnablePerTenantExtensionCop `
            -outputTo { param($line) $script:lines += "$line" } 6> $null 3> $null
        # The test app compiles against the app we just built.
        if ($name -eq 'app') {
            $testSymbols = New-Item (Join-Path $RepoRoot 'test\.alpackages') -ItemType Directory -Force
            Copy-Item $appFile $testSymbols -Force
        }
    }
    catch {
        if ("$_" -notlike 'App generation failed*') { $script:lines += "${name}: error: $_" }
    }

    # alc prints "C:\full\path\File.al(12,5): error AL0118: message". Keep those lines only.
    $found = @($script:lines | Where-Object { $_ -match ': (error|warning) ' } |
            ForEach-Object { $_.Replace("$RepoRoot\", '') })
    $diagnostics += $found
    if ($found -match ': error ') { break }   # /test can't compile against a broken /app
}

$diagnostics
$errors = @($diagnostics -match ': error ').Count
$warnings = @($diagnostics -match ': warning ').Count
$seconds = [int]$timer.Elapsed.TotalSeconds
if ($diagnostics) {
    Write-Output "Compile FAILED: $errors errors, $warnings warnings ($($Project -join ', '), ${seconds}s)"
    exit 1
}
Write-Output "Compile OK: $($Project -join ', ') (${seconds}s)"
