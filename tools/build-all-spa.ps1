# tools/build-all-spa.ps1
# Build all SPA samples (production): npm ci -> npm run build
# Usage:
#   pwsh -ExecutionPolicy Bypass -File .\tools\build-all-spa.ps1
#   pwsh -ExecutionPolicy Bypass -File .\tools\build-all-spa.ps1 -Restore install
#   pwsh -ExecutionPolicy Bypass -File .\tools\build-all-spa.ps1 -Clean

param(
    [ValidateSet('ci','install')]
    [string]$Restore = 'ci',
    [switch]$Clean
)

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path

# List your SPA projects here
$projects = @(
    'Photino.HelloPhotino.React',
    'Photino.HelloPhotino.Vue',
    'Photino.HelloPhotino.Angular',
    'Photino.HelloPhotino.3d.React'
)

function Stop-UiProcesses([string]$uiPath) {
    # Best-effort kill of common dev toolchains that may lock files in UI dir
    $names = 'node','npm','vite','next','ng'
    foreach ($n in $names) {
        try { Get-Process -Name $n -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue } catch {}
    }
    Start-Sleep -Milliseconds 200
}

function Clear-ReadOnly([string]$dir) {
    if (Test-Path $dir) {
        Get-ChildItem -LiteralPath $dir -Recurse -Force -ErrorAction SilentlyContinue |
            ForEach-Object {
                try {
                    if ($_.Attributes -band [IO.FileAttributes]::ReadOnly) {
                        $_.Attributes = ($_.Attributes -bxor [IO.FileAttributes]::ReadOnly)
                    }
                } catch {}
            }
    }
}

function Remove-Dir([string]$path) {
    if (Test-Path $path) {
        try {
            Clear-ReadOnly $path
            Remove-Item -LiteralPath $path -Recurse -Force -ErrorAction Stop
        }
        catch {
            # Fallback to cmd rmdir
            try {
                & cmd /c "rmdir /s /q ""$path""" | Out-Null
            } catch {}
        }
    }
}

$results = @()
foreach ($proj in $projects) {
    $ui = Join-Path $repoRoot "$proj\UserInterface"
    $pkgJson = Join-Path $ui 'package.json'

    if (!(Test-Path $pkgJson)) {
        $results += [pscustomobject]@{ Project = $proj; Status = 'Skipped'; Reason = 'No package.json' }
        continue
    }

    Write-Host "==> $proj" -ForegroundColor Cyan
    Push-Location $ui
    try {
        if ($Clean) {
            Write-Host "   Clean: stop dev servers & remove node_modules/, dist/build" -ForegroundColor DarkGray
            Stop-UiProcesses $ui
            Remove-Dir (Join-Path $ui 'node_modules')
            Remove-Dir (Join-Path $ui 'dist')
            Remove-Dir (Join-Path $ui 'build')
        }

        Write-Host "   npm $Restore" -ForegroundColor DarkGray
        npm $Restore

        Write-Host "   npm run build" -ForegroundColor DarkGray
        npm run build

        $results += [pscustomobject]@{ Project = $proj; Status = 'Built'; Reason = '' }
    }
    catch {
        $msg = $_.Exception.Message
        $results += [pscustomobject]@{ Project = $proj; Status = 'Failed'; Reason = $msg }
        Write-Host "   ERROR: $msg" -ForegroundColor Red
    }
    finally {
        Pop-Location
    }
}

Write-Host ""
Write-Host "Summary:" -ForegroundColor Yellow
$results | ForEach-Object {
    $line = "{0,-30}  {1,-7} {2}" -f $_.Project, $_.Status, $_.Reason
    switch ($_.Status) {
        'Built'   { Write-Host $line -ForegroundColor Green }
        'Skipped' { Write-Host $line -ForegroundColor DarkYellow }
        'Failed'  { Write-Host $line -ForegroundColor Red }
        default   { Write-Host $line }
    }
}

if ($results.Where({ $_.Status -eq 'Failed' }).Count -gt 0) {
    exit 1
}