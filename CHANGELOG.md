# Changelog

All notable changes to this project are documented here.

The format follows [Keep a Changelog 1.1.0](https://keepachangelog.com/en/1.1.0/) and this project uses [Semantic Versioning](https://semver.org/).

## [Unreleased]

## [0.6.0] - 2026-10-21

### Added

- Optional cloud sync with your own Supabase project. Sign in with Google in the browser (code flow with a proof key, no Google Play Services) and tap **Migrate and sync**: vehicles, fill-ups, expenses and reminders are merged both ways, the newest change wins and deletions propagate. Nothing syncs in the background. The tables and their row level security are in `docs/supabase/schema.sql`, the setup in `docs/cloud-sync.md`. The section stays switched off until `supabase.properties` (ignored by Git) holds the project URL and anon key at build time.
- Tests: the sync engine with two phones and a cloud that drops stale writes, the cloud codec, the sign-in proof key and session parsing, and the version 3 migration.

### Changed

- The database moves to schema version 3: every record gets a UUID and a last-change time, and a table of pending deletions is added. Existing data is kept.
- Deleting a record now leaves a tombstone until the next sync, and the CSV import tombstones the records it replaces.

## [0.5.0] - 2026-10-21

### Added

- Italian translation of the whole app: screens, form errors, notifications and the home screen widget. The app follows the phone's language (Italian or English); on Android 13 and later it also appears in the system's per-app language settings. Numbers and dates follow the language (1.234,5 and 21/10/2026 in Italian).
- Richer motion. Dashboard: cards enter in sequence, the gauge needle springs with a little overshoot while its digits count up on their own curve, and amounts climb to their values. Charts: bars grow in sequence, the consumption line draws left to right with points popping in, and selecting a point fades the tooltip. Lists: rows cascade in, reorder smoothly and collapse when swiped away before the deletion is reported. Navigation: tabs cross-fade with a slight zoom, other screens slide along the horizontal axis, and the fill-up button pops in and shrinks to an icon while a list is scrolled. Fields fade to amber when the app calculates a value, an overdue badge breathes, and the splash draws the ledger lines before the name appears.
- **Check for updates** in Settings, which becomes **Update app** when GitHub has a newer release and opens the APK download. It is the app's only network request and runs only when tapped. The row is available in English and Italian.
- Tests: English and Italian string files must have the same keys and placeholders, Italian text is resolved under Robolectric, and swipe-to-delete and the stagger timing are covered.

### Changed

- All interface text now lives in string resources (`values/` English, `values-it/` Italian). View models hold `UiText` instead of literals, enum labels moved to `ui/Labels.kt`, reminder phrases come from `Fmt.daysPhrase` as `UiText`, and CSV import errors are typed (`CsvFormatException`) so they can be shown in the user's language.
- Display formatting follows the app language: Italian conventions in Italian, British ones otherwise.
- Unit tests run with a fixed English locale, so results do not depend on the language of the machine.
- Only English and Italian library resources are packaged.
- The app now declares the `INTERNET` permission, for the update check only. `ACCESS_NETWORK_STATE` stays removed.

## [0.4.0] - 2026-10-21

### Added

- Optional "Range before fill-up" field. With it, consumption is estimated for partial fill-ups too, from the change in displayed range between two readings.
- Statistics card "Estimated from range", with a calibration against full-to-full segments that shows how far the board computer is off.
- GitHub Pages download page (`docs/index.html`) whose button always links to the APK of the latest release.
- The CSV backup carries the range in a new last column. Files from earlier versions still import, and older apps ignore the column.

### Changed

- `build_apk.bat` writes the APK to `dist/` and deletes older builds there, so only the latest one is kept.
- The database moves to schema version 2 (new nullable `rangeBeforeKm` column). Existing data is kept. Room schemas are now exported to `app/schemas/` and a test covers the 1 to 2 migration.

### Security

- Encrypted the source code on GitHub with transcrypt (AES-256-CBC), rewriting the existing history and tags. Documentation and release assets stay readable.

## [0.3.0] - 2026-10-20

### Added

- Receipt scan in the new fill-up form: camera or gallery photo, on-device ML Kit text recognition and a parser for Italian pump receipts (liters, price per liter, total, date). Inconsistent liters are recalculated from price and total.
- Home screen widget built with Glance: average consumption, odometer, most urgent reminder and a fill-up shortcut. It refreshes after every change and once a day.
- Tests for receipt parsing and the widget summary, plus rendered widget screenshots.

### Changed

- The fill-up shortcut opens the form directly and skips the cold-start animation.
- Release APKs include ARM native code only, which keeps the ML Kit model at about 33 MB instead of 56 MB.
- Releases are signed with a personal key and distributed on GitHub Releases, with an Obtainium guide in `docs/install.md`. Debug-signed builds must be uninstalled first; export a CSV backup before doing so.
- `build_apk.bat` asks for the signing password with hidden input when `keystore.properties` exists; the password is read from `FUEL_LEDGER_KEY_PASSWORD` and never stored on disk.

### Security

- Removed the `INTERNET` and `ACCESS_NETWORK_STATE` permissions that ML Kit adds, so the app stays offline.

## [0.2.0] - 2026-10-20

### Added

- Fuel Ledger vector identity, adaptive launcher icon and notification mark.
- Animated cold-start needle with a system-animation-disabled fallback.
- Static and animated SVG wordmarks, English review screenshots and a dashboard startup GIF rendered from Compose.
- Tests for English formatting and splash completion.

### Changed

- Renamed the project and application ID to `com.fcastaldi.fuelledger`.
- Translated the interface, enum names, messages and repository documentation into English.
- Switched display formatting to English while retaining euros, liters and kilometers.
- Renamed local storage and CSV identifiers. The earlier prototype remains a separate app; its CSV format is not directly compatible.

### Security

- Disabled Android automatic cloud backup to keep app-managed data local.

## [0.1.0] - 2026-10-20

### Added

- Local Italian-language prototype with multiple vehicles, fill-ups, full-to-full consumption, expenses and reminders.
- Daily reminder notifications, monthly spending charts and CSV import/export.
- Automatic day/night themes, animated gauge and rolling odometer.
- Unit, Room repository and screenshot-rendering tests.

Version 0.1.0 was a local prototype and was not published.

[Unreleased]: https://github.com/FrancescoCastaldi/fuel-ledger-android/compare/v0.6.0...HEAD
[0.6.0]: https://github.com/FrancescoCastaldi/fuel-ledger-android/compare/v0.5.0...v0.6.0
[0.5.0]: https://github.com/FrancescoCastaldi/fuel-ledger-android/compare/v0.4.0...v0.5.0
[0.4.0]: https://github.com/FrancescoCastaldi/fuel-ledger-android/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/FrancescoCastaldi/fuel-ledger-android/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/FrancescoCastaldi/fuel-ledger-android/releases/tag/v0.2.0
[0.1.0]: https://github.com/FrancescoCastaldi/fuel-ledger-android
