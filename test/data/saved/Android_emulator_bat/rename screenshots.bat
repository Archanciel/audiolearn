@echo off
setlocal enabledelayedexpansion

echo ========================================
echo Screenshot Renamer
echo ========================================
echo.
echo This script will rename all Screenshot_*.jpg files
echo to step_01.jpg, step_02.jpg, etc. in chronological order.
echo.

REM Check if there are any Screenshot files
dir /b Screenshot_*.jpg >nul 2>&1
if errorlevel 1 (
    echo ERROR: No Screenshot_*.jpg files found in current directory!
    echo Please run this script in the folder containing the screenshots.
    pause
    exit /b
)

echo Files found:
echo.
dir /b /o:n Screenshot_*.jpg
echo.

REM Ask for confirmation
set /p confirm="Do you want to proceed with renaming? (Y/N): "
if /i not "%confirm%"=="Y" (
    echo Operation cancelled.
    pause
    exit /b
)

echo.
echo Renaming files...
echo.

REM Initialize counter
set counter=1

REM Loop through all Screenshot_*.jpg files sorted by name (which sorts by date/time)
for /f "delims=" %%f in ('dir /b /o:n Screenshot_*.jpg') do (
    REM Pad the counter with leading zero (01, 02, etc.)
    set "padded=0!counter!"
    set "padded=!padded:~-2!"
    
    REM Rename the file
    echo Renaming: %%f  --^>  step_!padded!.jpg
    ren "%%f" "step_!padded!.jpg"
    
    REM Increment counter
    set /a counter+=1
)

echo.
echo ========================================
echo Renaming complete!
echo Total files renamed: !counter! files
echo ========================================
echo.

REM Show the renamed files
echo Renamed files:
dir /b /o:n step_*.jpg

pause