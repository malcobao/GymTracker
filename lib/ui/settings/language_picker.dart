import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/labels.dart';
import '../core/view_models/settings_controller.dart';

/// Name of a language in that same language, as language pickers usually do.
String languageName(String? code, AppLocalizations l10n) => switch (code) {
  'en' => 'English',
  'es' => 'Español',
  _ => l10n.languageSystem,
};

/// App-bar button to switch language (used on the onboarding screen, before
/// Settings is reachable).
class LanguageMenuButton extends StatelessWidget {
  const LanguageMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();
    final l10n = context.l10n;
    return PopupMenuButton<String?>(
      tooltip: l10n.language,
      icon: const Icon(Icons.translate),
      initialValue: settings.languageCode,
      onSelected: settings.setLanguage,
      itemBuilder: (context) => [
        for (final code in [null, ...SettingsController.supportedLanguages])
          PopupMenuItem(value: code, child: Text(languageName(code, l10n))),
      ],
    );
  }
}
