@echo off
echo ===== Setting up test environment =====

REM Default paths (can be overridden by command line arguments)
set "DEFAULT_SOURCE=C:\development\flutter\audiolearn\test\data\audio\Sauvegarde"
set "DEFAULT_DEST=/storage/emulated/0/Documents/test/audiolearn"

REM Use command line arguments if provided, otherwise use defaults
set "SOURCE_PATH=%~1"
set "DEST_PATH=%~2"

if "%SOURCE_PATH%"=="" set "SOURCE_PATH=%DEFAULT_SOURCE%"
if "%DEST_PATH%"=="" set "DEST_PATH=%DEFAULT_DEST%"

echo Source: %SOURCE_PATH%
echo Destination: %DEST_PATH%
echo.

powershell.exe -ExecutionPolicy Bypass -File "%~dp0copy_sauvegarde.ps1" -SourcePath "%SOURCE_PATH%" -DestPath "%DEST_PATH%"
pause