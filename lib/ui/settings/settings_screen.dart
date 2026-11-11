import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../data/local/database_changes.dart';
import '../../data/repositories/profile_repository.dart';
import '../../data/repositories/workout_repository.dart';
import '../../domain/models/enums.dart';
import '../../routing/routes.dart';
import '../core/app_theme.dart';
import '../core/labels.dart';
import '../core/view_models/session_controller.dart';
import '../core/view_models/settings_controller.dart';
import '../core/widgets/dialogs.dart';
import '../core/widgets/state_views.dart';
import 'language_picker.dart';
import 'settings_view_model.dart';

/// Tab 4: profile, language, appearance, weight unit and the local database.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final vm = SettingsViewModel(
    data: context.read<DataRepository>(),
    profiles: context.read<ProfileRepository>(),
    session: context.read<SessionController>(),
  )..loadCounts();

  /// Reloads after any write to the database, even one made on another tab.
  late final DatabaseChanges _changes = context.read<DatabaseChanges>();

  @override
  void initState() {
    super.initState();
    _changes.addListener(vm.loadCounts);
  }

  @override
  void dispose() {
    _changes.removeListener(vm.loadCounts);
    vm.dispose();
    super.dispose();
  }

  Future<void> _loadSample() async {
    final l10n = context.l10n;
    final spanish = Localizations.localeOf(context).languageCode == 'es';
    final error = await vm.loadSampleData(spanish: spanish);
    if (mounted) {
      showMessage(
        context,
        error == null ? l10n.sampleDataLoaded : l10n.error(error),
      );
    }
  }

  Future<void> _deleteAll() async {
    final l10n = context.l10n;
    final ok = await confirmAction(
      context,
      title: l10n.deleteAllData,
      message: l10n.deleteAllDataMessage,
      confirmLabel: l10n.delete,
      destructive: true,
    );
    if (!ok || !mounted) return;
    final error = await vm.deleteAllData();
    if (mounted && error != null) showMessage(context, l10n.error(error));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final settings = context.watch<SettingsController>();
    final session = context.watch<SessionController>();
    final profile = session.profile;
    final theme = Theme.of(context);
    final sections = <Widget>[
      // ---- profile ----
      if (profile != null)
        Card(
          child: ListTile(
            contentPadding: const EdgeInsets.all(AppTheme.space4),
            leading: CircleAvatar(
              radius: 26,
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              child: Text(
                profile.displayName.characters.first.toUpperCase(),
                style: const TextStyle(fontSize: 22),
              ),
            ),
            title: Text(
              profile.displayName,
              style: theme.textTheme.titleMedium,
            ),
            subtitle: Text(
              '${l10n.ageAndBmi(profile.ageOn(DateTime.now()), context.fmt.number(profile.bmi))}\n'
              '${l10n.goal(profile.goal)} · ${l10n.level(profile.experienceLevel)}',
            ),
            isThreeLine: true,
            trailing: IconButton.filledTonal(
              tooltip: l10n.editProfile,
              icon: const Icon(Icons.edit),
              onPressed: () => context.push(Routes.profile),
            ),
          ),
        ),
      // ---- appearance ----
      _Section(
        title: l10n.appearance,
        icon: Icons.palette_outlined,
        children: [
          _Labeled(
            label: l10n.language,
            child: SegmentedButton<String?>(
              showSelectedIcon: false,
              segments: [
                for (final code in [
                  null,
                  ...SettingsController.supportedLanguages,
                ])
                  ButtonSegment(
                    value: code,
                    label: Text(languageName(code, l10n)),
                  ),
              ],
              selected: {settings.languageCode},
              onSelectionChanged: (s) => settings.setLanguage(s.first),
            ),
          ),
          _Labeled(
            label: l10n.theme,
            child: SegmentedButton<ThemeMode>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: ThemeMode.system,
                  icon: const Icon(Icons.brightness_auto),
                  label: Text(l10n.themeSystem),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  icon: const Icon(Icons.light_mode),
                  label: Text(l10n.themeLight),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  icon: const Icon(Icons.dark_mode),
                  label: Text(l10n.themeDark),
                ),
              ],
              selected: {settings.themeMode},
              onSelectionChanged: (s) => settings.setThemeMode(s.first),
            ),
          ),
          _Labeled(
            label: l10n.accentColor,
            child: Wrap(
              spacing: AppTheme.space3,
              children: [
                for (var i = 0; i < AppTheme.accents.length; i++)
                  _ColorDot(
                    color: AppTheme.accents[i],
                    selected: settings.accentIndex == i,
                    onTap: () => settings.setAccent(i),
                  ),
              ],
            ),
          ),
          if (profile != null)
            _Labeled(
              label: l10n.weightUnit,
              child: SegmentedButton<WeightUnit>(
                segments: const [
                  ButtonSegment(value: WeightUnit.kg, label: Text('kg')),
                  ButtonSegment(value: WeightUnit.lb, label: Text('lb')),
                ],
                selected: {profile.weightUnit},
                onSelectionChanged: (s) async {
                  final error = await vm.setUnit(s.first);
                  if (context.mounted && error != null) {
                    showMessage(context, l10n.error(error));
                  }
                },
              ),
            ),
        ],
      ),
      // ---- database ----
      ListenableBuilder(
        listenable: vm,
        builder: (context, _) {
          final counts = vm.counts;
          Widget table(String label, int? count, IconData icon) => ListTile(
            dense: true,
            leading: Icon(icon, color: theme.colorScheme.primary),
            title: Text(label),
            trailing: count == null
                ? null
                : AnimatedNumber(
                    value: count.toDouble(),
                    format: (v) => l10n.tableRows(v.round()),
                    style: theme.textTheme.labelLarge,
                  ),
          );
          return _Section(
            title: l10n.databaseSection,
            icon: Icons.storage_outlined,
            children: [
              Text(l10n.databaseInfo, style: theme.textTheme.bodySmall),
              table(l10n.tableProfile, counts?.profile, Icons.person_outline),
              table(l10n.tableRoutines, counts?.routines, Icons.list_alt),
              table(
                l10n.tableExercises,
                counts?.exercises,
                Icons.fitness_center,
              ),
              table(l10n.tableSets, counts?.sets, Icons.repeat),
              const SizedBox(height: AppTheme.space2),
              Text(l10n.loadSampleDataInfo, style: theme.textTheme.bodySmall),
              const SizedBox(height: AppTheme.space2),
              Wrap(
                spacing: AppTheme.space2,
                runSpacing: AppTheme.space2,
                children: [
                  FilledButton.tonalIcon(
                    onPressed: vm.busy ? null : _loadSample,
                    icon: const Icon(Icons.auto_awesome),
                    label: Text(l10n.loadSampleData),
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                    ),
                    onPressed: vm.busy ? null : _deleteAll,
                    icon: const Icon(Icons.delete_forever_outlined),
                    label: Text(l10n.deleteAllData),
                  ),
                ],
              ),
            ],
          );
        },
      ),
      _Section(
        title: l10n.about,
        icon: Icons.info_outline,
        children: [Text(l10n.aboutText)],
      ),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navSettings)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.space2),
        children: [
          for (final (i, s) in sections.indexed)
            FadeSlideIn(index: i, child: s),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary),
                const SizedBox(width: AppTheme.space2),
                Text(title, style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: AppTheme.space3),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _Labeled extends StatelessWidget {
  const _Labeled({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppTheme.space4),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: AppTheme.space2),
        SingleChildScrollView(scrollDirection: Axis.horizontal, child: child),
      ],
    ),
  );
}

/// A colour swatch that grows and shows a check when selected.
class _ColorDot extends StatelessWidget {
  const _ColorDot({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: AppTheme.medium,
      curve: Curves.easeOutBack,
      width: selected ? 44 : 36,
      height: selected ? 44 : 36,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface,
          width: selected ? 3 : 0,
        ),
        boxShadow: selected
            ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 10)]
            : null,
      ),
      child: AnimatedOpacity(
        duration: AppTheme.fast,
        opacity: selected ? 1 : 0,
        child: const Icon(Icons.check, color: Colors.white),
      ),
    ),
  );
}
