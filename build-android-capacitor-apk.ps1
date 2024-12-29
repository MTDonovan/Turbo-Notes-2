# Example: ./build-capacitor-apk.ps1 -IsDebug $true

[CmdletBinding()]
param (
  [Parameter()]
  [Boolean]
  $IsDebug = $false
)

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

if ($IsDebug) {
  quasar build -m capacitor -T android --debug

  Start-Process `
    -FilePath `
    $envJson.ANDROID_APK_SIGNER_PATH `
    -ArgumentList `
    "sign", `
    "--ks", `
    $envJson.RELEASE_KEYSTORE_PATH, `
    "--ks-key-alias", `
    "my-alias", `
    "./dist/capacitor/android/apk/debug/app-debug.apk" `
    -Wait

  Set-Location ./dist/capacitor/android/apk/debug
  Rename-Item -Path app-debug.apk -NewName app-debug-signed.apk
  # Copy the signed apk to OneDrive
  Copy-Item -Path app-debug-signed.apk -Destination $envJson.ONEDRIVE_PATH
}
else {
  quasar build -m capacitor -T android

  Start-Process `
    -FilePath `
    $envJson.ANDROID_APK_SIGNER_PATH `
    -ArgumentList `
    "sign", `
    "--ks", `
    $envJson.RELEASE_KEYSTORE_PATH, `
    "--ks-key-alias", `
    "my-alias", `
    "./dist/capacitor/android/apk/release/app-release-unsigned.apk" `
    -Wait

  Set-Location ./dist/capacitor/android/apk/release
  Rename-Item -Path app-release-unsigned.apk -NewName app-release-signed.apk
  # Copy the signed apk to OneDrive
  Copy-Item -Path app-release-signed.apk -Destination $envJson.ONEDRIVE_PATH
}

Set-Location $OriginalPath