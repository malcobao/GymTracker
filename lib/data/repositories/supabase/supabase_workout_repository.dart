import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../domain/models/user_profile.dart' show dateOnly;
import '../../../domain/models/workout_set.dart';
import '../../../utils/result.dart';
import '../../errors/app_exception.dart';
import '../workout_repository.dart';

class SupabaseWorkoutRepository implements WorkoutRepository {
  SupabaseWorkoutRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<Result<List<WorkoutSet>>> listSetsOn(
    List<String> exerciseIds,
    DateTime day,
  ) async {
    if (exerciseIds.isEmpty) return const Result.ok([]);
    try {
      final rows = await _client
          .from('workout_sets')
          .select()
          .inFilter('exercise_id', exerciseIds)
          .eq('performed_on', dateOnly(day))
          .order('set_number', ascending: true);
      return Result.ok(rows.map(WorkoutSet.fromJson).toList());
    } catch (e) {
      return Result.error(mapError(e));
    }
  }

  @override
  Future<Result<List<WorkoutSet>>> listSetsForExercise(
    String exerciseId,
  ) async {
    try {
      final rows = await _client
          .from('workout_sets')
          .select()
          .eq('exercise_id', exerciseId)
          .order('performed_on', ascending: true)
          .order('set_number', ascending: true);
      return Result.ok(rows.map(WorkoutSet.fromJson).toList());
    } catch (e) {
      return Result.error(mapError(e));
    }
  }

  @override
  Future<Result<WorkoutSet>> logSet({
    required String exerciseId,
    required DateTime day,
    required double weightKg,
    required int reps,
  }) async {
    try {
      final last = await _client
          .from('workout_sets')
          .select('set_number')
          .eq('exercise_id', exerciseId)
          .eq('performed_on', dateOnly(day))
          .order('set_number', ascending: false)
          .limit(1)
          .maybeSingle();
      final draft = WorkoutSet(
        id: '',
        exerciseId: exerciseId,
        performedOn: day,
        setNumber: ((last?['set_number'] as int?) ?? 0) + 1,
        weightKg: weightKg,
        reps: reps,
      );
      final row = await _client
          .from('workout_sets')
          .insert(draft.toInsertJson())
          .select()
          .single();
      return Result.ok(WorkoutSet.fromJson(row));
    } catch (e) {
      return Result.error(
        mapError(
          e,
          duplicateMessage: 'That set was just saved twice. Refresh the list.',
        ),
      );
    }
  }

  @override
  Future<Result<void>> deleteSet(String setId) async {
    try {
      await _client.from('workout_sets').delete().eq('id', setId);
      return const Result.ok(null);
    } catch (e) {
      return Result.error(mapError(e));
    }
  }
}
