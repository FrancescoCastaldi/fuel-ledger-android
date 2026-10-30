# AGENTS.md: Fuel Ledger (Android)

## Working rules

1. Keep source, comments and documentation in English, UTF-8 without BOM. Interface text is a string resource: English in `values/` (the default) and Italian in `values-it/`. Never put a user-visible literal in Kotlin; `StringResourcesTest` fails when the two files differ in keys or placeholders. Use `UiText` where there is no composable context (view models, widget, notifications).
2. Increment `versionName` (SemVer) and `versionCode` for a release. Synchronize `VERSION` in `build_apk.bat` and update `CHANGELOG.md`.
3. Run `.\gradlew.bat testDebugUnitTest` before delivery. After visual changes, review `app/build/screenshots/` and refresh the committed screenshots and demo if needed.
4. Do not commit, tag or push without explicit conversation authorization.
5. Use `DashTheme.colors` and the typography tokens in `ui/theme`. Keep one amber accent, tabular numbers and no gradients. Take animation timing and easing from `ui/Motion.kt`; loops must check `rememberMotionEnabled()` so they stop when the user turns system animations off.
6. Keep data offline by default. There are two network paths, both started by a tap in Settings and never in the background: the update (`update/`: reads the latest release through `update/GitHubReleases.kt` and, when the user taps Update app, downloads that release's APK from GitHub and hands it to the system installer; it sends nothing about the user) and the optional sync with the user's own Supabase project (`sync/`, inert unless `supabase.properties` is present at build time and the user signs in). Do not add other network access, analytics, third-party cloud services or automatic cloud backup. Never put the Supabase `service_role` key or `supabase.properties` in the repository. CSV files must be chosen by the user.
7. Never commit signing keys, passwords, `local.properties`, database files or APKs. Release APKs live in `dist/` and only the latest versioned one is kept: `build_apk.bat` deletes older builds from `dist/` after a successful build. Never leave APKs in the repository root.
8. Never overwrite unrelated user changes. Follow the parent workspace instructions when available.

## Toolchain

Use JDK 17 or 21 and Android SDK 34. The wrapper uses Gradle 8.7.

In the original local workspace, the portable JDK is at `03_Sviluppo_Software/Tool_e_Config/tools/jdk-21/jdk-21` and the SDK is at `Tool_e_Config/tools/android-sdk`. Prefer `JAVA_HOME`, `ANDROID_HOME` or an ignored `local.properties` over machine-specific paths in committed files.

Source files under `app/`, `tools/` and the Gradle build scripts are encrypted on GitHub with transcrypt (see README, "Encrypted source"). Before committing in a new clone, check `git config --get transcrypt.cipher` returns `aes-256-cbc`; the `crypt` filter is required, so commits fail instead of leaking plain text when it is missing. Never print or commit the password.

See [codemap.md](codemap.md) for entry points and responsibilities.
