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

quasar build -m capacitor -T android -- bundleRelease

jarsigner `
  -verbose `
  -sigalg `
  SHA256withRSA `
  -digestalg `
  SHA-256 `
  -keystore `
  $envJson.RELEASE_KEYSTORE_PATH `
  "./dist/capacitor/android/bundle/release/app-release.aab" `
  "TurboNotes"

Set-Location ./dist/capacitor/android/bundle/release
Rename-Item -Path app-release.aab -NewName app-release-signed.aab
Copy-Item -Path app-release-signed.aab -Destination $envJson.ONEDRIVE_PATH

Set-Location $OriginalPath