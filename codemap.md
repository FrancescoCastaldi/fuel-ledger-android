# Codemap: Fuel Ledger

Offline Android car logbook for fill-ups, consumption, expenses and maintenance reminders.

## Architecture

```text
Compose screens -> ViewModel (StateFlow) -> CarRepository -> Room (AppDatabase)
                                                ^
DeadlineReminderWorker (daily WorkManager) ------+--> Local notifications, widget refresh
FuelLedgerWidget (Glance) -------------------------+
Fill-up form -> ReceiptScanner (ML Kit, on device) -> ReceiptParser
Fill-up form -> DashboardScanDialog -> DashboardCamera (CameraX + ML Kit, on device) -> DashboardParser -> ReadingStabilizer
```

`AppContainer` in `FuelLedgerApp` creates the database and repository. `FuelLedgerApp` also refreshes the widget whenever `currentData` changes. `AppViewModelProvider` constructs ViewModels. SharedPreferences stores the selected vehicle. `CarRepository.currentData` emits its vehicle, fill-ups, expenses and reminders.

## Modules

Paths below are relative to `app/src/main/java/com/fcastaldi/fuelledger/`.

| Path | Responsibility |
|:---|:---|
| `FuelLedgerApp.kt` | Application, dependency container, reminder scheduling |
| `MainActivity.kt` | System splash, edge-to-edge window, cold-start UI, notification permission, `ACTION_ADD_REFUEL` |
| `data/entity/Entities.kt` | Room entities, English type enums and the 3x3 cluster grid (`DashSpot`) of each vehicle |
| `data/Daos.kt`, `data/AppDatabase.kt` | Queries, database and date converters |
| `data/CarRepository.kt` | Selected vehicle, flows, CRUD and transactional import |
| `domain/ConsumptionCalculator.kt` | Full-to-full consumption and weighted averages |
| `domain/RangeConsumptionCalculator.kt` | Consumption estimate from the range before each refuel, with board computer calibration |
| `domain/CostCalculator.kt` | Cost per kilometer, period totals and monthly totals |
| `domain/DeadlineEvaluator.kt` | Reminder status, renewal and urgency order |
| `domain/RefuelMath.kt` | Missing fill-up value and odometer validation |
| `domain/CsvCodec.kt` | Single-file CSV with V, R, E and D record types |
| `domain/ReceiptParser.kt` | OCR line merging and liters, price, total and date extraction |
| `domain/DashboardParser.kt` | Scores numbers on the cluster for the odometer and the range by cell, unit, label and history |
| `domain/ReadingStabilizer.kt` | Locks a value once it holds across frames, and shows the most frequent one until then |
| `domain/DashboardHistory.kt` | Odometer limits and expected reading from a car's fill-ups around a date |
| `domain/ViewfinderMap.kt` | Guide frame on screen and mapping of photo words onto it, undoing the preview crop |
| `scan/ReceiptScanner.kt` | Camera cache URI for receipt photos, reading and photo cleanup |
| `scan/TextScanner.kt` | ML Kit recognition of one photo, with its upright size |
| `scan/DashboardScanner.kt` | Gallery photo of the cluster; values are marked for checking |
| `scan/DashboardCamera.kt` | Live CameraX preview and frame analysis, nothing written to disk |
| `ui/refuels/DashboardScanDialog.kt` | Full-screen live scan: permission, guide frame, locked values and the accept action |
| `widget/FuelLedgerWidget.kt` | Glance widget, receiver, day/night palette and fill-up shortcut |
| `widget/WidgetSummary.kt` | Formatted widget data for the selected vehicle |
| `ui/Fmt.kt`, `ui/Icons.kt` | Language-aware formatting and type-to-icon mapping |
| `ui/UiText.kt`, `ui/Labels.kt` | A string resource with arguments resolved late, and the resource ids of enum labels |
| `sync/SyncEngine.kt` | Two-way merge of the local database with the cloud by uuid, newest `updatedAt` wins |
| `sync/CloudApi.kt`, `sync/CloudCodec.kt` | The cloud as the engine sees it, and the conversion of records to and from cloud rows |
| `sync/SupabaseApi.kt`, `sync/SupabaseAuth.kt`, `sync/Http.kt`, `sync/Pkce.kt` | REST client, Google sign-in through the browser with a proof key, session storage |
| `sync/CloudService.kt`, `ui/settings/CloudViewModel.kt` | Sign-in state, sync in the app scope, and the Settings view of it |
| `update/ReleaseVersion.kt`, `update/GitHubReleases.kt` | Version comparison and the latest-release request, made only when the user taps Check for updates |
| `ui/settings/UpdateViewModel.kt` | State of the update row in Settings |
| `ui/Motion.kt` | Shared easing and timing, staggered entrance, count-up and the entrance window of lists |
| `ui/theme/` | Day/night colors, Barlow typography and shapes |
| `ui/components/` | Gauge, rolling odometer, charts, forms, swipe rows and the cluster spot picker (`SpotPicker.kt`) |
| `ui/components/FuelLedgerSplash.kt` | Vector mark and animated cold-start needle |
| `ui/dashboard/`, `ui/refuels/`, `ui/expenses/` | Main records and forms |
| `ui/deadlines/`, `ui/stats/`, `ui/settings/` | Reminders, charts, vehicles and CSV picker |
| `ui/navigation/FuelLedgerRoot.kt` | Navigation host, five tabs and transitions |
| `work/DeadlineReminderWorker.kt` | Notification channel and daily reminder check |

