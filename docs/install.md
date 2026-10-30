# Install and update Fuel Ledger

Fuel Ledger is distributed as a signed APK on [GitHub Releases](https://github.com/FrancescoCastaldi/fuel-ledger-android/releases) and from the [download page](https://francescocastaldi.github.io/fuel-ledger-android/), whose button always points at the latest one. It is not on Google Play. [Obtainium](https://github.com/ImranR98/Obtainium) can watch the releases and install updates for you.

## Signing certificate

Every release is signed with the same personal key. Android refuses an update signed with a different key, so this fingerprint identifies genuine builds:

```text
SHA-256: 2A:4B:94:09:10:7C:2C:D2:06:1D:BF:82:A1:9C:16:9C:2C:6B:2F:AE:38:68:76:FD:56:91:FC:FC:0F:86:1D:69
```

To check a downloaded APK on a computer with the Android build tools:

```powershell
apksigner verify --print-certs FuelLedger-vX.Y.Z.apk
```

## Coming from a local or debug build

Builds made before 0.3.0 was published, including `DiarioAuto` and the local 0.2.0 APK, were signed with a development key. Android cannot update them to a release build.

1. In Fuel Ledger, open **Settings** and export a CSV backup to a folder you can reach.
2. Uninstall the old app.
3. Install the release APK, then import the CSV from **Settings**.

The Italian `DiarioAuto` prototype uses a different CSV format and cannot be imported.

## Update from the app

From 0.5.0 on, **Settings > Updates > Check for updates** asks GitHub for the latest release. If it is newer than the installed version the row becomes **Update app**. Tapping it downloads the APK inside the app with a progress bar, checks it against the published SHA-256 and the signing key, and opens Android's installer over the current app. Your records are kept, because the signing key is the same. Besides the optional [cloud sync](cloud-sync.md), these are the only network requests the app makes, and they happen only when you tap the row.

From 0.8.0 on, the first update needs two things from you, once: allowing installs from Fuel Ledger when Android asks (the app opens that settings page and continues by itself when you come back), and tapping **Update** in Android's own dialog. Versions before 0.8.0 do not have this, so **0.8.0 itself is installed by hand**: download `FuelLedger-v0.8.0.apk` from the release page, as described above. If the in-app download or the installer fails, **Download from the browser instead** is offered as a fallback.

## Install with Obtainium

1. Install Obtainium from its [GitHub releases](https://github.com/ImranR98/Obtainium/releases) or from F-Droid.
2. In Obtainium, tap **Add app** and enter `https://github.com/FrancescoCastaldi/fuel-ledger-android`. The repository is public, so no token is needed.
3. Leave pre-releases off. Obtainium reads the version from the release tag (`vX.Y.Z`) and downloads `FuelLedger-vX.Y.Z.apk`.
4. Tap **Install**. Android asks once to allow installs from Obtainium.

Obtainium then checks for new releases in the background and notifies you when one is available.

## Install by hand

Download `FuelLedger-vX.Y.Z.apk` from the release page on the phone, open it and allow installs from your browser or file manager when Android asks. Later versions install over it without losing data.

## Publishing a release (maintainer)

1. Update `versionCode`, `versionName`, `VERSION` in `build_apk.bat` and `CHANGELOG.md`, and write `docs/releases/vX.Y.Z.md`.
2. Run `build_apk.bat`. The APK is written to `dist/FuelLedger-vX.Y.Z.apk` and older APKs in `dist/` are deleted, so the folder always holds the latest build only. The script then verifies the APK and ends with `RESULT: PASS` (detail in `build_apk.log`). It takes the signing password from a `storePassword=` line in the local `keystore.properties`, else from `FUEL_LEDGER_KEY_PASSWORD` in the private workspace `.env`, else asks for it with hidden input. `keystore.properties` is ignored by Git and must never be committed.
3. Commit, tag `vX.Y.Z`, push the branch and the tag.
4. Create the release with the APK attached:

```powershell
gh release create vX.Y.Z dist/FuelLedger-vX.Y.Z.apk --title "Fuel Ledger X.Y.Z" --notes-file docs/releases/vX.Y.Z.md
```

The download page (`docs/index.html`, served by GitHub Pages) always links to the APK of the newest release, so it needs no edit. Attach exactly one `.apk` per release.

Never lose the keystore or its password: without them, installed apps cannot be updated.
