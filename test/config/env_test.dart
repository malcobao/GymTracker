import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/config/env.dart';

void main() {
  test('valid when an https URL and a key are given', () {
    const env = Env(
      supabaseUrl: 'https://example.supabase.co',
      supabasePublishableKey: 'sb_publishable_test',
    );
    expect(env.isValid, isTrue);
    expect(env.problems, isEmpty);
  });

  test('reports every missing setting', () {
    const env = Env(supabaseUrl: '', supabasePublishableKey: '');
    expect(env.problems, ['SUPABASE_URL', 'SUPABASE_PUBLISHABLE_KEY']);
  });

  test('rejects a non-https URL', () {
    const env = Env(
      supabaseUrl: 'http://example.supabase.co',
      supabasePublishableKey: 'sb_publishable_test',
    );
    expect(env.problems, ['SUPABASE_URL']);
  });
}
