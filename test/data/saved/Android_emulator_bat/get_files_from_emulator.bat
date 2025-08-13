@echo off
echo ===== Getting files from emulator =====
powershell.exe -ExecutionPolicy Bypass -File "%~dp0get_files_from_emulator.ps1"
pause