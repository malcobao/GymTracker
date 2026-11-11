# Gym Tracker

A personal gym progress tracker built with Flutter and Supabase: create routines,
log every set (weight × reps) and see your progress per exercise.

University course project. Full design (requirements, ER diagram, data dictionary,
security rules, architecture): see `docs/DECISIONS.md`.

## Requirements

- Flutter 3.47.9 (Dart 3.13.7) or newer on the stable channel
- A Supabase project (free plan is enough)

## Quick start: demo mode (no Supabase needed)

```sh
flutter pub get
flutter run            # or press F5 in VS Code
```

Started without Supabase settings, the app runs in **demo mode** (a "DEMO"
ribbon is shown): any email and a password of 8+ characters sign in, and a
sample "Push day" routine with two past bench-press sessions is preloaded.
Data lives in memory only and is lost when the app closes.

## Set up the database (once, for real data)

1. Create a free project at supabase.com.
2. Open the project's **SQL Editor**, paste the whole file
   `supabase/migrations/20261104120000_init_schema.sql` and run it.
   (Or, with the Supabase CLI: `supabase link` then `supabase db push`.)
3. In **Project Settings → API keys**, copy the project URL and the
   **publishable** key. Never copy the secret key into the app.
4. Email confirmation is on by default. The app has no deep link for the
   confirmation email yet, so either confirm via the email link and then sign in
   in the app, or turn off "Confirm email" in the Email provider settings of
   Supabase Authentication for this personal project.

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

## Features

- Email + password sign up / sign in / sign out / password reset
- Onboarding profile (name, birth date, sex, height, body weight, experience,
  goal, kg or lb) and profile editing
- Routines: create, rename, remove (archived, history kept)
- Exercises per routine: add, edit, remove, drag to reorder, targets
- Today's workout: log every set (weight × reps), delete mistakes
- Progress per exercise: best estimated 1RM (Epley), change, chart, history

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
  domain/     models, validation and progress calculations (pure Dart)
  data/       repositories: abstract classes + Supabase implementations
  ui/         one folder per feature: view + view model; ui/core = shared widgets
  utils/      small shared types such as Result
```