## Tests

Under `app/src/test/java/com/fcastaldi/fuelledger/`:

- `domain/*Test.kt`: calculations, validation and CSV.
- `data/CarRepositoryTest.kt`: in-memory Room, selection, cascade deletion and import.
- `data/AppDatabaseMigrationTest.kt`: builds a version 1 database from `app/schemas/` and migrates it.
- `domain/RangeConsumptionCalculatorTest.kt`: range-based estimates and calibration.
- `ui/FmtTest.kt`: English and Italian formatting and reminder phrases.
- `ui/StringResourcesTest.kt`, `ui/ItalianLocalizationTest.kt`: parity of `values/` and `values-it/`, and Italian text under Robolectric.
- `sync/SyncEngineTest.kt`, `sync/CloudCodecTest.kt`, `sync/AuthTest.kt`: sync between two phones and a fake cloud, record conversion, proof key and session parsing.
- `update/UpdateTest.kt`: version comparison, release JSON parsing and the update state machine.
- `ui/MotionTest.kt`, `ui/SwipeToDeleteTest.kt`: stagger timing and swipe-to-delete.
- `ui/ScreenshotTest.kt`: review screenshots, splash completion and dashboard animation frames.
- `domain/ReceiptParserTest.kt`: receipt layouts, cross-checks, totals and dates.
- `domain/DashboardParserTest.kt`, `domain/ReadingStabilizerTest.kt`, `domain/DashboardHistoryTest.kt`, `domain/ViewfinderMapTest.kt`: cluster readings, value locking, odometer limits and frame mapping.
- `widget/WidgetSummaryTest.kt`, `widget/WidgetRenderTest.kt`: widget data and RemoteViews screenshots.

## Assets and delivery

- `docs/brand/`: static and animated SVG wordmarks, palette and usage notes.
- `docs/screenshots/`: reviewed English screenshots.
- `docs/demo/dashboard.gif`: startup sequence rendered from Compose tests.
- `build_apk.bat`: the whole release step. Finds the signing password, runs the test gate, builds the versioned APK in `dist/` (removing older builds), then verifies it (versions, single APK, package, permissions, languages, signature against the fingerprint in `docs/install.md`). The console shows the RESULT; detail goes to the ignored `build_apk.log`. `build_apk.bat verify` only re-checks the APK in `dist/`.
- `dist/`: the latest signed APK only. Ignored by Git, never committed.
- `docs/index.html`: GitHub Pages site (source: `main`, folder `/docs`). Its download button reads the latest release from the GitHub API, so it needs no edit per release. `docs/.nojekyll` turns off Jekyll processing.
- `docs/cloud-sync.md`, `docs/supabase/schema.sql`: setup of the optional Supabase sync and its tables with row level security.
- `docs/install.md`: GitHub Releases, Obtainium, signing fingerprint and release steps.
- `docs/releases/`: release notes used for each GitHub release.
- `tools/outline_brand.py`: reproducible wordmark font outlining.
- `app/schemas/`: exported Room schemas, one JSON per database version.
- `app/src/main/res/values/strings.xml`, `values-it/strings.xml`: all interface text in English and Italian; `xml/locales_config.xml` lists the languages for Android 13 per-app settings.
- `app/src/main/res/`: launcher/notification vectors, themes and bundled OFL fonts.
