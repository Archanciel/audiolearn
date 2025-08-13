@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul
echo Finding files...

set "source_base=/storage/emulated/0/Documents/test/audiolearn"
set "dest_base=C:\development\flutter\audiolearn\test\data\audio"

for /f "delims=" %%i in ('adb shell "find /storage/emulated/0/Documents/test/audiolearn -name '*.*' -type f"') do (
    echo Processing: %%i
    
    REM Extract the relative path by removing the base path
    set "full_path=%%i"
    set "rel_path=!full_path:%source_base%=!"
    
    REM Remove leading slash if present
    if "!rel_path:~0,1!"=="/" set "rel_path=!rel_path:~1!"
    
    REM Convert forward slashes to backslashes for Windows
    set "rel_path=!rel_path:/=\!"
    
    REM Get the directory part for creating folders
    for %%f in ("!dest_base!\!rel_path!") do set "dest_dir=%%~dpf"
    
    REM Create the destination directory structure if it doesn't exist
    if not exist "!dest_dir!" (
        echo Creating directory: !dest_dir!
        mkdir "!dest_dir!" 2>nul
    )
    
    REM Pull the file to the correct location
    echo Pulling: %%i
    echo     to: !dest_base!\!rel_path!
    adb pull "%%i" "!dest_base!\!rel_path!"
    echo.
)

echo Done!
pause