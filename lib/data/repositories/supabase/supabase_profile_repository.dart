import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../domain/models/user_profile.dart';
import '../../../utils/result.dart';
import '../../errors/app_exception.dart';
import '../profile_repository.dart';

class SupabaseProfileRepository implements ProfileRepository {
  SupabaseProfileRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<Result<UserProfile?>> getMyProfile() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return const Result.error(NotSignedInException());
    try {
      final row = await _client
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();
      return Result.ok(row == null ? null : UserProfile.fromJson(row));
    } catch (e) {
      return Result.error(mapError(e));
    }
  }

  @override
  Future<Result<UserProfile>> saveProfile(UserProfile profile) async {
    try {
      final row = await _client
          .from('users')
          .upsert({
            ...profile.toJson(),
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .select()
          .single();
      return Result.ok(UserProfile.fromJson(row));
    } catch (e) {
      return Result.error(mapError(e));
    }
  }
}
