# Local database

Everything is stored on the device in one SQLite file (`gym_tracker.db`):
a file in the app's private folder on Android/iOS, and IndexedDB (SQLite
compiled to WebAssembly) in the browser. The schema lives in
[`lib/data/local/app_database.dart`](../lib/data/local/app_database.dart).

## The four tables

```text
profile (1) ──< routines (N)        one owner, many training plans
routines (1) ──< exercises (N)       a plan has ordered exercises
exercises (1) ──< workout_sets (N)   every set lifted for an exercise
```

| Table | What one row is | Key columns |
| --- | --- | --- |
| `profile` | The app's owner (personal use: one row, `id = 1`) | name, birth date, sex, height, body weight (kg), experience, goal, weight unit |
| `routines` | A training plan, e.g. "Push day" | `profile_id` → profile, name, description, `archived_at` |
| `exercises` | One exercise of one routine | `routine_id` → routines, name, muscle group, target sets/reps, `position`, `archived_at` |
| `workout_sets` | One set actually lifted | `exercise_id` → exercises, `performed_on` (date), `set_number`, `weight_kg`, `reps` |

Calculated, never stored: age, BMI, volume (weight × reps), estimated 1RM
(Epley), every statistic and report. App preferences (language, theme,
accent colour) are device settings kept in shared_preferences, so the
database has exactly four tables.

## Integrity rules (enforced by SQLite itself)

| Rule | How |
| --- | --- |
| Foreign keys are checked | `PRAGMA foreign_keys = ON` on every connection (`onConfigure`) |
| A set must belong to an existing exercise, an exercise to an existing routine | `REFERENCES … ` on every child column, `NOT NULL` |
| Deleting a routine deletes its exercises | `exercises.routine_id … ON DELETE CASCADE` |
| History is never deleted by accident | `workout_sets.exercise_id … ON DELETE RESTRICT`: deleting an exercise (or a routine whose exercises) has sets fails |
| Valid values | `CHECK` on every column: name length 1–60, height 50–272 cm, body weight 20–400 kg, weight 0–1000 kg, reps 1–200, target sets 1–20, target reps 1–100, enum values, date format |
| One profile | `CHECK (id = 1)` |
| No duplicate names | `UNIQUE` index on `(profile_id, name COLLATE NOCASE) WHERE archived_at IS NULL` (and per routine for exercises) |
| No duplicate set numbers | `UNIQUE (exercise_id, performed_on, set_number)` |

The forms check the same limits on every keystroke (real-time validation,
[`lib/domain/validation.dart`](../lib/domain/validation.dart)); the database
is the final authority. Database errors are translated into friendly,
translated messages ([`lib/data/errors/app_exception.dart`](../lib/data/errors/app_exception.dart)).

### Deleting with referential integrity

1. The user taps *Delete* and confirms.
2. The repository runs `DELETE`. If sets depend on the row, SQLite refuses
   (`FOREIGN KEY constraint failed`) and nothing changes.
3. The app counts the dependent sets and offers: **Archive** (hide it, keep
   the history; can be restored) or **Delete everything** (one transaction:
   delete the sets, then the row).

## Where each CRUD operation lives

UI → view model → repository (abstract) → SQLite implementation (SQL).

| Table | Create | Read | Update | Delete |
| --- | --- | --- | --- | --- |
| `profile` | `SqliteProfileRepository.saveProfile` (first time) | `getProfile` | `saveProfile` (afterwards; weight unit from Settings) | `SqliteDataRepository.deleteAllData` |
| `routines` | `SqliteRoutineRepository.createRoutine` | `listRoutines`, `getRoutine` | `updateRoutine`, `archiveRoutine`, `restoreRoutine` | `deleteRoutine` (`withHistory`) |
| `exercises` | `addExercise` | `listExercises`, `listAllExercises` (JOIN) | `updateExercise`, `reorderExercises`, `archiveExercise`, `restoreExercise` | `deleteExercise` (`withHistory`) |
| `workout_sets` | `SqliteWorkoutRepository.logSet` | `listSetsOn`, `listSetsForExercise`, `records` (3-table JOIN with filters) | `updateSet` | `deleteSet` (renumbers the rest) |

Screens that trigger them: `ui/profile/profile_form_screen.dart`,
`ui/routines/routine_list_screen.dart`, `ui/routines/routine_detail_screen.dart`,
`ui/workout/workout_screen.dart`, `ui/settings/settings_screen.dart`.

## Statistics and reports

Both start from one parameterised query, `SqliteWorkoutRepository.records`
(`workout_sets JOIN exercises JOIN routines WHERE …`), and compute in pure
Dart so every number is unit-tested.

**Statistics** (`domain/statistics.dart`, screen `ui/statistics/`). Global
parameters: period (7/30/90 days, 12 months, all, custom range), routine,
exercise, muscle group.

1. KPIs: training days, sets, reps, total volume, average volume per session,
   average sets per session, best estimated 1RM (and exercise), week streak.
2. Progress over time — bar chart; parameters: metric (volume/sets/reps),
   grouping (day/week/month).
3. Estimated 1RM progress — line chart; parameter: exercise.
4. Distribution by muscle group — donut chart; parameter: metric.
5. Training days by weekday — bar chart.
6. Top exercises — ranking bars; parameters: rank by (volume/best 1RM), size
   (3/5/10).

**Reports** (`domain/reports.dart`, screen `ui/reports/`). Parameters: report
type, period, routine, exercise, muscle group, grouping (by period), sort
column and direction (also by tapping a column header). Every report has a
totals row (except records) and can be copied as CSV.

| Report | One row per | Columns |
| --- | --- | --- |
| Set log | set | date, routine, exercise, muscle group, set, weight, reps, volume |
| Summary by exercise | exercise | exercise, routine, muscle group, days, sets, reps, volume, top weight, best 1RM |
| Summary by period | day / week / month | period, days, sets, reps, volume, top weight |
| Personal records | exercise | exercise, muscle group, top weight + date, best 1RM + date |
