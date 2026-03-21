# tools/run-dev.ps1
param(
    [string]$Project,                  # e.g. "Photino.HelloPhotino.React" (folder with .csproj)
    [string]$UiDir = "UserInterface",  # UI folder name (UserInterface/ClientApp)
    [int]$Port,                        # React/Next=3000, Vue/Vite=5173, Angular=4200 (default)
    [string]$DevCmd = "",              # if empty -> auto-pick by framework; if set -> use as-is
    [string]$DotnetArgs = "run -c Debug",
    [int]$TimeoutSec = 180,
    [switch]$NoBrowser,                # suppress auto-opening browser where applicable
    [switch]$List                      # list detected SPA projects
)

$ErrorActionPreference = 'Stop'

function Info($m){ Write-Host $m -ForegroundColor Cyan }
function Ok  ($m){ Write-Host $m -ForegroundColor Green }
function Warn($m){ Write-Host $m -ForegroundColor DarkYellow }
function Err ($m){ Write-Host $m -ForegroundColor Red }

# Repo root = parent of tools/
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path

# Detect SPA projects if listing requested
function Get-SpaCandidates {
    # Find sample folders that contain "<UiDir>\package.json" and a sibling .csproj
    Get-ChildItem -Path $repoRoot -Directory -Recurse -Depth 2 |
        Where-Object {
            (Test-Path (Join-Path $_.FullName (Join-Path $UiDir 'package.json'))) -and
            (Get-ChildItem -Path $_.FullName -Filter *.csproj -ErrorAction SilentlyContinue)
        } |
        Sort-Object Name
}

if ($List) {
    Write-Host "Detected SPA projects:" -ForegroundColor Yellow
    foreach ($d in Get-SpaCandidates) {
        $rel = $d.FullName.Substring($repoRoot.Length+1)
        Write-Host " - $rel" -ForegroundColor Green
    }
    exit 0
}

if (-not $Project) { Err "Missing -Project. Use -List to see detected projects."; exit 1 }

# Resolve the project by exact name, prefix, or relative path
$candidate = Get-SpaCandidates | Where-Object {
    $_.Name -ieq $Project -or $_.Name -like ($Project + '*') -or
    ($_.FullName.Substring($repoRoot.Length+1)) -ieq $Project -or
    ($_.FullName.Substring($repoRoot.Length+1)) -like ($Project + '*')
} | Select-Object -First 1

if (-not $candidate) { Err "Project not found: $Project"; exit 1 }

$projDir = $candidate.FullName
$uiPath  = Join-Path $projDir $UiDir
$csproj  = (Get-ChildItem -Path $projDir -Filter *.csproj | Select-Object -First 1).FullName

# Default port by framework if not provided
if (-not $Port -or $Port -le 0) {
    if     ($candidate.Name -match 'Angular') { $Port = 4200 }
    elseif ($candidate.Name -match 'Vue')     { $Port = 5173 }
    else                                      { $Port = 3000 }  # React/Next
}

# Auto-pick DevCmd if not provided
if (-not $DevCmd -or $DevCmd.Trim().Length -eq 0) {
    if ($candidate.Name -match 'Angular') {
        $DevCmd = "npm run start"
        if ($NoBrowser) { $DevCmd = "$DevCmd -- --no-open" }
    }
    elseif ($candidate.Name -match 'Vue') {
        # Bind to localhost explicitly; don't add --open
        $DevCmd = "npm run dev -- --host localhost"
        # (Vite does not auto-open unless configured, so NoBrowser is a no-op here)
    }
    else {
        # React/Next: usually 'npm run dev' (Next). CRA often uses 'npm run start' (opens browser).
        # We prefer 'npm run dev' by default; if your sample uses CRA, override via -DevCmd.
        $DevCmd = "npm run dev"
        # NoBrowser usually not needed for Next; CRA users should pass -DevCmd "set BROWSER=none && npm run start"
    }
}

Info ("Repo root : {0}" -f $repoRoot)
Info ("Project   : {0}" -f ($projDir.Substring($repoRoot.Length+1)))
Info ("UI path   : {0}" -f ($uiPath.Substring($repoRoot.Length+1)))
Info ("csproj    : {0}" -f ([System.IO.Path]::GetFileName($csproj)))
Info ("Dev port  : {0}" -f $Port)
Info ("Dev cmd   : {0}" -f $DevCmd)
Write-Host ""

# --- Helpers ---
# Probe both IPv4 and IPv6 loopback via 127.0.0.1 and localhost
function Test-PortUp([int]$p) {
    $urls = @("http://127.0.0.1:$p/","http://localhost:$p/")
    foreach ($u in $urls) {
        try {
            $r = Invoke-WebRequest -Uri $u -UseBasicParsing -TimeoutSec 2
            if ($r.StatusCode -ge 200) { return $true }
        } catch { }
    }
    return $false
}

# If dev server already runs on the port, reuse it; otherwise, start and own it.
$devOwned = $false
if (Test-PortUp $Port) {
    Warn ("Dev server already running on port {0}; reusing it." -f $Port)
} else {
    Push-Location $uiPath
    try {
        # For CRA users: if you need to suppress auto-open, call with:
        #   -DevCmd "set BROWSER=none && npm run start"
        # Use cmd /c to keep a single child process we can kill later
        $devCmdLine = 'cmd /c {0}' -f $DevCmd
        Info "Starting dev server ..."
        $devProc = Start-Process -FilePath "powershell" `
                  -ArgumentList "-NoLogo","-NoProfile","-Command",$devCmdLine `
                  -WorkingDirectory $uiPath -PassThru -WindowStyle Hidden
        $devOwned = $true
    } finally { Pop-Location }

    Info ("Waiting for http://localhost:{0}/ (or 127.0.0.1) ..." -f $Port)
    $deadline = (Get-Date).AddSeconds($TimeoutSec)
    while ((Get-Date) -lt $deadline) {
        if (Test-PortUp $Port) { break }
        Start-Sleep -Milliseconds 300
    }
    if (-not (Test-PortUp $Port)) {
        Err ("Dev server did not start within {0} s." -f $TimeoutSec)
        if ($devOwned -and $devProc -and -not $devProc.HasExited) { try { $devProc.Kill() } catch {} }
        exit 1
    }
    Ok "Dev server is UP."
}

# Start .NET host (window)
Push-Location $projDir
try {
    Info "Starting .NET host ..."
    $dotnetProc = Start-Process -FilePath "dotnet" -ArgumentList $DotnetArgs `
                  -WorkingDirectory $projDir -PassThru
    Ok  "Running. Close the .NET app to stop."
    Wait-Process -Id $dotnetProc.Id
}
finally {
    Pop-Location
    # Kill the dev server only if we started it
    if ($devOwned -and $devProc -and -not $devProc.HasExited) {
        Warn ("Stopping dev server (PID={0}) ..." -f $devProc.Id)
        try { $devProc.Kill() } catch {}
    } else {
        Warn "Dev server was not started by this script; leaving it running."
    }
}
