param (
    [string]$SourcePath = "C:\development\flutter\audiolearn\test\data\saved\restore_zip_existing_playlist_selected_test_android",
    [string]$DestPath = "/storage/emulated/0/Documents/test/audiolearn",
    [string]$BaseDir = "restore_zip_existing_playlist_selected_test_android"
)

# Delete and recreate target directories to ensure clean state
Write-Host "Preparing target directories..."
adb shell "rm -rf $DestPath/*"
adb shell "mkdir -p $DestPath"

# Process all files recursively
Write-Host "Copying files to device..."
Get-ChildItem -Path $SourcePath -Recurse -File | ForEach-Object {
    $relativePath = ($_.FullName.Substring($_.FullName.IndexOf($BaseDir) + $BaseDir.Length + 1)).Replace("\", "/")
    $parentDir = Split-Path -Parent $relativePath
    
    # Create parent directory if needed
    if ($parentDir) {
        adb shell "mkdir -p '$DestPath/$parentDir'"
    }
    
    # Push file to device
    Write-Host "Pushing $($_.Name)"
    adb push $_.FullName "$DestPath/$relativePath"
}

Write-Host "Copy completed successfully."