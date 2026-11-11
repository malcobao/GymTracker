import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../data/errors/app_exception.dart';
import '../../data/repositories/routine_repository.dart';
import '../../domain/models/exercise.dart';
import '../../routing/routes.dart';
import '../core/app_theme.dart';
import '../core/labels.dart';
import '../core/widgets/dialogs.dart';
import '../core/widgets/state_views.dart';
import 'exercise_dialog.dart';
import 'routine_detail_view_model.dart';

enum _Action { edit, archive, restore, delete }

/// The exercises of one routine: add, edit, reorder (drag), archive,
/// restore, delete; start today's workout.
class RoutineDetailScreen extends StatefulWidget {
  const RoutineDetailScreen({required this.routineId, super.key});

  final int routineId;

  @override
  State<RoutineDetailScreen> createState() => _RoutineDetailScreenState();
}

class _RoutineDetailScreenState extends State<RoutineDetailScreen> {
  late final vm = RoutineDetailViewModel(
    context.read<RoutineRepository>(),
    routineId: widget.routineId,
  )..load();

  @override
  void dispose() {
    vm.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final l10n = context.l10n;
    final draft = await showExerciseDialog(context, takenNames: vm.activeNames);
    if (draft == null || !mounted) return;
    _report(await vm.add(draft), l10n.exerciseAdded);
  }

  Future<void> _edit(Exercise exercise) async {
    final l10n = context.l10n;
    final draft = await showExerciseDialog(
      context,
      existing: exercise,
      takenNames: vm.activeNames,
    );
    if (draft == null || !mounted) return;
    _report(await vm.update(exercise.id, draft), l10n.exerciseUpdated);
  }

  Future<void> _delete(Exercise exercise) async {
    final l10n = context.l10n;
    final ok = await confirmAction(
      context,
      title: l10n.deleteTitle(exercise.name),
      message: l10n.deleteExerciseMessage,
      confirmLabel: l10n.delete,
      destructive: true,
    );
    if (!ok || !mounted) return;
    final error = await vm.delete(exercise.id);
    if (error is InUseException && mounted) {
      final choice = await askInUse(
        context,
        name: exercise.name,
        setCount: error.setCount,
      );
      if (!mounted) return;
      switch (choice) {
        case InUseChoice.archive:
          _report(await vm.archive(exercise.id), l10n.exerciseArchived);
        case InUseChoice.deleteEverything:
          _report(
            await vm.delete(exercise.id, withHistory: true),
            l10n.exerciseDeleted,
          );
        case null:
          return;
      }
      return;
    }
    _report(error, l10n.exerciseDeleted);
  }

  Future<void> _onAction(_Action action, Exercise exercise) async {
    final l10n = context.l10n;
    switch (action) {
      case _Action.edit:
        await _edit(exercise);
      case _Action.archive:
        _report(await vm.archive(exercise.id), l10n.exerciseArchived);
      case _Action.restore:
        _report(await vm.restore(exercise.id), l10n.exerciseRestored);
      case _Action.delete:
        await _delete(exercise);
    }
  }

  void _report(Exception? error, String success) {
    if (!mounted) return;
    showMessage(context, error == null ? success : context.l10n.error(error));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: Text(
            vm.showArchived
                ? l10n.archivedExercises
                : (vm.routine?.name ?? l10n.routine),
          ),
          actions: [
            IconButton(
              tooltip: l10n.archivedExercises,
              isSelected: vm.showArchived,
              icon: const Icon(Icons.inventory_2_outlined),
              selectedIcon: const Icon(Icons.inventory_2),
              onPressed: vm.toggleArchived,
            ),
            if (!vm.showArchived)
              IconButton(
                tooltip: l10n.addExercise,
                icon: const Icon(Icons.add),
                onPressed: _add,
              ),
          ],
        ),
        body: StateSwitcher(
          state: vm.state,
          onRetry: vm.load,
          empty: vm.showArchived
              ? EmptyView(message: l10n.noArchivedExercises)
              : EmptyView(
                  message: l10n.noExercises,
                  icon: Icons.fitness_center,
                  actionLabel: l10n.addExercise,
                  onAction: _add,
                ),
          loaded: (exercises) => Column(
            children: [
              Expanded(
                child: ReorderableListView.builder(
                  padding: const EdgeInsets.only(top: AppTheme.space2),
                  buildDefaultDragHandles: !vm.showArchived,
                  itemCount: exercises.length,
                  onReorderItem: (from, to) async {
                    final error = await vm.move(from, to);
                    if (error != null) _report(error, '');
                  },
                  itemBuilder: (context, i) => FadeSlideIn(
                    key: ValueKey(exercises[i].id),
                    index: i,
                    child: _ExerciseTile(
                      exercise: exercises[i],
                      onTap: exercises[i].archived
                          ? null
                          : () => _edit(exercises[i]),
                      onProgress: () => context.push(
                        Routes.progress(exercises[i].id),
                        extra: exercises[i].name,
                      ),
                      onAction: (a) => _onAction(a, exercises[i]),
                    ),
                  ),
                ),
              ),
              if (!vm.showArchived)
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.space4),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: Text(l10n.startWorkout),
                        onPressed: () async {
                          await context.push(Routes.workout(vm.routineId));
                          await vm.load();
                        },
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExerciseTile extends StatelessWidget {
  const _ExerciseTile({
    required this.exercise,
    required this.onTap,
    required this.onProgress,
    required this.onAction,
  });

  final Exercise exercise;
  final VoidCallback? onTap;
  final VoidCallback onProgress;
  final ValueChanged<_Action> onAction;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final details = [
      if (exercise.muscleGroup != null) l10n.muscle(exercise.muscleGroup),
      ?l10n.target(exercise),
    ].join(' · ');
    return Card(
      child: ListTile(
        onTap: onTap,
        title: Text(
          exercise.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: details.isEmpty ? null : Text(details),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: l10n.progressTooltip,
              icon: const Icon(Icons.show_chart),
              onPressed: onProgress,
            ),
            PopupMenuButton<_Action>(
              tooltip: l10n.moreOptions,
              onSelected: onAction,
              itemBuilder: (context) => [
                if (!exercise.archived) ...[
                  PopupMenuItem(value: _Action.edit, child: Text(l10n.edit)),
                  PopupMenuItem(
                    value: _Action.archive,
                    child: Text(l10n.archive),
                  ),
                ] else
                  PopupMenuItem(
                    value: _Action.restore,
                    child: Text(l10n.restore),
                  ),
                PopupMenuItem(value: _Action.delete, child: Text(l10n.delete)),
              ],
            ),
            if (!exercise.archived) const SizedBox(width: 32),
          ],
        ),
      ),
    );
  }
}
