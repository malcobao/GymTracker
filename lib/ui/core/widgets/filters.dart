import 'package:flutter/material.dart';

import '../../../data/repositories/routine_repository.dart';
import '../../../domain/models/enums.dart';
import '../../../domain/models/exercise.dart';
import '../../../domain/models/routine.dart';
import '../../../domain/models/user_profile.dart' show dayOf;
import '../../../domain/statistics.dart';
import '../../../utils/result.dart';
import '../app_theme.dart';
import '../labels.dart';

/// The period choices shared by statistics and reports.
enum PeriodPreset {
  last7Days,
  last30Days,
  last90Days,
  lastYear,
  allTime,
  custom,
}

/// What the user picked in a [FilterBar].
class FilterSelection {
  const FilterSelection({
    this.preset = PeriodPreset.last90Days,
    this.custom,
    this.routineId,
    this.exerciseId,
    this.muscleGroup,
  });

  final PeriodPreset preset;
  final DateTimeRange? custom;
  final int? routineId;
  final int? exerciseId;
  final MuscleGroup? muscleGroup;

  /// The database filter for this selection, with "today" = [today].
  RecordFilter toFilter(DateTime today) {
    final end = dayOf(today);
    DateTime back(int days) => DateTime(end.year, end.month, end.day - days);
    final (from, to) = switch (preset) {
      PeriodPreset.last7Days => (back(6), end),
      PeriodPreset.last30Days => (back(29), end),
      PeriodPreset.last90Days => (back(89), end),
      PeriodPreset.lastYear => (
        DateTime(end.year - 1, end.month, end.day + 1),
        end,
      ),
      PeriodPreset.allTime => (null, null),
      PeriodPreset.custom => (custom?.start, custom?.end),
    };
    return RecordFilter(
      from: from,
      to: to,
      routineId: routineId,
      exerciseId: exerciseId,
      muscleGroup: muscleGroup,
    );
  }

  FilterSelection copyWith({
    PeriodPreset? preset,
    DateTimeRange? Function()? custom,
    int? Function()? routineId,
    int? Function()? exerciseId,
    MuscleGroup? Function()? muscleGroup,
  }) => FilterSelection(
    preset: preset ?? this.preset,
    custom: custom == null ? this.custom : custom(),
    routineId: routineId == null ? this.routineId : routineId(),
    exerciseId: exerciseId == null ? this.exerciseId : exerciseId(),
    muscleGroup: muscleGroup == null ? this.muscleGroup : muscleGroup(),
  );
}

/// Routines and exercises the filters can choose from (archived included,
/// because their history still counts).
class Lookups {
  const Lookups({this.routines = const [], this.exercises = const []});

  final List<Routine> routines;
  final List<Exercise> exercises;

  static Future<Lookups> load(RoutineRepository repo) async {
    final active = await repo.listRoutines();
    final archived = await repo.listRoutines(archived: true);
    final exercises = await repo.listAllExercises();
    return Lookups(
      routines: [
        if (active case Ok(:final value)) ...value,
        if (archived case Ok(:final value)) ...value,
      ],
      exercises: switch (exercises) {
        Ok(:final value) => value,
        Error() => const [],
      },
    );
  }
}

/// A pill-shaped button showing "label: value" that opens a menu of
/// [options]. Used for every parameter on the statistics and report screens,
/// so all controls look and behave the same.
class ChoicePill<T> extends StatelessWidget {
  const ChoicePill({
    required this.label,
    required this.value,
    required this.options,
    required this.optionLabel,
    required this.onSelected,
    this.icon,
    super.key,
  });

  final String label;
  final T value;
  final List<T> options;
  final String Function(T) optionLabel;
  final ValueChanged<T> onSelected;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return PopupMenuButton<T>(
      tooltip: label,
      initialValue: value,
      onSelected: onSelected,
      itemBuilder: (context) => [
        for (final o in options)
          PopupMenuItem(
            value: o,
            child: Row(
              children: [
                Icon(
                  Icons.check,
                  size: 18,
                  color: o == value ? scheme.primary : Colors.transparent,
                ),
                const SizedBox(width: AppTheme.space2),
                Flexible(child: Text(optionLabel(o))),
              ],
            ),
          ),
      ],
      child: AnimatedContainer(
        duration: AppTheme.fast,
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.space3,
          vertical: AppTheme.space2,
        ),
        decoration: BoxDecoration(
          color: scheme.secondaryContainer.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: scheme.onSecondaryContainer),
              const SizedBox(width: AppTheme.space1),
            ],
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 220),
              child: Text(
                '$label: ${optionLabel(value)}',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: scheme.onSecondaryContainer),
              ),
            ),
            Icon(Icons.arrow_drop_down, color: scheme.onSecondaryContainer),
          ],
        ),
      ),
    );
  }
}

