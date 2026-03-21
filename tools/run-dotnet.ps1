param(
  [Parameter(Mandatory=$true)] [string]$Project,
  [string]$DotnetArgs = "run -c Debug"
)

$ErrorActionPreference = 'Stop'

# repo root = parent of tools/
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$projDir  = Join-Path $repoRoot $Project
$csproj   = Get-ChildItem -Path $projDir -Filter *.csproj | Select-Object -First 1

if (-not $csproj) {
  Write-Host "[ERROR] .csproj not found in: $projDir" -ForegroundColor Red
  exit 1
}

Write-Host "Repo root : $repoRoot"
Write-Host "Project   : $Project"
Write-Host "Proj dir  : $projDir"
Write-Host "csproj    : $($csproj.Name)"
Write-Host ""

Write-Host "Restoring..."
dotnet restore $csproj.FullName
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "Running .NET app..."
Push-Location $projDir
try {
  # Split "run -c Debug" into an array: "run","-c","Debug"
  $dotnetArgsArray = @()
  if ($DotnetArgs) { $dotnetArgsArray = $DotnetArgs -split '\s+' }

  & dotnet @dotnetArgsArray
  $rc = $LASTEXITCODE
}
finally {
  Pop-Location
}

exit $rc
