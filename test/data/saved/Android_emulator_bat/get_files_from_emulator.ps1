$sourceBase = '/storage/emulated/0/Documents/test/audiolearn'
$destBase = 'C:\development\flutter\audiolearn\test\data\audio'

Write-Host 'Finding files...'

# Get the list of files from the emulator
$files = & adb shell "find /storage/emulated/0/Documents/test/audiolearn -name '*.*' -type f"

foreach ($file in $files) {
    if ([string]::IsNullOrWhiteSpace($file)) { continue }
    
    $file = $file.Trim()
    Write-Host "Processing: $file"
    
    # Extract relative path
    $relPath = $file.Replace($sourceBase, '').TrimStart('/')
    $relPath = $relPath.Replace('/', '\')
    
    # Create destination directory
    $destPath = Join-Path $destBase $relPath
    $destDir = Split-Path $destPath -Parent
    
    if (!(Test-Path $destDir)) {
        Write-Host "Creating directory: $destDir"
        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
    }
    
    # Pull the file
    Write-Host "Pulling: $file"
    Write-Host "     to: $destPath"
    & adb pull $file $destPath
    Write-Host ''
}

Write-Host 'Done!' -ForegroundColor Green