import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../data/local/database_changes.dart';
import '../../data/repositories/routine_repository.dart';
import '../../data/repositories/workout_repository.dart';
import '../../domain/reports.dart';
import '../../domain/statistics.dart';
import '../core/app_theme.dart';
import '../core/labels.dart';
import '../core/widgets/dialogs.dart';
import '../core/widgets/filters.dart';
import '../core/widgets/state_views.dart';
import 'report_format.dart';
import 'reports_view_model.dart';

/// Tab 3: configurable reports. The user chooses the report type, the
/// filters (period, routine, exercise, muscle group), the grouping and the
/// sort column/direction (also by tapping a column header), then can copy
/// the result as CSV.
const _icons = {
  ReportType.setLog: Icons.list_alt,
  ReportType.byExercise: Icons.fitness_center,
  ReportType.byPeriod: Icons.date_range,
  ReportType.personalRecords: Icons.emoji_events_outlined,
};

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  late final vm = ReportsViewModel(
    routines: context.read<RoutineRepository>(),
    workouts: context.read<WorkoutRepository>(),
  )..load();

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

  Future<void> _copyCsv() async {
    final l10n = context.l10n;
    final csv = ReportFormatter(
      l10n,
      context.fmtNow,
      vm.config.grouping,
    ).csv(vm.table);
    await Clipboard.setData(ClipboardData(text: csv));
    if (mounted) showMessage(context, l10n.csvCopied);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) {
        final table = vm.table;
        final config = vm.config;
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.navReports),
            actions: [
              IconButton(
                tooltip: l10n.copyCsv,
                icon: const Icon(Icons.copy_all_outlined),
                onPressed: table.rows.isEmpty ? null : _copyCsv,
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: vm.load,
            child: ListView(
              padding: const EdgeInsets.only(bottom: AppTheme.space5),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.space4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: AppTheme.space2,
                          runSpacing: AppTheme.space2,
                          children: [
                            for (final t in ReportType.values)
                              ChoiceChip(
                                avatar: Icon(_icons[t], size: 18),
                                label: Text(l10n.reportTypeLabel(t)),
                                selected: config.type == t,
                                showCheckmark: false,
                                onSelected: (_) => vm.setType(t),
                              ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.space2),
                        AnimatedSwitcher(
                          duration: AppTheme.fast,
                          child: Text(
                            l10n.reportInfo(config.type),
                            key: ValueKey(config.type),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        const SizedBox(height: AppTheme.space3),
                        FilterBar(
                          selection: vm.selection,
                          lookups: vm.lookups,
                          onChanged: vm.setSelection,
                        ),
                        const SizedBox(height: AppTheme.space2),
                        Wrap(
                          spacing: AppTheme.space2,
                          runSpacing: AppTheme.space2,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            if (config.type == ReportType.byPeriod)
                              ChoicePill<Grouping>(
                                icon: Icons.calendar_view_week,
                                label: l10n.groupBy,
                                value: config.grouping,
                                options: Grouping.values,
                                optionLabel: l10n.grouping,
                                onSelected: vm.setGrouping,
                              ),
                            ChoicePill<ReportColumn>(
                              icon: Icons.sort,
                              label: l10n.sortBy,
                              value: table.sortColumn,
                              options: table.columns,
                              optionLabel: l10n.column,
                              onSelected: (c) =>
                                  vm.sortBy(c, ascending: table.ascending),
                            ),
                            ChoicePill<bool>(
                              icon: table.ascending
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              label: l10n.order,
                              value: table.ascending,
                              options: const [true, false],
                              optionLabel: (a) =>
                                  a ? l10n.ascending : l10n.descending,
                              onSelected: (a) =>
                                  vm.sortBy(table.sortColumn, ascending: a),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                StateSwitcher(
                  state: vm.state,
                  onRetry: vm.load,
                  empty: Padding(
                    padding: const EdgeInsets.all(AppTheme.space5),
                    child: EmptyView(
                      message: l10n.noData,
                      icon: Icons.table_chart_outlined,
                    ),
                  ),
                  loaded: (_) => _ReportTableView(
                    table: table,
                    grouping: config.grouping,
                    onSort: vm.sortBy,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ReportTableView extends StatelessWidget {
  const _ReportTableView({
    required this.table,
    required this.grouping,
    required this.onSort,
  });

  final ReportTable table;
  final Grouping grouping;
  final void Function(ReportColumn) onSort;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final format = ReportFormatter(l10n, context.fmt, grouping);
    final bold = TextStyle(
      fontWeight: FontWeight.bold,
      color: theme.colorScheme.primary,
    );
    return FadeSlideIn(
      key: ValueKey('${table.columns.first}-${table.rows.length}'),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.space4,
                AppTheme.space4,
                AppTheme.space4,
                0,
              ),
              child: Text(
                l10n.rowCount(table.rows.length),
                style: theme.textTheme.labelLarge,
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingTextStyle: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                sortColumnIndex: table.columns.indexOf(table.sortColumn),
                sortAscending: table.ascending,
                columns: [
                  for (final c in table.columns)
                    DataColumn(
                      label: Text(l10n.column(c)),
                      numeric: c.isNumeric,
                      onSort: (_, _) => onSort(c),
                    ),
                ],
                rows: [
                  for (final row in table.rows)
                    DataRow(
                      cells: [
                        for (var i = 0; i < row.length; i++)
                          DataCell(Text(format.cell(table.columns[i], row[i]))),
                      ],
                    ),
                  if (table.totals case final totals?)
                    DataRow(
                      color: WidgetStatePropertyAll(
                        theme.colorScheme.primaryContainer.withValues(
                          alpha: 0.4,
                        ),
                      ),
                      cells: [
                        for (var i = 0; i < totals.length; i++)
                          DataCell(
                            Text(
                              i == 0
                                  ? l10n.total
                                  : format.cell(table.columns[i], totals[i]),
                              style: bold,
                            ),
                          ),
                      ],
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
