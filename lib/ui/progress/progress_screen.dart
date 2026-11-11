import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/repositories/workout_repository.dart';
import '../../domain/progress_calculator.dart';
import '../core/app_theme.dart';
import '../core/labels.dart';
import '../core/widgets/charts.dart';
import '../core/widgets/state_views.dart';
import '../statistics/kpi_tile.dart';
import 'progress_view_model.dart';

/// Progress of one exercise: best estimated 1RM, chart and history.
class ProgressScreen extends StatefulWidget {
  const ProgressScreen({
    required this.exerciseId,
    required this.exerciseName,
    super.key,
  });

  final int exerciseId;
  final String exerciseName;

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  late final vm = ProgressViewModel(
    context.read<WorkoutRepository>(),
    exerciseId: widget.exerciseId,
  )..load();

  @override
  void dispose() {
    vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(widget.exerciseName)),
      body: ListenableBuilder(
        listenable: vm,
        builder: (context, _) => StateSwitcher(
          state: vm.state,
          onRetry: vm.load,
          empty: EmptyView(
            message: l10n.noSetsForExercise,
            icon: Icons.show_chart,
          ),
          loaded: (days) => _ProgressBody(days: days),
        ),
      ),
    );
  }
}

class _ProgressBody extends StatelessWidget {
  const _ProgressBody({required this.days});

  final List<DailyProgress> days;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final fmt = context.fmt;
    final theme = Theme.of(context);
    final best = days
        .map((d) => d.estimatedOneRepMaxKg)
        .reduce((a, b) => a > b ? a : b);
    final change =
        days.last.estimatedOneRepMaxKg - days.first.estimatedOneRepMaxKg;
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.space2),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.space2),
          child: Wrap(
            children: [
              KpiTile(
                label: l10n.bestOneRepMax,
                value: best,
                format: fmt.weight,
                icon: Icons.emoji_events_outlined,
              ),
              KpiTile(
                label: l10n.changeSinceFirst,
                value: change,
                format: (v) => '${v >= 0 ? '+' : ''}${fmt.weight(v)}',
                icon: Icons.trending_up,
              ),
              KpiTile(
                label: l10n.trainingDays,
                value: days.length.toDouble(),
                format: (v) => fmt.number(v, decimals: 0),
                icon: Icons.calendar_month_outlined,
              ),
            ],
          ),
        ),
        ChartCard(
          title: l10n.oneRepMaxPerDay,
          icon: Icons.show_chart,
          footer: Text(l10n.epleyNote, style: theme.textTheme.bodySmall),
          child: TrendLineChart(
            values: [for (final d in days) fmt.inUnit(d.estimatedOneRepMaxKg)],
            xLabel: (i) => fmt.shortDate(days[i].date),
            valueLabel: (v) => fmt.unitValue(v, decimals: 0),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.space4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.history, style: theme.textTheme.titleMedium),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: [
                      DataColumn(label: Text(l10n.date)),
                      DataColumn(label: Text(l10n.topSet), numeric: true),
                      DataColumn(label: Text(l10n.estimated1rm), numeric: true),
                      DataColumn(label: Text(l10n.volume), numeric: true),
                    ],
                    rows: [
                      for (final d in days.reversed)
                        DataRow(
                          cells: [
                            DataCell(Text(fmt.date(d.date))),
                            DataCell(Text(fmt.weight(d.topWeightKg))),
                            DataCell(Text(fmt.weight(d.estimatedOneRepMaxKg))),
                            DataCell(Text(fmt.volume(d.volumeKg))),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
