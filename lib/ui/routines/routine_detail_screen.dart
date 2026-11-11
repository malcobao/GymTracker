import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/exercise.dart';
import '../../routing/routes.dart';
import '../core/view_models/view_state.dart';
import '../core/widgets/empty_view.dart';
import '../core/widgets/error_view.dart';
import '../core/widgets/loading_view.dart';
import '../core/widgets/snack.dart';
import '../core/widgets/text_prompt_dialog.dart';
import 'exercise_dialog.dart';
import 'routine_detail_view_model.dart';

/// The exercises of one routine. Drag to reorder; start today's workout.
class RoutineDetailScreen extends StatefulWidget {
  const RoutineDetailScreen({
    required this.viewModel,
    required this.title,
    super.key,
  });

  final RoutineDetailViewModel viewModel;
  final String title;

  @override
  State<RoutineDetailScreen> createState() => _RoutineDetailScreenState();
}

class _RoutineDetailScreenState extends State<RoutineDetailScreen> {
  RoutineDetailViewModel get vm => widget.viewModel;

  @override
  void initState() {
    super.initState();
    vm.load();
  }

  Future<void> _add() async {
    final draft = await showExerciseDialog(context);
    if (draft == null || !mounted) return;
    final message = await vm.add(draft);
    if (mounted) showMessage(context, message);
  }

  Future<void> _edit(Exercise exercise) async {
    final draft = await showExerciseDialog(context, existing: exercise);
    if (draft == null || !mounted) return;
    final message = await vm.update(exercise.id, draft);
    if (mounted) showMessage(context, message);
  }

  Future<void> _archive(Exercise exercise) async {
    final ok = await confirmAction(
      context,
      title: 'Remove "${exercise.name}"?',
      message: 'It leaves this routine. Its logged sets are kept.',
      confirmLabel: 'Remove',
    );
    if (!ok || !mounted) return;
    final message = await vm.archive(exercise.id);
    if (mounted) showMessage(context, message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            tooltip: 'Add exercise',
            icon: const Icon(Icons.add),
            onPressed: _add,
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: vm,
        builder: (context, _) => switch (vm.state) {
          Loading() => const LoadingView(),
          Failed(:final message) => ErrorView(
            message: message,
            onRetry: vm.load,
          ),
          Empty() => EmptyView(
            message: 'This routine has no exercises yet.',
            actionLabel: 'Add exercise',
            onAction: _add,
          ),
          Loaded(data: final exercises) => Column(
            children: [
              Expanded(
                child: ReorderableListView.builder(
                  itemCount: exercises.length,
                  onReorderItem: (from, to) async {
                    final message = await vm.move(from, to);
                    if (mounted) showMessage(this.context, message);
                  },
                  itemBuilder: (context, i) {
                    final e = exercises[i];
                    final details = [
                      ?e.muscleGroup?.label,
                      ?e.targetLabel,
                    ].join(' · ');
                    return ListTile(
                      key: ValueKey(e.id),
                      title: Text(e.name),
                      subtitle: details.isEmpty ? null : Text(details),
                      onTap: () => _edit(e),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Progress',
                            icon: const Icon(Icons.show_chart),
                            onPressed: () =>
                                context.push(Routes.progress(e.id), extra: e),
                          ),
                          IconButton(
                            tooltip: 'Remove',
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _archive(e),
                          ),
                          const SizedBox(width: 24),
                        ],
                      ),
                    );
                  },
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      icon: const Icon(Icons.play_arrow),
                      label: const Text("Start today's workout"),
                      onPressed: () => context.push(
                        Routes.workout(vm.routineId),
                        extra: widget.title,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        },
      ),
    );
  }
}
