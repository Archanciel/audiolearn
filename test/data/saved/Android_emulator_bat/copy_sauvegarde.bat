@echo off
echo ===== Setting up test environment =====
powershell.exe -ExecutionPolicy Bypass -File "%~dp0copy_sauvegarde.ps1"
pause