# Codemap: Fuel Ledger

Offline Android car logbook for fill-ups, consumption, expenses and maintenance reminders.

## Architecture

```text
Compose screens -> ViewModel (StateFlow) -> CarRepository -> Room (AppDatabase)
                                                ^
DeadlineReminderWorker (daily WorkManager) ------+--> Local notifications, widget refresh
FuelLedgerWidget (Glance) -------------------------+
Fill-up form -> ReceiptScanner (ML Kit, on device) -> ReceiptParser
```

`AppContainer` in `FuelLedgerApp` creates the database and repository. `FuelLedgerApp` also refreshes the widget whenever `currentData` changes. `AppViewModelProvider` constructs ViewModels. SharedPreferences stores the selected vehicle. `CarRepository.currentData` emits its vehicle, fill-ups, expenses and reminders.

## Modules

Paths below are relative to `app/src/main/java/com/fcastaldi/fuelledger/`.

| Path | Responsibility |
|:---|:---|
| `FuelLedgerApp.kt` | Application, dependency container, reminder scheduling |
| `MainActivity.kt` | System splash, edge-to-edge window, cold-start UI, notification permission, `ACTION_ADD_REFUEL` |
| `data/entity/Entities.kt` | Room entities and English type enums |
| `data/Daos.kt`, `data/AppDatabase.kt` | Queries, database and date converters |
| `data/CarRepository.kt` | Selected vehicle, flows, CRUD and transactional import |
| `domain/ConsumptionCalculator.kt` | Full-to-full consumption and weighted averages |
| `domain/CostCalculator.kt` | Cost per kilometer, period totals and monthly totals |
| `domain/DeadlineEvaluator.kt` | Reminder status, renewal and urgency order |
| `domain/RefuelMath.kt` | Missing fill-up value and odometer validation |
| `domain/CsvCodec.kt` | Single-file CSV with V, R, E and D record types |
| `domain/ReceiptParser.kt` | OCR line merging and liters, price, total and date extraction |
| `scan/ReceiptScanner.kt` | Camera cache URI, ML Kit recognition and photo cleanup |
| `widget/FuelLedgerWidget.kt` | Glance widget, receiver, day/night palette and fill-up shortcut |
| `widget/WidgetSummary.kt` | Formatted widget data for the selected vehicle |
| `ui/Fmt.kt`, `ui/Icons.kt` | English formatting and type-to-icon mapping |
| `ui/theme/` | Day/night colors, Barlow typography and shapes |
| `ui/components/` | Gauge, rolling odometer, charts, forms and swipe rows |
| `ui/components/FuelLedgerSplash.kt` | Vector mark and animated cold-start needle |
| `ui/dashboard/`, `ui/refuels/`, `ui/expenses/` | Main records and forms |
| `ui/deadlines/`, `ui/stats/`, `ui/settings/` | Reminders, charts, vehicles and CSV picker |
| `ui/navigation/FuelLedgerRoot.kt` | Navigation host, five tabs and transitions |
| `work/DeadlineReminderWorker.kt` | Notification channel and daily reminder check |

## Tests

Under `app/src/test/java/com/fcastaldi/fuelledger/`:

- `domain/*Test.kt`: calculations, validation and CSV.
- `data/CarRepositoryTest.kt`: in-memory Room, selection, cascade deletion and import.
- `ui/FmtTest.kt`: English formatting and reminder phrases.
- `ui/ScreenshotTest.kt`: review screenshots, splash completion and dashboard animation frames.
- `domain/ReceiptParserTest.kt`: receipt layouts, cross-checks, totals and dates.
- `widget/WidgetSummaryTest.kt`, `widget/WidgetRenderTest.kt`: widget data and RemoteViews screenshots.

## Assets and delivery

- `docs/brand/`: static and animated SVG wordmarks, palette and usage notes.
- `docs/screenshots/`: reviewed English screenshots.
- `docs/demo/dashboard.gif`: startup sequence rendered from Compose tests.
- `build_apk.bat`: signing password prompt, test gate and versioned local release APK.
- `docs/install.md`: GitHub Releases, Obtainium, signing fingerprint and release steps.
- `docs/releases/`: release notes used for each GitHub release.
- `tools/outline_brand.py`: reproducible wordmark font outlining.
- `app/src/main/res/`: launcher/notification vectors, themes and bundled OFL fonts.
