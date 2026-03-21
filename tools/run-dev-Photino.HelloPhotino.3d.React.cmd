@echo off
powershell -ExecutionPolicy Bypass -File "%~dp0run-dev.ps1" -Project "Photino.HelloPhotino.3d.React" -Port 3000 -DevCmd "set BROWSER=none && npm run start"
pause