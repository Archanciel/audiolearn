# run_integration_test.ps1
param(
    [string]$TestName = "restore_zip"
)

# Define paths
$batchDir = "C:\development\flutter\audiolearn\test\data\saved\Android_emulator_bat"
$testDir = "C:\development\flutter\audiolearn\integration_test"

# Map test names to batch files and test files
$testMap = @{
    "restore_zip" = @{
        "batch" = "$batchDir\setup_restore_zip_test.bat"
        "test" = "$testDir\android_emul_restore_integr_test.dart"
    }
    # Add more tests as needed
}

if (-not $testMap.ContainsKey($TestName)) {
    Write-Host "Unknown test: $TestName"
    Write-Host "Available tests: $($testMap.Keys -join ', ')"
    exit 1
}

# Run setup batch file
Write-Host "Running setup batch file: $($testMap[$TestName].batch)"
& $testMap[$TestName].batch

# Run Flutter test
Write-Host "Running Flutter test: $($testMap[$TestName].test)"
flutter test $testMap[$TestName].test -d emulator-5554