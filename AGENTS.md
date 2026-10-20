# AGENTS.md: Fuel Ledger (Android)

## Working rules

1. Keep all source, interface text, comments and documentation in English, UTF-8 without BOM.
2. Increment `versionName` (SemVer) and `versionCode` for a release. Synchronize `VERSION` in `build_apk.bat` and update `CHANGELOG.md`.
3. Run `.\gradlew.bat testDebugUnitTest` before delivery. After visual changes, review `app/build/screenshots/` and refresh the committed screenshots and demo if needed.
4. Do not commit, tag or push without explicit conversation authorization.
5. Use `DashTheme.colors` and the typography tokens in `ui/theme`. Keep one amber accent, tabular numbers and no gradients.
6. Keep data offline. Do not add network access, analytics, cloud services or automatic cloud backup. CSV files must be chosen by the user.
7. Never commit signing keys, passwords, `local.properties`, database files or APKs. Keep only the latest versioned APK locally.
8. Never overwrite unrelated user changes. Follow the parent workspace instructions when available.

## Toolchain

Use JDK 17 or 21 and Android SDK 34. The wrapper uses Gradle 8.7.

In the original local workspace, the portable JDK is at `03_Sviluppo_Software/Tool_e_Config/tools/jdk-21/jdk-21` and the SDK is at `Tool_e_Config/tools/android-sdk`. Prefer `JAVA_HOME`, `ANDROID_HOME` or an ignored `local.properties` over machine-specific paths in committed files.

See [codemap.md](codemap.md) for entry points and responsibilities.
