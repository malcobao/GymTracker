import 'enums.dart';

/// Anything with a date, a weight and repetitions; lets the calculators work
/// on plain sets and on joined [SetRecord]s alike.
abstract interface class Lift {
  DateTime get date;
  double get weightKg;
  int get reps;
}

/// One set actually lifted: [reps] repetitions with [weightKg] on
/// [performedOn] (table `workout_sets`).
class WorkoutSet implements Lift {
  const WorkoutSet({
    required this.id,
    required this.exerciseId,
    required this.performedOn,
    required this.setNumber,
    required this.weightKg,
    required this.reps,
  });

  factory WorkoutSet.fromRow(Map<String, Object?> row) => WorkoutSet(
    id: row['id']! as int,
    exerciseId: row['exercise_id']! as int,
    performedOn: DateTime.parse(row['performed_on']! as String),
    setNumber: row['set_number']! as int,
    weightKg: (row['weight_kg']! as num).toDouble(),
    reps: row['reps']! as int,
  );

  final int id;
  final int exerciseId;
  final DateTime performedOn;

  @override
  DateTime get date => performedOn;

  final int setNumber;
  @override
  final double weightKg;
  @override
  final int reps;

  /// Weight × reps.
  double get volumeKg => weightKg * reps;
}

/// A logged set together with its exercise and routine: one row of the
/// `workout_sets ⋈ exercises ⋈ routines` join that statistics and reports use.
class SetRecord implements Lift {
  const SetRecord({
    required this.setId,
    required this.date,
    required this.setNumber,
    required this.weightKg,
    required this.reps,
    required this.exerciseId,
    required this.exerciseName,
    required this.routineId,
    required this.routineName,
    this.muscleGroup,
  });

  factory SetRecord.fromRow(Map<String, Object?> row) => SetRecord(
    setId: row['set_id']! as int,
    date: DateTime.parse(row['performed_on']! as String),
    setNumber: row['set_number']! as int,
    weightKg: (row['weight_kg']! as num).toDouble(),
    reps: row['reps']! as int,
    exerciseId: row['exercise_id']! as int,
    exerciseName: row['exercise_name']! as String,
    muscleGroup: MuscleGroup.fromDb(row['muscle_group'] as String?),
    routineId: row['routine_id']! as int,
    routineName: row['routine_name']! as String,
  );

  final int setId;
  @override
  final DateTime date;
  final int setNumber;
  @override
  final double weightKg;
  @override
  final int reps;
  final int exerciseId;
  final String exerciseName;
  final MuscleGroup? muscleGroup;
  final int routineId;
  final String routineName;

  double get volumeKg => weightKg * reps;
}
