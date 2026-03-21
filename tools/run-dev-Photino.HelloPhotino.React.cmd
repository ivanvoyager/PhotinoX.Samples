@echo off
powershell -ExecutionPolicy Bypass -File "%~dp0run-dev.ps1" -Project "Photino.HelloPhotino.React" -Port 3000
pause