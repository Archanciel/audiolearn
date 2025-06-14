@echo off
echo ===== Setting up test environment =====
REM Define parameters (modify these for each test)
set SOURCE_PATH=C:\development\flutter\audiolearn\test\data\audio\Sauvegarde
set DEST_PATH=/storage/emulated/0/Documents/test/audiolearn

echo Copying files...
for %%f in ("%SOURCE_PATH%\*.*") do (
    echo Pushing %%~nxf
    adb push "%%f" "%DEST_PATH%/"
)

echo ===== Setup completed =====