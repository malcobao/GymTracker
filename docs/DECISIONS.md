# Decisions

The full design document (ER diagram, data dictionary, comparisons, sources) is
kept in the project's design doc. This file records each approved decision so the
code stays consistent with it.

| Date | Decision | Why |
| --- | --- | --- |
| 2026-10-28 | Exactly four tables: `users`, `routines`, `exercises`, `workout_sets` | Course rule |
| 2026-10-28 | Exercises belong to one routine (no shared catalog); no session table | Fits four tables; cost: same exercise in two routines = two rows |
| 2026-10-28 | Body weight is one column on `users`, no history | Only entered at registration and edited later |
| 2026-10-28 | Archive (`archived_at`) instead of delete for routines/exercises | Keeps logged history |
| 2026-10-28 | All weights stored in kg; `weight_unit` is display only | Avoid mixed units |
| 2026-11-04 | Supabase (hosted PostgreSQL + Auth) | Relational tables, built-in auth, free plan |
| 2026-11-04 | `users.id` = `auth.users.id`; email lives only in `auth.users` | No duplicated data |
| 2026-11-04 | Row Level Security on all four tables | Each user reaches only their own rows, enforced server-side |
| 2026-11-05 | No separate backend; app uses Supabase directly | Rules are ownership + validation, both enforced in the database |
| 2026-11-05 | `reorder_exercises()` database function | Reorder in one statement despite the unique position rule |
| 2026-11-05 | Progress computed in Dart, not a SQL view | Small data volume; avoids a fifth database object that could count as a table |
| 2026-11-05 | MVVM per Flutter's architecture guide: `ChangeNotifier`, `provider`, `go_router` | Official guidance, few dependencies |
| 2026-11-11 | Archived routines/exercises keep their name | Logged history stays readable; re-using an archived name is rejected with a clear message |
| 2026-11-11 | Reorder sends active exercises first, archived ones after | Archived rows keep a position; renumbering all of them avoids unique-position clashes |
| 2026-11-11 | Progress chart drawn with `CustomPainter` | No extra chart dependency for one simple line |
| 2026-11-11 | Weights typed in the user's unit, stored in kg with 2 decimals | Matches `NUMERIC(6,2)` columns |
| 2026-11-11 | Demo mode with in-memory repositories when no Supabase settings are given | Cristian asked to run the app without Supabase; the same in-memory repositories back the tests |
