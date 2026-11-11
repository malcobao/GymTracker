import 'enums.dart';

/// One exercise inside one routine, in the order given by [position].
class Exercise {
  const Exercise({
    required this.id,
    required this.routineId,
    required this.name,
    required this.position,
    this.muscleGroup,
    this.targetSets,
    this.targetReps,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
    id: json['id'] as String,
    routineId: json['routine_id'] as String,
    name: json['name'] as String,
    position: json['position'] as int,
    muscleGroup: MuscleGroup.fromDb(json['muscle_group'] as String?),
    targetSets: json['target_sets'] as int?,
    targetReps: json['target_reps'] as int?,
  );

  final String id;
  final String routineId;
  final String name;
  final int position;
  final MuscleGroup? muscleGroup;
  final int? targetSets;
  final int? targetReps;

  /// "3 × 8", "3 sets", "8 reps" or null when no target is set.
  String? get targetLabel => switch ((targetSets, targetReps)) {
    (final int s, final int r) => '$s × $r',
    (final int s, null) => '$s sets',
    (null, final int r) => '$r reps',
    (null, null) => null,
  };
}