/// Period, routine, exercise and muscle-group pickers.
class FilterBar extends StatelessWidget {
  const FilterBar({
    required this.selection,
    required this.lookups,
    required this.onChanged,
    this.showExercise = true,
    super.key,
  });

  final FilterSelection selection;
  final Lookups lookups;
  final ValueChanged<FilterSelection> onChanged;
  final bool showExercise;

  Future<void> _pickPeriod(BuildContext context, PeriodPreset preset) async {
    if (preset != PeriodPreset.custom) {
      onChanged(selection.copyWith(preset: preset));
      return;
    }
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: now,
      initialDateRange:
          selection.custom ??
          DateTimeRange(
            start: DateTime(now.year, now.month - 1, now.day),
            end: now,
          ),
    );
    if (range != null) {
      onChanged(selection.copyWith(preset: preset, custom: () => range));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final fmt = context.fmt;
    final exercises = [
      for (final e in lookups.exercises)
        if (selection.routineId == null || e.routineId == selection.routineId)
          e,
    ];
    String periodLabel(PeriodPreset p) => switch (p) {
      PeriodPreset.last7Days => l10n.last7Days,
      PeriodPreset.last30Days => l10n.last30Days,
      PeriodPreset.last90Days => l10n.last90Days,
      PeriodPreset.lastYear => l10n.lastYear,
      PeriodPreset.allTime => l10n.allTime,
      PeriodPreset.custom =>
        selection.custom == null || p != selection.preset
            ? l10n.customRange
            : '${fmt.shortDate(selection.custom!.start)} – '
                  '${fmt.shortDate(selection.custom!.end)}',
    };
    return Wrap(
      spacing: AppTheme.space2,
      runSpacing: AppTheme.space2,
      children: [
        ChoicePill<PeriodPreset>(
          icon: Icons.date_range,
          label: l10n.period,
          value: selection.preset,
          options: PeriodPreset.values,
          optionLabel: periodLabel,
          onSelected: (p) => _pickPeriod(context, p),
        ),
        ChoicePill<int?>(
          icon: Icons.list_alt,
          label: l10n.routine,
          value: selection.routineId,
          options: [null, for (final r in lookups.routines) r.id],
          optionLabel: (id) => id == null
              ? l10n.allRoutines
              : _routineName(id, l10n.archivedTag),
          onSelected: (id) => onChanged(
            selection.copyWith(
              routineId: () => id,
              exerciseId: () => null, // may not belong to the new routine
            ),
          ),
        ),
        if (showExercise)
          ChoicePill<int?>(
            icon: Icons.fitness_center,
            label: l10n.exercise,
            value: exercises.any((e) => e.id == selection.exerciseId)
                ? selection.exerciseId
                : null,
            options: [null, for (final e in exercises) e.id],
            optionLabel: (id) {
              if (id == null) return l10n.allExercises;
              final e = exercises.firstWhere((e) => e.id == id);
              return selection.routineId == null
                  ? '${e.name} (${e.routineName})'
                  : e.name;
            },
            onSelected: (id) =>
                onChanged(selection.copyWith(exerciseId: () => id)),
          ),
        ChoicePill<MuscleGroup?>(
          icon: Icons.accessibility_new,
          label: l10n.muscleGroup,
          value: selection.muscleGroup,
          options: [null, ...MuscleGroup.values],
          optionLabel: (g) => g == null ? l10n.allMuscleGroups : l10n.muscle(g),
          onSelected: (g) =>
              onChanged(selection.copyWith(muscleGroup: () => g)),
        ),
      ],
    );
  }

  String _routineName(int id, String archivedTag) {
    final r = lookups.routines.firstWhere((r) => r.id == id);
    return r.archived ? '${r.name} ($archivedTag)' : r.name;
  }
}
