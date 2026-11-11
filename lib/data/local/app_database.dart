import 'package:sqflite/sqflite.dart';

/// The local SQLite database: four tables, created on first launch.
///
/// ```text
///  profile 1 ──< routines 1 ──< exercises 1 ──< workout_sets
/// ```
///
/// Referential integrity is enforced by SQLite itself (`PRAGMA foreign_keys`):
/// * deleting a routine deletes its exercises (`ON DELETE CASCADE`), but
/// * an exercise with logged sets cannot be deleted (`ON DELETE RESTRICT`),
///   so a routine whose exercises have history cannot be deleted either.
///   The app then offers to archive it, or to delete the history explicitly.
abstract final class AppDatabase {
  static const fileName = 'gym_tracker.db';
  static const version = 1;

  /// Opens (and on first use creates) the database at [path] with [factory].
  /// Tests pass `inMemoryDatabasePath` and the FFI factory.
  static Future<Database> open(DatabaseFactory factory, String path) =>
      factory.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: version,
          // Foreign keys are off by default in SQLite: turn them on for every
          // connection, before anything else runs.
          onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
          onCreate: (db, _) async {
            final batch = db.batch();
            for (final statement in schema) {
              batch.execute(statement);
            }
            await batch.commit(noResult: true);
          },
        ),
      );

  /// The complete schema (also printed in docs/DATABASE.md).
  static const schema = [
    // 1. The single user of the app (personal use): always id = 1.
    '''
CREATE TABLE profile (
  id               INTEGER PRIMARY KEY CHECK (id = 1),
  display_name     TEXT    NOT NULL CHECK (length(trim(display_name)) BETWEEN 1 AND 50),
  birth_date       TEXT    NOT NULL CHECK (birth_date GLOB '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]'),
  sex              TEXT    NOT NULL CHECK (sex IN ('male', 'female', 'unspecified')),
  height_cm        REAL    NOT NULL CHECK (height_cm BETWEEN 50 AND 272),
  body_weight_kg   REAL    NOT NULL CHECK (body_weight_kg BETWEEN 20 AND 400),
  experience_level TEXT    NOT NULL CHECK (experience_level IN ('beginner', 'intermediate', 'advanced')),
  goal             TEXT    NOT NULL CHECK (goal IN ('strength', 'muscle_gain', 'fat_loss', 'general_fitness')),
  weight_unit      TEXT    NOT NULL DEFAULT 'kg' CHECK (weight_unit IN ('kg', 'lb')),
  created_at       TEXT    NOT NULL DEFAULT (datetime('now')),
  updated_at       TEXT    NOT NULL DEFAULT (datetime('now'))
)''',
    // 2. Training plans. Archived routines (archived_at set) are hidden but
    //    keep their history.
    '''
CREATE TABLE routines (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  profile_id  INTEGER NOT NULL DEFAULT 1
              REFERENCES profile (id) ON UPDATE CASCADE ON DELETE RESTRICT,
  name        TEXT    NOT NULL CHECK (length(trim(name)) BETWEEN 1 AND 60),
  description TEXT    CHECK (description IS NULL OR length(description) <= 500),
  archived_at TEXT,
  created_at  TEXT    NOT NULL DEFAULT (datetime('now')),
  updated_at  TEXT    NOT NULL DEFAULT (datetime('now'))
)''',
    // Two active routines cannot share a name (case-insensitive).
    '''
CREATE UNIQUE INDEX routines_active_name_uq
  ON routines (profile_id, name COLLATE NOCASE) WHERE archived_at IS NULL''',
    // 3. Exercises of a routine, in the order given by position.
    '''
CREATE TABLE exercises (
  id           INTEGER PRIMARY KEY AUTOINCREMENT,
  routine_id   INTEGER NOT NULL
               REFERENCES routines (id) ON UPDATE CASCADE ON DELETE CASCADE,
  name         TEXT    NOT NULL CHECK (length(trim(name)) BETWEEN 1 AND 60),
  muscle_group TEXT    CHECK (muscle_group IS NULL OR muscle_group IN
                 ('chest', 'back', 'shoulders', 'biceps', 'triceps', 'legs',
                  'glutes', 'core', 'full_body', 'other')),
  target_sets  INTEGER CHECK (target_sets IS NULL OR target_sets BETWEEN 1 AND 20),
  target_reps  INTEGER CHECK (target_reps IS NULL OR target_reps BETWEEN 1 AND 100),
  position     INTEGER NOT NULL CHECK (position >= 1),
  archived_at  TEXT,
  created_at   TEXT    NOT NULL DEFAULT (datetime('now')),
  updated_at   TEXT    NOT NULL DEFAULT (datetime('now'))
)''',
    'CREATE INDEX exercises_routine_idx ON exercises (routine_id, position)',
    '''
CREATE UNIQUE INDEX exercises_active_name_uq
  ON exercises (routine_id, name COLLATE NOCASE) WHERE archived_at IS NULL''',
    // 4. Every set lifted. RESTRICT: history is never deleted by accident.
    '''
CREATE TABLE workout_sets (
  id           INTEGER PRIMARY KEY AUTOINCREMENT,
  exercise_id  INTEGER NOT NULL
               REFERENCES exercises (id) ON UPDATE CASCADE ON DELETE RESTRICT,
  performed_on TEXT    NOT NULL CHECK (performed_on GLOB '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]'),
  set_number   INTEGER NOT NULL CHECK (set_number >= 1),
  weight_kg    REAL    NOT NULL CHECK (weight_kg BETWEEN 0 AND 1000),
  reps         INTEGER NOT NULL CHECK (reps BETWEEN 1 AND 200),
  created_at   TEXT    NOT NULL DEFAULT (datetime('now')),
  UNIQUE (exercise_id, performed_on, set_number)
)''',
    '''
CREATE INDEX workout_sets_date_idx ON workout_sets (performed_on)''',
  ];
}
