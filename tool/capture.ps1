param([ValidatePattern('^emulator-\d+$')][string]$Device = 'emulator-5554')

$ErrorActionPreference = 'Stop'
$project = Split-Path $PSScriptRoot -Parent
$sdkLine = Get-Content -LiteralPath (Join-Path $project 'android/local.properties') |
    Where-Object { $_.StartsWith('sdk.dir=') } | Select-Object -First 1
$adb = Join-Path ($sdkLine.Substring(8).Replace('\\', '\').Replace('\:', ':')) 'platform-tools/adb.exe'
if ((& $adb -s $Device get-state) -ne 'device') { throw "ADB device unavailable: $Device" }

$priorSize = [regex]::Match((& $adb -s $Device shell wm size | Out-String), 'Override size:\s*(\d+x\d+)').Groups[1].Value
$priorDensity = [regex]::Match((& $adb -s $Device shell wm density | Out-String), 'Override density:\s*(\d+)').Groups[1].Value
Push-Location $project
try {
    & $adb -s $Device shell wm size 780x1688
    if ($LASTEXITCODE -ne 0) { throw 'Could not set capture viewport size.' }
    & $adb -s $Device shell wm density 320
    if ($LASTEXITCODE -ne 0) { throw 'Could not set capture viewport density.' }
    flutter drive -d $Device --driver=test_driver/screens_driver.dart --target=integration_test/screens_test.dart
    if ($LASTEXITCODE -ne 0) { throw 'Flutter screenshot run failed.' }
} finally {
    & $adb -s $Device shell wm size $(if ($priorSize) { $priorSize } else { 'reset' })
    & $adb -s $Device shell wm density $(if ($priorDensity) { $priorDensity } else { 'reset' })
    Pop-Location
}
