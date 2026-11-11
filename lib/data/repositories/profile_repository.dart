import '../../domain/models/user_profile.dart';
import '../../utils/result.dart';

/// CRUD of the `profile` table (one row).
abstract class ProfileRepository {
  /// Read: the profile, or `Ok(null)` before onboarding.
  Future<Result<UserProfile?>> getProfile();

  /// Create or Update (the table has at most one row).
  Future<Result<UserProfile>> saveProfile(UserProfile profile);
}
