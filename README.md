# Gym Tracker

A personal gym progress tracker built with Flutter and Supabase: create routines,
log every set (weight × reps) and see your progress per exercise.

University course project. Full design (requirements, ER diagram, data dictionary,
security rules, architecture): see `docs/DECISIONS.md`.

## Requirements

- Flutter 3.47.9 (Dart 3.13.7) or newer on the stable channel
- A Supabase project (free plan is enough)

## Run

The app reads its Supabase settings at build time. Only the **publishable** key
goes here; never pass the secret key to the app.

```sh
flutter pub get
flutter run \
  --dart-define=SUPABASE_URL=https://<project-ref>.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=<publishable key>
```

## Checks

```sh
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

## Database

- `supabase/migrations/` — the approved schema (4 tables + Row Level Security).
  Apply with `supabase link` then `supabase db push`.
- `supabase/tests/` — SQL tests run against plain PostgreSQL 16 with a stand-in
  for Supabase's `auth` schema (`test_mock_supabase_auth.sql`).

## Project structure

```
lib/
  config/     build-time settings
  routing/    routes and redirects (go_router)
  domain/     models and pure business logic (added in later milestones)
  data/       repositories that talk to Supabase (added in later milestones)
  ui/         one folder per feature: view + view model; ui/core = shared widgets
  utils/      small shared types such as Result
```
