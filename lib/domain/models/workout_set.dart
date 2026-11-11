import 'user_profile.dart' show dateOnly;

/// One set actually lifted: [reps] repetitions with [weightKg] on [performedOn].
class WorkoutSet {
  const WorkoutSet({
    required this.id,
    required this.exerciseId,
    required this.performedOn,
    required this.setNumber,
    required this.weightKg,
    required this.reps,
  });

  factory WorkoutSet.fromJson(Map<String, dynamic> json) => WorkoutSet(
    id: json['id'] as String,
    exerciseId: json['exercise_id'] as String,
    performedOn: DateTime.parse(json['performed_on'] as String),
    setNumber: json['set_number'] as int,
    weightKg: (json['weight_kg'] as num).toDouble(),
    reps: json['reps'] as int,
  );

  final String id;
  final String exerciseId;
  final DateTime performedOn;
  final int setNumber;
  final double weightKg;
  final int reps;

  Map<String, dynamic> toInsertJson() => {
    'exercise_id': exerciseId,
    'performed_on': dateOnly(performedOn),
    'set_number': setNumber,
    'weight_kg': weightKg,
    'reps': reps,
  };
}
