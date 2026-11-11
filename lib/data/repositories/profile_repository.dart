import '../../domain/models/user_profile.dart';
import '../../utils/result.dart';

abstract class ProfileRepository {
  /// The signed-in user's profile, or `Ok(null)` if onboarding is not done.
  Future<Result<UserProfile?>> getMyProfile();

  /// Creates or updates the profile (one row per user).
  Future<Result<UserProfile>> saveProfile(UserProfile profile);
}
