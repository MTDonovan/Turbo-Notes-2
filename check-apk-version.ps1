$OriginalPath = Get-Location

$envJson = @{}
$envFilePath = Join-Path $OriginalPath ".env.local.json"
if (Test-Path $envFilePath) {
  $envJson = Get-Content -Path $envFilePath -Raw | ConvertFrom-Json
}
else {
  Write-Host "Error: .env.local.json file not found."
  exit
}

Invoke-Expression "$($envJson.ANDROID_AAPT_PATH) dump badging ./dist/capacitor/android/apk/release/app-release-unsigned.apk"