import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/repositories/routine_repository.dart';
import '../../data/repositories/workout_repository.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/workout_set.dart';
import '../../domain/validation.dart';
import '../../utils/result.dart';
import '../../utils/units.dart';
import '../core/app_theme.dart';
import '../core/labels.dart';
import '../core/view_models/session_controller.dart';
import '../core/widgets/dialogs.dart';
import '../core/widgets/state_views.dart';
import 'workout_view_model.dart';

/// Logs today's sets of one routine.
class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({required this.routineId, this.day, super.key});

  final int routineId;

  /// The day to log; today by default (tests pass a fixed day).
  final DateTime? day;

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  late final vm = WorkoutViewModel(
    routines: context.read<RoutineRepository>(),
    workouts: context.read<WorkoutRepository>(),
    routineId: widget.routineId,
    day: widget.day,
  )..load();

  @override
  void dispose() {
    vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final fmt = context.fmt;
    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: Text(vm.routine?.name ?? l10n.routine),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(24),
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.space2),
              child: Text(l10n.workoutOf(fmt.date(vm.day))),
            ),
          ),
        ),
        body: StateSwitcher(
          state: vm.state,
          onRetry: vm.load,
          empty: EmptyView(message: l10n.noExercisesWorkout),
          loaded: (items) => ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: AppTheme.space2),
            itemCount: items.length,
            itemBuilder: (context, i) => FadeSlideIn(
              index: i,
              child: _ExerciseCard(
                key: ValueKey(items[i].exercise.id),
                item: items[i],
                vm: vm,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// One exercise: its logged sets and a form to log the next one.
class _ExerciseCard extends StatefulWidget {
  const _ExerciseCard({required this.item, required this.vm, super.key});

  final WorkoutItem item;
  final WorkoutViewModel vm;

  @override
  State<_ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<_ExerciseCard> {
  final _formKey = GlobalKey<FormState>();
  final _weight = TextEditingController();
  final _reps = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Start from the last set: the next set is usually the same.
    if (widget.item.sets.lastOrNull case final last?) {
      final unit = context.read<SessionController>().unit;
      _weight.text = _plain(Units.fromKg(last.weightKg, unit));
      _reps.text = last.reps.toString();
    }
  }

  @override
  void dispose() {
    _weight.dispose();
    _reps.dispose();
    super.dispose();
  }

  static String _plain(double value) =>
      value.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');

  Future<void> _log() async {
    if (!_formKey.currentState!.validate()) return;
    final unit = context.read<SessionController>().unit;
    final l10n = context.l10n;
    final result = await widget.vm.logSet(
      widget.item.exercise.id,
      Units.toKg(Validation.parseDecimal(_weight.text)!, unit),
      int.parse(_reps.text.trim()),
    );
    if (!mounted) return;
    showMessage(context, switch (result) {
      Ok(:final value) => l10n.setLogged(value.setNumber),
      Error(:final error) => l10n.error(error),
    });
  }

  Future<void> _editSet(WorkoutSet set) async {
    final l10n = context.l10n;
    final unit = context.read<SessionController>().unit;
    final edited = await showDialog<({double weightKg, int reps})>(
      context: context,
      builder: (_) => _SetDialog(set: set, unit: unit),
    );
    if (edited == null || !mounted) return;
    final result = await widget.vm.updateSet(
      set.id,
      edited.weightKg,
      edited.reps,
    );
    if (!mounted) return;
    showMessage(context, switch (result) {
      Ok() => l10n.setUpdated,
      Error(:final error) => l10n.error(error),
    });
  }

  Future<void> _deleteSet(WorkoutSet set) async {
    final l10n = context.l10n;
    final result = await widget.vm.deleteSet(set.id);
    if (!mounted) return;
    showMessage(context, switch (result) {
      Ok() => l10n.setDeleted(set.setNumber),
      Error(:final error) => l10n.error(error),
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final fmt = context.fmt;
    final theme = Theme.of(context);
    final exercise = widget.item.exercise;
    final target = l10n.target(exercise);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(exercise.name, style: theme.textTheme.titleMedium),
            if (target != null)
              Text(l10n.targetPrefix(target), style: theme.textTheme.bodySmall),
            AnimatedSize(
              duration: AppTheme.medium,
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: Column(
                children: [
                  for (final set in widget.item.sets)
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      onTap: () => _editSet(set),
                      leading: CircleAvatar(
                        radius: 14,
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Text('${set.setNumber}'),
                      ),
                      title: Text('${fmt.weight(set.weightKg)} × ${set.reps}'),
                      trailing: IconButton(
                        tooltip: l10n.deleteSet(set.setNumber),
                        icon: const Icon(Icons.close),
                        onPressed: widget.vm.saving
                            ? null
                            : () => _deleteSet(set),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.space2),
            Form(
              key: _formKey,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _WeightField(controller: _weight)),
                  const SizedBox(width: AppTheme.space2),
                  Expanded(child: _RepsField(controller: _reps)),
                  const SizedBox(width: AppTheme.space2),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: FilledButton(
                      onPressed: widget.vm.saving ? null : _log,
                      child: Text(l10n.logSet),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Weight in the user's unit, limited like the database (0–1000 kg).
class _WeightField extends StatelessWidget {
  const _WeightField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final unit = context.watch<SessionController>().unit;
    final l10n = context.l10n;
    return TextFormField(
      controller: controller,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: l10n.weight,
        suffixText: unit.dbValue,
      ),
      validator: (v) => l10n.field(
        Validation.decimal(
          v,
          min: 0,
          max: Units.fromKg(Validation.maxLiftKg, unit).floorToDouble(),
        ),
      ),
    );
  }
}

class _RepsField extends StatelessWidget {
  const _RepsField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return TextFormField(
      controller: controller,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: l10n.reps),
      validator: (v) => l10n.field(Validation.reps(v)),
    );
  }
}

/// Edits the weight and reps of a logged set.
class _SetDialog extends StatefulWidget {
  const _SetDialog({required this.set, required this.unit});

  final WorkoutSet set;
  final WeightUnit unit;

  @override
  State<_SetDialog> createState() => _SetDialogState();
}

class _SetDialogState extends State<_SetDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _weight = TextEditingController(
    text: _ExerciseCardState._plain(
      Units.fromKg(widget.set.weightKg, widget.unit),
    ),
  );
  late final _reps = TextEditingController(text: '${widget.set.reps}');

  @override
  void dispose() {
    _weight.dispose();
    _reps.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop((
      weightKg: Units.toKg(Validation.parseDecimal(_weight.text)!, widget.unit),
      reps: int.parse(_reps.text.trim()),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.editSet(widget.set.setNumber)),
      content: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _WeightField(controller: _weight),
            const SizedBox(height: AppTheme.space3),
            _RepsField(controller: _reps),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(onPressed: _save, child: Text(l10n.save)),
      ],
    );
  }
}
