# Changelog

All notable changes to this project are documented here.

The format follows [Keep a Changelog 1.1.0](https://keepachangelog.com/en/1.1.0/) and this project uses [Semantic Versioning](https://semver.org/).

## [Unreleased]

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

[Unreleased]: https://github.com/FrancescoCastaldi/fuel-ledger-android/compare/v0.4.0...HEAD
[0.4.0]: https://github.com/FrancescoCastaldi/fuel-ledger-android/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/FrancescoCastaldi/fuel-ledger-android/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/FrancescoCastaldi/fuel-ledger-android/releases/tag/v0.2.0
[0.1.0]: https://github.com/FrancescoCastaldi/fuel-ledger-android
