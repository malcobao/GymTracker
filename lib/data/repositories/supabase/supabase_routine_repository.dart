import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../domain/models/exercise.dart';
import '../../../domain/models/routine.dart';
import '../../../utils/result.dart';
import '../../errors/app_exception.dart';
import '../routine_repository.dart';

class SupabaseRoutineRepository implements RoutineRepository {
  SupabaseRoutineRepository(this._client);

  final SupabaseClient _client;

  static const _duplicateRoutine =
      'You already have a routine with that name (it may be archived).';
  static const _duplicateExercise =
      'This routine already has an exercise with that name (it may be archived).';

  String get _now => DateTime.now().toUtc().toIso8601String();

  @override
  Future<Result<List<Routine>>> listRoutines() async {
    try {
      // RLS already limits rows to the signed-in user.
      final rows = await _client
          .from('routines')
          .select()
          .isFilter('archived_at', null)
          .order('name', ascending: true);
      return Result.ok(rows.map(Routine.fromJson).toList());
    } catch (e) {
      return Result.error(mapError(e));
    }
  }

  @override
  Future<Result<Routine>> createRoutine(
    String name, {
    String? description,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return const Result.error(NotSignedInException());
    try {
      final row = await _client
          .from('routines')
          .insert({
            'user_id': userId,
            'name': name.trim(),
            'description': (description?.trim().isEmpty ?? true)
                ? null
                : description!.trim(),
          })
          .select()
          .single();
      return Result.ok(Routine.fromJson(row));
    } catch (e) {
      return Result.error(mapError(e, duplicateMessage: _duplicateRoutine));
    }
  }

  @override
  Future<Result<void>> renameRoutine(String routineId, String name) async {
    try {
      await _client
          .from('routines')
          .update({'name': name.trim(), 'updated_at': _now})
          .eq('id', routineId);
      return const Result.ok(null);
    } catch (e) {
      return Result.error(mapError(e, duplicateMessage: _duplicateRoutine));
    }
  }

  @override
  Future<Result<void>> archiveRoutine(String routineId) async {
    try {
      await _client
          .from('routines')
          .update({'archived_at': _now, 'updated_at': _now})
          .eq('id', routineId);
      return const Result.ok(null);
    } catch (e) {
      return Result.error(mapError(e));
    }
  }

  @override
  Future<Result<List<Exercise>>> listExercises(String routineId) async {
    try {
      final rows = await _client
          .from('exercises')
          .select()
          .eq('routine_id', routineId)
          .isFilter('archived_at', null)
          .order('position', ascending: true);
      return Result.ok(rows.map(Exercise.fromJson).toList());
    } catch (e) {
      return Result.error(mapError(e));
    }
  }

  @override
  Future<Result<Exercise>> addExercise(
    String routineId,
    ExerciseDraft draft,
  ) async {
    try {
      // Archived exercises keep their position, so take the highest of all.
      final last = await _client
          .from('exercises')
          .select('position')
          .eq('routine_id', routineId)
          .order('position', ascending: false)
          .limit(1)
          .maybeSingle();
      final nextPosition = ((last?['position'] as int?) ?? 0) + 1;
      final row = await _client
          .from('exercises')
          .insert({
            ...draft.toJson(),
            'routine_id': routineId,
            'position': nextPosition,
          })
          .select()
          .single();
      return Result.ok(Exercise.fromJson(row));
    } catch (e) {
      return Result.error(mapError(e, duplicateMessage: _duplicateExercise));
    }
  }

  @override
  Future<Result<void>> updateExercise(
    String exerciseId,
    ExerciseDraft draft,
  ) async {
    try {
      await _client
          .from('exercises')
          .update({...draft.toJson(), 'updated_at': _now})
          .eq('id', exerciseId);
      return const Result.ok(null);
    } catch (e) {
      return Result.error(mapError(e, duplicateMessage: _duplicateExercise));
    }
  }

  @override
  Future<Result<void>> archiveExercise(String exerciseId) async {
    try {
      await _client
          .from('exercises')
          .update({'archived_at': _now, 'updated_at': _now})
          .eq('id', exerciseId);
      return const Result.ok(null);
    } catch (e) {
      return Result.error(mapError(e));
    }
  }

  @override
  Future<Result<void>> reorderExercises(
    String routineId,
    List<String> exerciseIds,
  ) async {
    try {
      // Archived exercises keep a position too. Appending them after the
      // active ones renumbers every row, so no two can end up sharing one.
      final archived = await _client
          .from('exercises')
          .select('id')
          .eq('routine_id', routineId)
          .not('archived_at', 'is', null)
          .order('position', ascending: true);
      await _client.rpc(
        'reorder_exercises',
        params: {
          'p_routine_id': routineId,
          'p_exercise_ids': [
            ...exerciseIds,
            ...archived.map((row) => row['id'] as String),
          ],
        },
      );
      return const Result.ok(null);
    } catch (e) {
      return Result.error(mapError(e));
    }
  }
}
