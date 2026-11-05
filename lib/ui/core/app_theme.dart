import 'package:flutter/material.dart';

/// Material 3 themes for light and dark mode, derived from one seed colour.
abstract final class AppTheme {
  static const _seed = Color(0xFF2E7D32);

  static final light = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: _seed),
  );

  static final dark = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.dark,
    ),
  );
}
