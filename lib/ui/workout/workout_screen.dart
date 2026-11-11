import 'package:flutter/material.dart';

import '../../domain/models/user_profile.dart' show dateOnly;
import '../../domain/models/workout_set.dart';
import '../../domain/validation.dart';
import '../../utils/units.dart';
import '../core/view_models/view_state.dart';
import '../core/widgets/empty_view.dart';
import '../core/widgets/error_view.dart';
import '../core/widgets/loading_view.dart';
import '../core/widgets/snack.dart';
import 'workout_view_model.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({
    required this.viewModel,
    required this.routineName,
    super.key,
  });

  final WorkoutViewModel viewModel;
  final String routineName;

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  WorkoutViewModel get vm => widget.viewModel;

  @override
  void initState() {
    super.initState();
    vm.load();
  }

  // The router may rebuild this page with a new view model (for example
  // when returning from a pushed screen); load it, or it stays Loading.
  @override
  void didUpdateWidget(WorkoutScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.viewModel != widget.viewModel) widget.viewModel.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.routineName),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text('Workout of ${dateOnly(vm.day)}'),
          ),
        ),
      ),
      body: ListenableBuilder(
        listenable: vm,
        builder: (context, _) => switch (vm.state) {
          Loading() => const LoadingView(),
          Failed(:final message) => ErrorView(
            message: message,
            onRetry: vm.load,
          ),
          Empty() => const EmptyView(
            message: 'Add exercises to this routine before training.',
          ),
          Loaded(data: final items) => ListView(
            padding: const EdgeInsets.all(12),
            children: [
              for (final item in items)
                _ExerciseCard(
                  key: ValueKey(item.exercise.id),
                  item: item,
                  vm: vm,
                ),
            ],
          ),
        },
      ),
    );
  }
}

class _ExerciseCard extends StatefulWidget {
  const _ExerciseCard({required this.item, required this.vm, super.key});

  final ExerciseWithSets item;
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
    _prefillFromLastSet();
  }

  /// Suggests the last set's numbers, which is what people usually repeat.
  void _prefillFromLastSet() {
    final sets = widget.item.sets;
    if (sets.isEmpty) return;
    final last = sets.last;
    final value = Units.fromKg(last.weightKg, widget.vm.unit);
    _weight.text = value.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
    _reps.text = last.reps.toString();
  }

  @override
  void dispose() {
    _weight.dispose();
    _reps.dispose();
    super.dispose();
  }

  String? _weightValidator(String? v) {
    final unit = widget.vm.unit;
    return Validation.range(
      v,
      min: 0,
      max: double.parse(
        Units.fromKg(Validation.maxLiftKg, unit).toStringAsFixed(0),
      ),
      unit: unit.dbValue,
    );
  }

  Future<void> _log() async {
    if (!_formKey.currentState!.validate()) return;
    final error = await widget.vm.logSet(
      widget.item.exercise.id,
      Validation.parseDecimal(_weight.text)!,
      int.parse(_reps.text.trim()),
    );
    if (mounted) showMessage(context, error);
  }

  Future<void> _delete(WorkoutSet set) async {
    final error = await widget.vm.deleteSet(set);
    if (mounted) showMessage(context, error ?? 'Set ${set.setNumber} deleted');
  }

  @override
  Widget build(BuildContext context) {
    final exercise = widget.item.exercise;
    final unit = widget.vm.unit;
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(exercise.name, style: theme.textTheme.titleMedium),
            if (exercise.targetLabel != null)
              Text(
                'Target: ${exercise.targetLabel}',
                style: theme.textTheme.bodySmall,
              ),
            const SizedBox(height: 8),
            for (final set in widget.item.sets)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  radius: 14,
                  child: Text('${set.setNumber}'),
                ),
                title: Text(
                  '${Units.format(set.weightKg, unit)} × ${set.reps}',
                ),
                trailing: IconButton(
                  tooltip: 'Delete set ${set.setNumber}',
                  icon: const Icon(Icons.close),
                  onPressed: () => _delete(set),
                ),
              ),
            Form(
              key: _formKey,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _weight,
                      decoration: InputDecoration(
                        labelText: 'Weight',
                        suffixText: unit.dbValue,
                        isDense: true,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: _weightValidator,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _reps,
                      decoration: const InputDecoration(
                        labelText: 'Reps',
                        isDense: true,
                      ),
                      keyboardType: TextInputType.number,
                      validator: Validation.reps,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: ListenableBuilder(
                      listenable: widget.vm,
                      builder: (context, _) => FilledButton(
                        onPressed: widget.vm.saving ? null : _log,
                        child: const Text('Log set'),
                      ),
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
