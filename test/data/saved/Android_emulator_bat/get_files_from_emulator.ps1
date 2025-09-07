# Set UTF-8 encoding for proper character handling
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$sourceBase = '/storage/emulated/0/Documents/test'
$destBase = 'C:\development\flutter\audiolearn\test\data\audio'

Write-Host 'Finding files...' -ForegroundColor Cyan

# Get all files directly without pre-checking existence
$allFiles = & adb shell "find /storage/emulated/0/Documents/test -type f" 2>$null

$totalFiles = 0
$successfulFiles = 0
$failedFiles = 0

foreach ($file in $allFiles) {
    if ([string]::IsNullOrWhiteSpace($file)) { 
        continue 
    }
    
    # Clean the file path
    $file = $file.Trim()
    $totalFiles++
    
    Write-Host "Processing [$totalFiles]: $file" -ForegroundColor White
    
    # Extract relative path
    $relPath = $file.Replace($sourceBase, '').TrimStart('/')
    $relPath = $relPath.Replace('/', '\')
    
    # Create destination directory
    $destPath = Join-Path $destBase $relPath
    $destDir = Split-Path $destPath -Parent
    
    if (!(Test-Path $destDir)) {
        Write-Host "  Creating directory: $destDir" -ForegroundColor Yellow
        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
    }
    
    Write-Host "  Pulling to: $destPath" -ForegroundColor Gray
    
    # Direct pull without pre-checking - let adb handle the error if any
    $result = & adb pull "$file" "$destPath" 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  Success!" -ForegroundColor Green
        $successfulFiles++
    } else {
        Write-Host "  Failed: $result" -ForegroundColor Red
        $failedFiles++
        
        # Try with escaped quotes as fallback
        Write-Host "  Trying with escaped quotes..." -ForegroundColor Yellow
        $escapedFile = $file -replace "'", "\'"
        $result2 = & adb pull "$escapedFile" "$destPath" 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  Success with escaping!" -ForegroundColor Green
            $successfulFiles++
            $failedFiles--
        } else {
            Write-Host "  Also failed with escaping: $result2" -ForegroundColor Red
            
            # Show what's actually in the directory
            $directory = Split-Path $file -Parent
            Write-Host "  Directory contents:" -ForegroundColor Magenta
            $dirContents = & adb shell "ls -la '$directory'" 2>$null
            foreach ($item in $dirContents) {
                Write-Host "    $item" -ForegroundColor Magenta
            }
        }
    }
    
    Write-Host ""
}

Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "Summary:" -ForegroundColor Cyan
Write-Host "  Total files found: $totalFiles" -ForegroundColor White
Write-Host "  Successfully copied: $successfulFiles" -ForegroundColor Green
Write-Host "  Failed to copy: $failedFiles" -ForegroundColor Red
Write-Host "===============================================" -ForegroundColor Cyan

if ($failedFiles -eq 0) {
    Write-Host "All files copied successfully!" -ForegroundColor Green
} else {
    Write-Host "Some files failed to copy. Check the output above for details." -ForegroundColor Yellow
}