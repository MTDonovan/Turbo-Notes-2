$envJson = @{}
$envFilePath = ".env.local.json"
if (Test-Path $envFilePath) {
    $envJson = Get-Content -Path $envFilePath -Raw | ConvertFrom-Json
}
else {
    Write-Host "Error: .env.local.json file not found."
    exit
}

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
