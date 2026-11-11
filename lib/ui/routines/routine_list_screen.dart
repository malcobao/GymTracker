import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/routine.dart';
import '../../routing/routes.dart';
import '../core/view_models/view_state.dart';
import '../core/widgets/empty_view.dart';
import '../core/widgets/error_view.dart';
import '../core/widgets/loading_view.dart';
import '../core/widgets/snack.dart';
import '../core/widgets/text_prompt_dialog.dart';
import 'routine_list_view_model.dart';

/// Home screen: the user's routines.
class RoutineListScreen extends StatefulWidget {
  const RoutineListScreen({
    required this.viewModel,
    required this.onSignOut,
    super.key,
  });

  final RoutineListViewModel viewModel;
  final Future<void> Function() onSignOut;

  @override
  State<RoutineListScreen> createState() => _RoutineListScreenState();
}

enum _MenuAction { profile, signOut }

class _RoutineListScreenState extends State<RoutineListScreen> {
  RoutineListViewModel get vm => widget.viewModel;

  @override
  void initState() {
    super.initState();
    vm.load();
  }

  Future<void> _create() async {
    final input = await showNameDialog(
      context,
      title: 'New routine',
      askDescription: true,
      confirmLabel: 'Create',
    );
    if (input == null || !mounted) return;
    final message = await vm.create(input.name, input.description);
    if (mounted) showMessage(context, message);
  }

  Future<void> _rename(Routine routine) async {
    final input = await showNameDialog(
      context,
      title: 'Rename routine',
      initialName: routine.name,
    );
    if (input == null || !mounted) return;
    final message = await vm.rename(routine.id, input.name);
    if (mounted) showMessage(context, message);
  }

  Future<void> _archive(Routine routine) async {
    final ok = await confirmAction(
      context,
      title: 'Remove "${routine.name}"?',
      message:
          'It disappears from your list. Sets you already logged are kept.',
      confirmLabel: 'Remove',
    );
    if (!ok || !mounted) return;
    final message = await vm.archive(routine.id);
    if (mounted) showMessage(context, message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My routines'),
        actions: [
          PopupMenuButton<_MenuAction>(
            onSelected: (action) => switch (action) {
              _MenuAction.profile => context.push(Routes.profile),
              _MenuAction.signOut => widget.onSignOut(),
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: _MenuAction.profile,
                child: Text('Edit profile'),
              ),
              PopupMenuItem(
                value: _MenuAction.signOut,
                child: Text('Sign out'),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _create,
        icon: const Icon(Icons.add),
        label: const Text('Routine'),
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
            message:
                'No routines yet. Create your first one, for example '
                '"Push day".',
            actionLabel: 'Create routine',
            onAction: _create,
          ),
          Loaded(data: final routines) => RefreshIndicator(
            onRefresh: vm.load,
            child: ListView.separated(
              padding: const EdgeInsets.only(bottom: 88),
              itemCount: routines.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final routine = routines[i];
                return ListTile(
                  leading: const Icon(Icons.list_alt),
                  title: Text(routine.name),
                  subtitle: routine.description == null
                      ? null
                      : Text(routine.description!),
                  onTap: () =>
                      context.push(Routes.routine(routine.id), extra: routine),
                  trailing: PopupMenuButton<String>(
                    tooltip: 'Routine options',
                    onSelected: (value) => value == 'rename'
                        ? _rename(routine)
                        : _archive(routine),
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'rename', child: Text('Rename')),
                      PopupMenuItem(value: 'archive', child: Text('Remove')),
                    ],
                  ),
                );
              },
            ),
          ),
        },
      ),
    );
  }
}
