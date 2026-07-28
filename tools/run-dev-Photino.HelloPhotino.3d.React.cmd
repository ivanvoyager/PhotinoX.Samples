@echo off
set "BROWSER=none"
set "DISABLE_ESLINT_PLUGIN=true"
powershell -ExecutionPolicy Bypass -File "%~dp0run-dev.ps1" -Project "Photino.HelloPhotino.3d.React" -Port 3000 -DevCmd "npm run start"
pause