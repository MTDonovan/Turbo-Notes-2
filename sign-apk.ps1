$envJson = @{}
$envFilePath = ".env.local.json"
if (Test-Path $envFilePath) {
    $envJson = Get-Content -Path $envFilePath -Raw | ConvertFrom-Json
}
else {
    Write-Host "Error: .env.local.json file not found."
    exit
}

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
