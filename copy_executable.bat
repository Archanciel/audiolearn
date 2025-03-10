@echo off
:: Check for administrative privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    REM Requesting administrative privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: Define variables
set "PROJECT_DIR=%~dp0"
set "SOURCE_DIR=%PROJECT_DIR%build\windows\x64\runner\Release"
set "DEST_DIR=C:\Program Files\audiolearn"

:: Navigate to the project directory
cd /d "%PROJECT_DIR%"

:: Ensure destination directory exists
if not exist "%DEST_DIR%" (
    echo Creating destination directory: %DEST_DIR%
    mkdir "%DEST_DIR%"
)

:: Copy all files and subdirectories
echo Copying files from "%SOURCE_DIR%" to "%DEST_DIR%"...
robocopy "%SOURCE_DIR%" "%DEST_DIR%" /E /COPYALL /R:0 /DCOPY:T
if %errorlevel% lss 8 (
    echo Files copied successfully to %DEST_DIR%.
) else (
    echo Failed to copy files. Please check the paths and try again.
    exit /b 1
)

pause
