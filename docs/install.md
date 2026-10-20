# Install and update Fuel Ledger

Fuel Ledger is distributed as a signed APK on [GitHub Releases](https://github.com/FrancescoCastaldi/fuel-ledger-android/releases). It is not on Google Play. [Obtainium](https://github.com/ImranR98/Obtainium) can watch the releases and install updates for you.

## Signing certificate

Every release is signed with the same personal key. Android refuses an update signed with a different key, so this fingerprint identifies genuine builds:

```text
SHA-256: 2A:4B:94:09:10:7C:2C:D2:06:1D:BF:82:A1:9C:16:9C:2C:6B:2F:AE:38:68:76:FD:56:91:FC:FC:0F:86:1D:69
```

To check a downloaded APK on a computer with the Android build tools:

```powershell
apksigner verify --print-certs FuelLedger-v0.3.0.apk
```

## Coming from a local or debug build

Builds made before 0.3.0 was published, including `DiarioAuto` and the local 0.2.0 APK, were signed with a development key. Android cannot update them to a release build.

1. In Fuel Ledger, open **Settings** and export a CSV backup to a folder you can reach.
2. Uninstall the old app.
3. Install the release APK, then import the CSV from **Settings**.

The Italian `DiarioAuto` prototype uses a different CSV format and cannot be imported.

## Install with Obtainium

1. Install Obtainium from its [GitHub releases](https://github.com/ImranR98/Obtainium/releases) or from F-Droid.
2. The repository is private, so Obtainium needs read access:
   1. On GitHub, open **Settings > Developer settings > Personal access tokens > Fine-grained tokens** and create a token.
   2. Limit it to `FrancescoCastaldi/fuel-ledger-android`, with **Contents: Read-only** and nothing else. Give it an expiry date you will remember.
   3. In Obtainium, open **Settings**, find the **GitHub** source section and paste the token into the personal access token field.
3. In Obtainium, tap **Add app** and enter `https://github.com/FrancescoCastaldi/fuel-ledger-android`.
4. Leave pre-releases off. Obtainium reads the version from the release tag (`v0.3.0`) and downloads `FuelLedger-v0.3.0.apk`.
5. Tap **Install**. Android asks once to allow installs from Obtainium.

Obtainium then checks for new releases in the background and notifies you when one is available. If the token expires, update checks fail until you paste a new one.

## Install by hand

Download `FuelLedger-vX.Y.Z.apk` from the release page on the phone, open it and allow installs from your browser or file manager when Android asks. Later versions install over it without losing data.

## Publishing a release (maintainer)

1. Update `versionCode`, `versionName`, `VERSION` in `build_apk.bat` and `CHANGELOG.md`, and write `docs/releases/vX.Y.Z.md`.
2. Run `build_apk.bat`. It asks for the signing password stored in KeePass. `keystore.properties` points to the keystore and never contains the password.
3. Commit, tag `vX.Y.Z`, push the branch and the tag.
4. Create the release with the APK attached:

```powershell
gh release create vX.Y.Z FuelLedger-vX.Y.Z.apk --title "Fuel Ledger X.Y.Z" --notes-file docs/releases/vX.Y.Z.md
```

Never lose the keystore or its password: without them, installed apps cannot be updated.
