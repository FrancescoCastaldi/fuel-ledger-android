# Codemap: Fuel Ledger

Offline Android car logbook for fill-ups, consumption, expenses and maintenance reminders.

## Architecture

```text
Compose screens -> ViewModel (StateFlow) -> CarRepository -> Room (AppDatabase)
                                                ^
DeadlineReminderWorker (daily WorkManager) ------+--> Local notifications
```

`AppContainer` in `FuelLedgerApp` creates the database and repository. `AppViewModelProvider` constructs ViewModels. SharedPreferences stores the selected vehicle. `CarRepository.currentData` emits its vehicle, fill-ups, expenses and reminders.

## Modules

Paths below are relative to `app/src/main/java/com/fcastaldi/fuelledger/`.

| Path | Responsibility |
|:---|:---|
| `FuelLedgerApp.kt` | Application, dependency container, reminder scheduling |
| `MainActivity.kt` | System splash, edge-to-edge window, cold-start UI, notification permission |
| `data/entity/Entities.kt` | Room entities and English type enums |
| `data/Daos.kt`, `data/AppDatabase.kt` | Queries, database and date converters |
| `data/CarRepository.kt` | Selected vehicle, flows, CRUD and transactional import |
| `domain/ConsumptionCalculator.kt` | Full-to-full consumption and weighted averages |
| `domain/CostCalculator.kt` | Cost per kilometer, period totals and monthly totals |
| `domain/DeadlineEvaluator.kt` | Reminder status, renewal and urgency order |
| `domain/RefuelMath.kt` | Missing fill-up value and odometer validation |
| `domain/CsvCodec.kt` | Single-file CSV with V, R, E and D record types |
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

## Assets and delivery

- `docs/brand/`: static and animated SVG wordmarks, palette and usage notes.
- `docs/screenshots/`: reviewed English screenshots.
- `docs/demo/dashboard.gif`: startup sequence rendered from Compose tests.
- `build_apk.bat`: test gate and versioned local release APK.
- `tools/outline_brand.py`: reproducible wordmark font outlining.
- `app/src/main/res/`: launcher/notification vectors, themes and bundled OFL fonts.
