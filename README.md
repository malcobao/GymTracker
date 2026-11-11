# Gym Tracker

A personal gym tracker built with Flutter. Everything is stored **locally**
on the device (SQLite), works offline and needs no account. English and
Spanish.

- **Routines**: create, edit, archive/restore, delete; exercises with muscle
  group and targets, drag to reorder.
- **Workout**: log every set (weight × reps), edit or delete a set.
- **Statistics**: 8 KPIs and 5 animated charts, all filterable (period,
  routine, exercise, muscle group) and configurable (metric, grouping,
  ranking).
- **Reports**: set log, summary by exercise, summary by period, personal
  records; filters, grouping, sorting, totals, copy as CSV.
- **Settings**: profile, language, light/dark theme, accent colour, kg/lb,
  database row counts, load sample data, delete all data.

Database design, integrity rules and where each CRUD operation lives:
[`docs/DATABASE.md`](docs/DATABASE.md). Decisions: [`docs/DECISIONS.md`](docs/DECISIONS.md).

## Run

Requires Flutter 3.47 (Dart 3.13) or newer.

```sh
flutter pub get
flutter run -d chrome      # or an Android emulator / phone, or F5 in VS Code
```

On first launch the app asks for your profile. To try the statistics and
reports at once: **Settings → Load sample data** (3 routines, 8 weeks of
workouts).

The web build stores the database in the browser (IndexedDB) using the files
`web/sqlite3.wasm` and `web/sqflite_sw.js`, created with
`dart run sqflite_common_ffi_web:setup`.

## Checks

```sh
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

Repository tests run against a real in-memory SQLite (sqflite_common_ffi), so
foreign keys, CHECK and UNIQUE rules are tested for real.

## Translations

All texts live in `lib/l10n/app_en.arb` and `app_es.arb`, generated from
`tool/gen_arb.py` (both languages side by side, so none can be missing):

```sh
python tool/gen_arb.py
flutter gen-l10n
```

## Project structure

```
lib/
  config/        dependency injection (which repository implementation)
  data/
    local/       database schema, opening per platform, change notifier
    repositories/  abstract repositories + sqlite/ implementations (SQL)
    errors/      database errors → app errors
  domain/        models, validation, progress, statistics, reports (pure Dart)
  l10n/          English / Spanish texts
  routing/       paths and router (bottom navigation with 4 tabs)
  ui/            one folder per feature: screen + view model
    core/        theme (design system), labels, shared widgets, charts
test/            data (SQLite), domain, ui (end-to-end widget tests)
```

Architecture: MVVM as in Flutter's architecture guide — views
(`*_screen.dart`) → view models (`ChangeNotifier`) → repositories (abstract
classes) → SQLite. `provider` for dependency injection, `go_router` for
navigation.
