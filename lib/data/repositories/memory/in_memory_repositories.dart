import 'package:flutter/foundation.dart';

import '../../../domain/models/exercise.dart';
import '../../../domain/models/routine.dart';
import '../../../domain/models/user_profile.dart';
import '../../../domain/models/workout_set.dart';
import '../../../utils/result.dart';
import '../../errors/app_exception.dart';
import '../auth_repository.dart';
import '../profile_repository.dart';
import '../routine_repository.dart';
import '../workout_repository.dart';

/// In-memory repositories. They follow the same rules as the database
/// (unique names, ordering, set numbering) and back two things:
/// the offline demo mode (app started without Supabase settings) and the
/// tests. Data lives only while the app runs.

const demoUserId = 'demo-user';

class InMemoryAuthRepository extends AuthRepository {
  InMemoryAuthRepository({this._signedIn = false, this.password});

  bool _signedIn;

  /// When set, only this password signs in; when null any password does.
  String? password;
  bool requireEmailConfirmation = false;

  @override
  bool get isSignedIn => _signedIn;

  @override
  String? get userId => _signedIn ? demoUserId : null;

  @override
  Future<Result<void>> signIn(String email, String password) async {
    if (this.password != null && password != this.password) {
      return const Result.error(
        AuthFailedException('Wrong email or password.'),
      );
    }
    _signedIn = true;
    notifyListeners();
    return const Result.ok(null);
  }

  @override
  Future<Result<SignUpOutcome>> signUp(String email, String password) async {
    if (requireEmailConfirmation) {
      return const Result.ok(SignUpOutcome.confirmationEmailSent);
    }
    _signedIn = true;
    notifyListeners();
    return const Result.ok(SignUpOutcome.signedIn);
  }

  @override
  Future<Result<void>> signOut() async {
    _signedIn = false;
    notifyListeners();
    return const Result.ok(null);
  }

  @override
  Future<Result<void>> sendPasswordReset(String email) async =>
      const Result.ok(null);
}

class InMemoryProfileRepository implements ProfileRepository {
  InMemoryProfileRepository({this.profile});

  UserProfile? profile;
  @visibleForTesting
  Exception? failure;

  @override
  Future<Result<UserProfile?>> getMyProfile() async =>
      failure != null ? Result.error(failure!) : Result.ok(profile);

  @override
  Future<Result<UserProfile>> saveProfile(UserProfile profile) async {
    this.profile = profile;
    return Result.ok(profile);
  }
}

class InMemoryRoutineRepository implements RoutineRepository {
  final routines = <Routine>[];
  final archivedRoutineIds = <String>{};
  final exercises = <Exercise>[];
  final archivedExerciseIds = <String>{};
  @visibleForTesting
  Exception? failure;
  var _nextId = 1;

  String _id(String prefix) => '$prefix-${_nextId++}';

  @override
  Future<Result<List<Routine>>> listRoutines() async {
    if (failure != null) return Result.error(failure!);
    final active = [
      for (final r in routines)
        if (!archivedRoutineIds.contains(r.id)) r,
    ]..sort((a, b) => a.name.compareTo(b.name));
    return Result.ok(active);
  }

  @override
  Future<Result<Routine>> createRoutine(
    String name, {
    String? description,
  }) async {
    if (routines.any((r) => r.name == name.trim())) {
      return const Result.error(
        DuplicateException('You already have a routine with that name.'),
      );
    }
    final routine = Routine(
      id: _id('routine'),
      name: name.trim(),
      description: description,
    );
    routines.add(routine);
    return Result.ok(routine);
  }

  @override
  Future<Result<void>> renameRoutine(String routineId, String name) async {
    final i = routines.indexWhere((r) => r.id == routineId);
    routines[i] = Routine(id: routineId, name: name, description: null);
    return const Result.ok(null);
  }

  @override
  Future<Result<void>> archiveRoutine(String routineId) async {
    archivedRoutineIds.add(routineId);
    return const Result.ok(null);
  }

