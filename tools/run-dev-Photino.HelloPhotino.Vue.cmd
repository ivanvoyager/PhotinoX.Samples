@echo off
powershell -ExecutionPolicy Bypass -File "%~dp0run-dev.ps1" -Project "Photino.HelloPhotino.Vue" -Port 5173
pause