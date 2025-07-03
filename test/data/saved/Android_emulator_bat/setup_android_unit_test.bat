@echo off
echo ===== Setting up test environment =====
REM Define parameters (modify these for each test)
set SOURCE_PATH=C:\development\flutter\audiolearn\test\data\saved\audio_comment_test
set DEST_PATH=/storage/emulated/0/Documents/test/audiolearn/playlists
set BASE_DIR=audio_comment_test

echo Cleaning target directory...
adb shell "rm -rf %DEST_PATH%/*"
adb shell "mkdir -p %DEST_PATH%"

echo Copying files...
powershell -ExecutionPolicy Bypass -Command "Get-ChildItem -Path '%SOURCE_PATH%' -Recurse -File | ForEach-Object { $baseIndex = $_.FullName.IndexOf('%BASE_DIR%'); if ($baseIndex -ge 0) { $relativePath = $_.FullName.Substring($baseIndex + '%BASE_DIR%'.Length + 1); $relativePath = $relativePath -replace '\\', '/'; $parentDir = Split-Path -Parent $relativePath; if ($parentDir) { $unixParentDir = $parentDir -replace '\\', '/'; adb shell \"mkdir -p '%DEST_PATH%/$unixParentDir'\" }; Write-Host \"Pushing $($_.Name) to $relativePath\"; adb push \"$($_.FullName)\" \"%DEST_PATH%/$relativePath\" } }"

echo ===== Setup completed =====