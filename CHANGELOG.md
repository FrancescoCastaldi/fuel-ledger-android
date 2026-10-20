# Changelog

All notable changes to this project are documented here.

The format follows [Keep a Changelog 1.1.0](https://keepachangelog.com/en/1.1.0/) and this project uses [Semantic Versioning](https://semver.org/).

## [Unreleased]

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

[Unreleased]: https://github.com/FrancescoCastaldi/fuel-ledger-android/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/FrancescoCastaldi/fuel-ledger-android/releases/tag/v0.2.0
[0.1.0]: https://github.com/FrancescoCastaldi/fuel-ledger-android
