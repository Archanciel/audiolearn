$sourcePath = 'C:\development\flutter\audiolearn\test\data\audio\Sauvegarde'
$destPath = '/storage/emulated/0/Documents/test/audiolearn'

Write-Host 'Cleaning target directory...'
adb shell "rm -rf $destPath/*"
adb shell "mkdir -p $destPath"

Write-Host 'Copying files and directories...'

$files = Get-ChildItem -Path $sourcePath -Recurse -File

foreach ($file in $files) {
    # Get relative path from source
    $relativePath = $file.FullName.Substring($sourcePath.Length + 1)
    
    # Convert to Unix path
    $unixRelativePath = $relativePath.Replace('\', '/')
    
    # Get directory part for creating on Android
    $unixDir = Split-Path $unixRelativePath -Parent
    if ($unixDir) {
        $androidDirPath = "$destPath/$unixDir"
        Write-Host "Creating directory: $androidDirPath"
        adb shell "mkdir -p '$androidDirPath'"
    }
    
    # Push the file
    $androidFilePath = "$destPath/$unixRelativePath"
    Write-Host "Pushing: $relativePath"
    Write-Host "     to: $androidFilePath"
    adb push $file.FullName $androidFilePath
    Write-Host ''
}

Write-Host 'Setup completed!' -ForegroundColor Green