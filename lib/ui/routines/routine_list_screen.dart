import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../data/local/database_changes.dart';
import '../../data/errors/app_exception.dart';
import '../../data/repositories/routine_repository.dart';
import '../../domain/models/routine.dart';
import '../../routing/routes.dart';
import '../core/app_theme.dart';
import '../core/labels.dart';
import '../core/widgets/dialogs.dart';
import '../core/widgets/state_views.dart';
import 'routine_list_view_model.dart';

enum _Action { edit, archive, restore, delete }

/// Tab 1: the user's routines (create, edit, archive, restore, delete).
class RoutineListScreen extends StatefulWidget {
  const RoutineListScreen({super.key});

  @override
  State<RoutineListScreen> createState() => _RoutineListScreenState();
}

class _RoutineListScreenState extends State<RoutineListScreen> {
  late final vm = RoutineListViewModel(context.read<RoutineRepository>())
    ..load();

  /// Reloads after any write to the database, even one made on another tab.
  late final DatabaseChanges _changes = context.read<DatabaseChanges>();

  @override
  void initState() {
    super.initState();
    _changes.addListener(vm.load);
  }

  @override
  void dispose() {
    _changes.removeListener(vm.load);
    vm.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final l10n = context.l10n;
    final input = await showNameDialog(
      context,
      title: l10n.newRoutine,
      confirmLabel: l10n.create,
      takenNames: vm.activeNames,
    );
    if (input == null || !mounted) return;
    final error = await vm.create(input.name, input.description);
    _report(error, l10n.routineCreated);
  }

  Future<void> _edit(Routine routine) async {
    final l10n = context.l10n;
    final input = await showNameDialog(
      context,
      title: l10n.editRoutine,
      confirmLabel: l10n.save,
      initialName: routine.name,
      initialDescription: routine.description,
      takenNames: vm.activeNames.where((n) => n != routine.name),
    );
    if (input == null || !mounted) return;
    final error = await vm.update(routine.id, input.name, input.description);
    _report(error, l10n.routineUpdated);
  }

  /// DELETE with referential integrity: the database refuses when logged
  /// sets depend on the routine; then the user chooses what to do.
  Future<void> _delete(Routine routine) async {
    final l10n = context.l10n;
    final ok = await confirmAction(
      context,
      title: l10n.deleteTitle(routine.name),
      message: l10n.deleteRoutineMessage,
      confirmLabel: l10n.delete,
      destructive: true,
    );
    if (!ok || !mounted) return;
    final error = await vm.delete(routine.id);
    if (error is InUseException && mounted) {
      final choice = await askInUse(
        context,
        name: routine.name,
        setCount: error.setCount,
      );
      if (!mounted) return;
      switch (choice) {
        case InUseChoice.archive:
          _report(await vm.archive(routine.id), l10n.routineArchived);
        case InUseChoice.deleteEverything:
          _report(
            await vm.delete(routine.id, withHistory: true),
            l10n.routineDeleted,
          );
        case null:
          return;
      }
      return;
    }
    _report(error, l10n.routineDeleted);
  }

  Future<void> _onAction(_Action action, Routine routine) async {
    final l10n = context.l10n;
    switch (action) {
      case _Action.edit:
        await _edit(routine);
      case _Action.archive:
        _report(await vm.archive(routine.id), l10n.routineArchived);
      case _Action.restore:
        _report(await vm.restore(routine.id), l10n.routineRestored);
      case _Action.delete:
        await _delete(routine);
    }
  }

  void _report(Exception? error, String success) {
    if (!mounted) return;
    showMessage(context, error == null ? success : context.l10n.error(error));
  }

  Future<void> _open(Routine routine) async {
    await context.push(Routes.routine(routine.id));
    await vm.load(); // exercises may have changed
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: Text(
            vm.showArchived ? l10n.archivedRoutines : l10n.myRoutines,
          ),
          actions: [
            IconButton(
              tooltip: l10n.showArchived,
              isSelected: vm.showArchived,
              icon: const Icon(Icons.inventory_2_outlined),
              selectedIcon: const Icon(Icons.inventory_2),
              onPressed: vm.toggleArchived,
            ),
          ],
        ),
        floatingActionButton: vm.showArchived
            ? null
            : FloatingActionButton.extended(
                onPressed: _create,
                icon: const Icon(Icons.add),
                label: Text(l10n.routineFab),
              ),
        body: StateSwitcher(
          state: vm.state,
          onRetry: vm.load,
          empty: vm.showArchived
              ? EmptyView(
                  message: l10n.noArchivedRoutines,
                  icon: Icons.inventory_2_outlined,
                )
              : EmptyView(
                  message: l10n.noRoutines,
                  icon: Icons.fitness_center,
                  actionLabel: l10n.createRoutine,
                  onAction: _create,
                ),
          loaded: (routines) => RefreshIndicator(
            onRefresh: vm.load,
            child: ListView.builder(
              padding: const EdgeInsets.only(top: AppTheme.space2, bottom: 96),
              itemCount: routines.length,
              itemBuilder: (context, i) => FadeSlideIn(
                key: ValueKey(routines[i].id),
                index: i,
                child: _RoutineCard(
                  routine: routines[i],
                  onTap: routines[i].archived ? null : () => _open(routines[i]),
                  onAction: (a) => _onAction(a, routines[i]),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoutineCard extends StatelessWidget {
  const _RoutineCard({
    required this.routine,
    required this.onTap,
    required this.onAction,
  });

  final Routine routine;
  final VoidCallback? onTap;
  final ValueChanged<_Action> onAction;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.fromLTRB(
          AppTheme.space4,
          AppTheme.space2,
          AppTheme.space1,
          AppTheme.space2,
        ),
        leading: CircleAvatar(
          backgroundColor: routine.archived
              ? scheme.surfaceContainerHighest
              : scheme.primaryContainer,
          foregroundColor: scheme.onPrimaryContainer,
          child: Text(routine.name.characters.first.toUpperCase()),
        ),
        title: Text(
          routine.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          [
            if (routine.description != null) routine.description!,
            l10n.exerciseCount(routine.exerciseCount),
          ].join('\n'),
        ),
        isThreeLine: routine.description != null,
        trailing: PopupMenuButton<_Action>(
          tooltip: l10n.moreOptions,
          onSelected: onAction,
          itemBuilder: (context) => [
            if (!routine.archived) ...[
              _item(_Action.edit, Icons.edit_outlined, l10n.edit),
              _item(_Action.archive, Icons.inventory_2_outlined, l10n.archive),
            ] else
              _item(_Action.restore, Icons.unarchive_outlined, l10n.restore),
            _item(_Action.delete, Icons.delete_outline, l10n.delete),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<_Action> _item(_Action action, IconData icon, String text) =>
      PopupMenuItem(
        value: action,
        child: ListTile(
          leading: Icon(icon),
          title: Text(text),
          contentPadding: EdgeInsets.zero,
        ),
      );
}
