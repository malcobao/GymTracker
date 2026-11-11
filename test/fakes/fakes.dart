import 'package:gym_tracker/data/errors/app_exception.dart';
import 'package:gym_tracker/data/repositories/auth_repository.dart';
import 'package:gym_tracker/data/repositories/profile_repository.dart';
import 'package:gym_tracker/data/repositories/routine_repository.dart';
import 'package:gym_tracker/data/repositories/workout_repository.dart';
import 'package:gym_tracker/domain/models/enums.dart';
import 'package:gym_tracker/domain/models/exercise.dart';
import 'package:gym_tracker/domain/models/routine.dart';
import 'package:gym_tracker/domain/models/user_profile.dart';
import 'package:gym_tracker/domain/models/workout_set.dart';
import 'package:gym_tracker/utils/result.dart';

/// In-memory stand-ins for the Supabase repositories. They follow the same
/// rules as the database (unique names, ordering, set numbering) so view
/// models and screens can be tested without a network.

const testUserId = 'user-1';

UserProfile sampleProfile({WeightUnit unit = WeightUnit.kg}) => UserProfile(
  id: testUserId,
  displayName: 'Cristian',
  birthDate: DateTime(2003, 4, 15),
  sex: Sex.male,
  heightCm: 178,
  bodyWeightKg: 75.5,
  experienceLevel: ExperienceLevel.beginner,
  goal: Goal.muscleGain,
  weightUnit: unit,
);

class FakeAuthRepository extends AuthRepository {
  FakeAuthRepository({this._signedIn = false});

  bool _signedIn;
  String password = 'password123';
  bool requireEmailConfirmation = false;

  @override
  bool get isSignedIn => _signedIn;

  @override
  String? get userId => _signedIn ? testUserId : null;

  @override
  Future<Result<void>> signIn(String email, String password) async {
    if (password != this.password) {
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

class FakeProfileRepository implements ProfileRepository {
  FakeProfileRepository({this.profile});

  UserProfile? profile;
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

class FakeRoutineRepository implements RoutineRepository {
  final routines = <Routine>[];
  final archivedRoutineIds = <String>{};
  final exercises = <Exercise>[];
  final archivedExerciseIds = <String>{};
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

class FakeWorkoutRepository implements WorkoutRepository {
  final sets = <WorkoutSet>[];
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
