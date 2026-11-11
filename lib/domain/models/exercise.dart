import 'enums.dart';

/// One exercise inside one routine, in the order given by [position]
/// (table `exercises`).
class Exercise {
  const Exercise({
    required this.id,
    required this.routineId,
    required this.name,
    required this.position,
    this.muscleGroup,
    this.targetSets,
    this.targetReps,
    this.archived = false,
    this.routineName,
  });

  /// [row] may carry an extra `routine_name` column from a JOIN.
  factory Exercise.fromRow(Map<String, Object?> row) => Exercise(
    id: row['id']! as int,
    routineId: row['routine_id']! as int,
    name: row['name']! as String,
    position: row['position']! as int,
    muscleGroup: MuscleGroup.fromDb(row['muscle_group'] as String?),
    targetSets: row['target_sets'] as int?,
    targetReps: row['target_reps'] as int?,
    archived: row['archived_at'] != null,
    routineName: row['routine_name'] as String?,
  );

  final int id;
  final int routineId;
  final String name;
  final int position;
  final MuscleGroup? muscleGroup;
  final int? targetSets;
  final int? targetReps;
  final bool archived;

  /// Name of the routine, filled only by queries that join `routines`.
  final String? routineName;
}
