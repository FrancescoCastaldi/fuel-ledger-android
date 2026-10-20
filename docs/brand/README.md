# Brand assets

The Fuel Ledger mark combines a 250-degree instrument dial, an ignition needle and three ledger entries. It is drawn as vector geometry, not a generated raster image.

| Token | Value | Use |
|:---|:---|:---|
| Anthracite | `#0F1215` | Night background |
| Instrument amber | `#FFA128` | Mark and active controls |
| Warm white | `#F2EFE8` | Ledger lines and primary text |
| Steel | `#9AA1AB` | Supporting text |
| Paper | `#F4F3EF` | Day background |

Display: Barlow Condensed. Body: Barlow. Numeric styles use tabular figures. SVG wordmarks use outlined lettering from the bundled fonts, so they render consistently without installed fonts.

`uv run tools/outline_brand.py` converts any SVG text elements to paths using FontTools. Keep the font license alongside distributed brand assets.

- `logo.svg`: static wordmark.
- `logo-animated.svg`: repeating ignition sweep, with a reduced-motion fallback.
- Android launcher: `app/src/main/res/drawable/ic_launcher_foreground.xml`.
- Android notification: `app/src/main/res/drawable/ic_stat_gauge.xml`.
- In-app mark and cold-start animation: `FuelLedgerSplash.kt`.

The README dashboard GIF is a recording of Compose test frames with synthetic vehicle data. It demonstrates the ignition sweep, not a live sensor reading.
