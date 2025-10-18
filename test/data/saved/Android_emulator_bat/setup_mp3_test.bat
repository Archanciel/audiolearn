@echo off
echo ===== Setting up test environment =====

REM Define parameters (modify these for each test)
set SOURCE_PATH=C:\development\flutter\audiolearn\test\data\saved\restoring_audio_mp3_selecting_zip_or_dir
set DEST_PATH=/storage/emulated/0/Documents/test/audiolearn
set DEST_PATH=/storage/emulated/0/Documents/test/audiolearn
set SAVE_PATH=/storage/emulated/0/Download/Mp3ZipFiles
set BASE_DIR=restoring_audio_mp3_selecting_zip_or_dir

echo Cleaning target directory...
adb shell "rm -rf %DEST_PATH%/*"
adb shell "mkdir -p %DEST_PATH%"

echo Cleaning mp3 save directory...
adb shell "rm -rf %SAVE_PATH%/*"
adb shell "mkdir -p %SAVE_PATH%"

echo Copying files...
powershell -ExecutionPolicy Bypass -Command "Get-ChildItem -Path '%SOURCE_PATH%' -Recurse -File | ForEach-Object { $relativePath = ($_.FullName.Substring($_.FullName.IndexOf('%BASE_DIR%') + '%BASE_DIR%'.Length + 1)).Replace('\', '/'); $parentDir = Split-Path -Parent $relativePath; if ($parentDir) { adb shell \"mkdir -p '%DEST_PATH%/$parentDir'\" }; Write-Host \"Pushing $($_.Name)\"; adb push $_.FullName \"%DEST_PATH%/$relativePath\" }"

echo ===== Setup completed =====