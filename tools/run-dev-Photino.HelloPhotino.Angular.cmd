@echo off
powershell -ExecutionPolicy Bypass -File "%~dp0run-dev.ps1" -Project "Photino.HelloPhotino.Angular" -Port 4200 -NoBrowser
pause