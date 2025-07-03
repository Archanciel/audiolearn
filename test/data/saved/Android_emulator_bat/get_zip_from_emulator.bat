@echo off
chcp 65001 >nul
echo Finding zip files...
for /f "delims=" %%i in ('adb shell "find /storage/emulated/0/Documents/test/audiolearn -name '*.zip' -type f"') do (
    echo Pulling: %%i
    adb pull "%%i" "C:\development\flutter\audiolearn\test\data\audio"
)