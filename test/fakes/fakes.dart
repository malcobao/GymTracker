import 'package:gym_tracker/data/repositories/memory/in_memory_repositories.dart';
import 'package:gym_tracker/domain/models/enums.dart';
import 'package:gym_tracker/domain/models/user_profile.dart';

export 'package:gym_tracker/data/repositories/memory/in_memory_repositories.dart';

/// Test doubles: the app's in-memory repositories, with a fixed password so
/// tests can check the wrong-password path.

const testUserId = demoUserId;

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

class FakeAuthRepository extends InMemoryAuthRepository {
  FakeAuthRepository({super.signedIn}) : super(password: 'password123');
}

typedef FakeProfileRepository = InMemoryProfileRepository;
typedef FakeRoutineRepository = InMemoryRoutineRepository;
typedef FakeWorkoutRepository = InMemoryWorkoutRepository;
