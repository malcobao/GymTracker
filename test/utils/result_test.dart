import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/utils/result.dart';

String describe(Result<int> result) => switch (result) {
  Ok(:final value) => 'ok $value',
  Error(:final error) => 'error $error',
};

void main() {
  test('ok carries its value', () {
    expect(describe(const Result.ok(42)), 'ok 42');
  });

  test('error carries its exception', () {
    expect(describe(Result.error(Exception('boom'))), 'error Exception: boom');
  });
}
