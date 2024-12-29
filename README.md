# Turbo Notes

A mobile checklist app for Android that allows users to manage multiple
checklists with ease.

## Install dependencies

```sh
npm install
```

## Lint files

```sh
npm run lint
```

## Format files

```sh
npm run format
```

## Env file

Create a ".env.local.json" file in the top-level project directory.

```json
{
  "RELEASE_KEYSTORE_PATH": "<path to *.keystore file>",
  "ANDROID_APK_SIGNER_PATH": "<path to apksigner.bat file>",
  "ANDROID_AAPT_PATH": "<path to aapt.exe file>",
  "ONEDRIVE_PATH": "<path to output directory>"
}
```
