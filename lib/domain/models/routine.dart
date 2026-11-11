/// A named training plan, such as "Push day" (table `routines`).
class Routine {
  const Routine({
    required this.id,
    required this.name,
    this.description,
    this.archived = false,
    this.exerciseCount = 0,
  });

  /// [row] may carry an extra `exercise_count` column from a JOIN.
  factory Routine.fromRow(Map<String, Object?> row) => Routine(
    id: row['id']! as int,
    name: row['name']! as String,
    description: row['description'] as String?,
    archived: row['archived_at'] != null,
    exerciseCount: (row['exercise_count'] as int?) ?? 0,
  );

  final int id;
  final String name;
  final String? description;

  /// Archived routines are hidden from the list but keep their history.
  final bool archived;

  /// Active exercises in the routine (calculated by the query).
  final int exerciseCount;
}