  @override
  Future<Result<List<Exercise>>> listExercises(String routineId) async {
    if (failure != null) return Result.error(failure!);
    return Result.ok(
      [
        for (final e in exercises)
          if (e.routineId == routineId && !archivedExerciseIds.contains(e.id))
            e,
      ]..sort((a, b) => a.position.compareTo(b.position)),
    );
  }

  @override
  Future<Result<Exercise>> addExercise(
    String routineId,
    ExerciseDraft draft,
  ) async {
    final inRoutine = exercises.where((e) => e.routineId == routineId);
    if (inRoutine.any((e) => e.name == draft.name)) {
      return const Result.error(DuplicateException());
    }
    final exercise = Exercise(
      id: _id('exercise'),
      routineId: routineId,
      name: draft.name,
      position: inRoutine.length + 1,
      muscleGroup: draft.muscleGroup,
      targetSets: draft.targetSets,
      targetReps: draft.targetReps,
    );
    exercises.add(exercise);
    return Result.ok(exercise);
  }

  @override
  Future<Result<void>> updateExercise(
    String exerciseId,
    ExerciseDraft draft,
  ) async {
    final i = exercises.indexWhere((e) => e.id == exerciseId);
    final old = exercises[i];
    exercises[i] = Exercise(
      id: old.id,
      routineId: old.routineId,
      name: draft.name,
      position: old.position,
      muscleGroup: draft.muscleGroup,
      targetSets: draft.targetSets,
      targetReps: draft.targetReps,
    );
    return const Result.ok(null);
  }

  @override
  Future<Result<void>> archiveExercise(String exerciseId) async {
    archivedExerciseIds.add(exerciseId);
    return const Result.ok(null);
  }

  @visibleForTesting
  List<String>? lastReorder;

  @override
  Future<Result<void>> reorderExercises(
    String routineId,
    List<String> exerciseIds,
  ) async {
    if (failure != null) return Result.error(failure!);
    lastReorder = exerciseIds;
    for (var i = 0; i < exerciseIds.length; i++) {
      final j = exercises.indexWhere((e) => e.id == exerciseIds[i]);
      final e = exercises[j];
      exercises[j] = Exercise(
        id: e.id,
        routineId: e.routineId,
        name: e.name,
        position: i + 1,
        muscleGroup: e.muscleGroup,
        targetSets: e.targetSets,
        targetReps: e.targetReps,
      );
    }
    return const Result.ok(null);
  }
}

class InMemoryWorkoutRepository implements WorkoutRepository {
  final sets = <WorkoutSet>[];
  @visibleForTesting
  Exception? failure;
  var _nextId = 1;

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Future<Result<List<WorkoutSet>>> listSetsOn(
    List<String> exerciseIds,
    DateTime day,
  ) async {
    if (failure != null) return Result.error(failure!);
    return Result.ok([
      for (final s in sets)
        if (exerciseIds.contains(s.exerciseId) && _sameDay(s.performedOn, day))
          s,
    ]);
  }

  @override
  Future<Result<List<WorkoutSet>>> listSetsForExercise(
    String exerciseId,
  ) async {
    if (failure != null) return Result.error(failure!);
    return Result.ok([
      for (final s in sets)
        if (s.exerciseId == exerciseId) s,
    ]);
  }

  @override
  Future<Result<WorkoutSet>> logSet({
    required String exerciseId,
    required DateTime day,
    required double weightKg,
    required int reps,
  }) async {
    if (failure != null) return Result.error(failure!);
    final previous = sets.where(
      (s) => s.exerciseId == exerciseId && _sameDay(s.performedOn, day),
    );
    final set = WorkoutSet(
      id: 'set-${_nextId++}',
      exerciseId: exerciseId,
      performedOn: day,
      setNumber: previous.length + 1,
      weightKg: weightKg,
      reps: reps,
    );
    sets.add(set);
    return Result.ok(set);
  }

  @override
  Future<Result<void>> deleteSet(String setId) async {
    sets.removeWhere((s) => s.id == setId);
    return const Result.ok(null);
  }
}
