@echo off
setlocal enabledelayedexpansion
REM --------------------------------------------------------------------
REM PhotinoX.Samples: run Photino.HelloPhotino.GRpc in dev mode (CLI).
REM - Restores NuGet packages (once)
REM - Optionally trusts dev HTTPS cert (first run on Windows)
REM - Runs the .NET host from the sample folder
REM
REM Usage:
REM   tools\run-grpc.cmd
REM   tools\run-grpc.cmd Photino.HelloPhotino.GRpc
REM   tools\run-grpc.cmd Photino.HelloPhotino.GRpc -c Release
REM --------------------------------------------------------------------

REM Resolve repo root = parent folder of /tools
set "TOOLS_DIR=%~dp0"
for %%I in ("%TOOLS_DIR%\..") do set "REPO_ROOT=%%~fI"

REM Default project folder
set "PROJECT=Photino.HelloPhotino.GRpc"

REM Optional args:
REM - first arg can override project folder name
if not "%~1"=="" (
  set "PROJECT=%~1"
  shift
)

REM Remaining args are passed to dotnet run (e.g., -c Release)
set "DOTNET_ARGS=%*"
if "%DOTNET_ARGS%"=="" set "DOTNET_ARGS=-c Debug"

REM Full paths
set "PROJ_DIR=%REPO_ROOT%\%PROJECT%"
set "CSPROJ="

REM Locate .csproj (first match)
for /f "delims=" %%F in ('dir /b /a:-d "%PROJ_DIR%\*.csproj" 2^>nul') do (
  set "CSPROJ=%%F"
  goto :foundproj
)

:foundproj
if "%CSPROJ%"=="" (
  echo [ERROR] .csproj not found in: %PROJ_DIR%
  exit /b 1
)

echo Repo root : %REPO_ROOT%
echo Project   : %PROJECT%
echo csproj    : %CSPROJ%
echo.

REM Optional: trust developer HTTPS certificate (Windows dev workflow)
REM Comment out if you do not use HTTPS in this sample.
echo Ensuring dev HTTPS certificate is trusted (one-time)...
dotnet dev-certs https --trust >nul 2>&1

REM Restore once (safe to run repeatedly)
echo Restoring NuGet packages...
dotnet restore "%PROJ_DIR%\%CSPROJ%"
if errorlevel 1 (
  echo [ERROR] restore failed.
  exit /b 1
)

REM Run the app
echo Running .NET host...
pushd "%PROJ_DIR%"
dotnet run %DOTNET_ARGS%
set "RC=%ERRORLEVEL%"
popd

if not "%RC%"=="0" (
  echo [ERROR] dotnet run exited with code %RC%
  exit /b %RC%
)

echo Done.
exit /b 0