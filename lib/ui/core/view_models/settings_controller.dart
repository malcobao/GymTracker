import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_theme.dart';

/// App preferences (language, theme, accent colour). They are device
/// settings, not training data, so they live in shared_preferences and the
/// database keeps exactly its four tables.
class SettingsController extends ChangeNotifier {
  SettingsController(this._prefs)
    : _languageCode = _prefs.getString(_languageKey),
      _themeMode = ThemeMode.values.firstWhere(
        (m) => m.name == _prefs.getString(_themeKey),
        orElse: () => ThemeMode.system,
      ),
      _accentIndex = (_prefs.getInt(_accentKey) ?? 0).clamp(
        0,
        AppTheme.accents.length - 1,
      );

  static const _languageKey = 'language';
  static const _themeKey = 'theme_mode';
  static const _accentKey = 'accent';

  /// Languages the app is translated to.
  static const supportedLanguages = ['en', 'es'];

  final SharedPreferences _prefs;
  String? _languageCode;
  ThemeMode _themeMode;
  int _accentIndex;

  /// 'en', 'es', or null to follow the device.
  String? get languageCode => _languageCode;
  Locale? get locale => _languageCode == null ? null : Locale(_languageCode!);
  ThemeMode get themeMode => _themeMode;
  int get accentIndex => _accentIndex;
  Color get accent => AppTheme.accents[_accentIndex];

  Future<void> setLanguage(String? code) async {
    assert(code == null || supportedLanguages.contains(code));
    _languageCode = code;
    notifyListeners();
    code == null
        ? await _prefs.remove(_languageKey)
        : await _prefs.setString(_languageKey, code);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    await _prefs.setString(_themeKey, mode.name);
  }

  Future<void> setAccent(int index) async {
    _accentIndex = index;
    notifyListeners();
    await _prefs.setInt(_accentKey, index);
  }
}
