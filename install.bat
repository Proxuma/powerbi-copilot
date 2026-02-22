@echo off
title Proxuma Power BI Copilot — Installer
echo.
echo   Starting installer...
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1"
echo.
pause
