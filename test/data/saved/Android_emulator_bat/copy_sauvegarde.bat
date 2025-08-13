@echo off
setlocal enabledelayedexpansion
echo ===== Setting up test environment =====

REM Define parameters (modify these for each test)
set "SOURCE_PATH=C:\development\flutter\audiolearn\test\data\audio\Sauvegarde"
set "DEST_PATH=/storage/emulated/0/Documents/test/audiolearn"

echo Cleaning target directory...
adb shell "rm -rf %DEST_PATH%/*"
adb shell "mkdir -p %DEST_PATH%"

echo Copying files and directories...

REM Use robocopy to get all files recursively, then process each one
for /f "delims=" %%i in ('dir "%SOURCE_PATH%" /s /b /a-d') do (
    set "full_path=%%i"
    
    REM Extract the relative path by removing the source base path
    set "rel_path=!full_path:%SOURCE_PATH%=!"
    
    REM Remove leading backslash if present
    if "!rel_path:~0,1!"=="\" set "rel_path=!rel_path:~1!"
    
    REM Convert backslashes to forward slashes for Android
    set "android_rel_path=!rel_path:\=/!"
    
    REM Get the directory part for creating folders on Android
    for %%d in ("!android_rel_path!") do set "android_dir=%%~dpd"
    set "android_dir=!android_dir:\=/!"
    if "!android_dir:~-1!"=="/" set "android_dir=!android_dir:~0,-1!"
    
    REM Create the destination directory structure on Android if needed
    if not "!android_dir!"=="" (
        echo Creating directory: %DEST_PATH%/!android_dir!
        adb shell "mkdir -p '%DEST_PATH%/!android_dir!'"
    )
    
    REM Push the file to the correct location
    echo Pushing: !rel_path!
    echo     to: %DEST_PATH%/!android_rel_path!
    adb push "%%i" "%DEST_PATH%/!android_rel_path!"
    echo.
)

echo ===== Setup completed =====
pause@echo off
setlocal enabledelayedexpansion
echo ===== Setting up test environment =====

REM Define parameters (modify these for each test)
set "SOURCE_PATH=C:\development\flutter\audiolearn\test\data\audio\Sauvegarde"
set "DEST_PATH=/storage/emulated/0/Documents/test/audiolearn"

echo Cleaning target directory...
adb shell "rm -rf %DEST_PATH%/*"
adb shell "mkdir -p %DEST_PATH%"

echo Copying files and directories...

REM Use robocopy to get all files recursively, then process each one
for /f "delims=" %%i in ('dir "%SOURCE_PATH%" /s /b /a-d') do (
    set "full_path=%%i"
    
    REM Extract the relative path by removing the source base path
    set "rel_path=!full_path:%SOURCE_PATH%=!"
    
    REM Remove leading backslash if present
    if "!rel_path:~0,1!"=="\" set "rel_path=!rel_path:~1!"
    
    REM Convert backslashes to forward slashes for Android
    set "android_rel_path=!rel_path:\=/!"
    
    REM Get the directory part for creating folders on Android
    for %%d in ("!android_rel_path!") do set "android_dir=%%~dpd"
    set "android_dir=!android_dir:\=/!"
    if "!android_dir:~-1!"=="/" set "android_dir=!android_dir:~0,-1!"
    
    REM Create the destination directory structure on Android if needed
    if not "!android_dir!"=="" (
        echo Creating directory: %DEST_PATH%/!android_dir!
        adb shell "mkdir -p '%DEST_PATH%/!android_dir!'"
    )
    
    REM Push the file to the correct location
    echo Pushing: !rel_path!
    echo     to: %DEST_PATH%/!android_rel_path!
    adb push "%%i" "%DEST_PATH%/!android_rel_path!"
    echo.
)

echo ===== Setup completed =====
pause