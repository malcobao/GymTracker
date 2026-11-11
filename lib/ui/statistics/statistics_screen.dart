import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/local/database_changes.dart';
import '../../data/repositories/routine_repository.dart';
import '../../data/repositories/workout_repository.dart';
import '../../domain/statistics.dart';
import '../core/app_theme.dart';
import '../core/labels.dart';
import '../core/widgets/charts.dart';
import '../core/widgets/filters.dart';
import '../core/widgets/state_views.dart';
import 'kpi_tile.dart';
import 'statistics_view_model.dart';

/// Tab 2: parametrisable statistics.
///
/// Global parameters (top bar): period, routine, exercise, muscle group.
/// Per-chart parameters: metric and grouping (progress over time), exercise
/// (1RM), metric (muscle groups), ranking and size (top exercises).
class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  late final vm = StatisticsViewModel(
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

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navStatistics),
        actions: [
          IconButton(
            tooltip: l10n.tryAgain,
            icon: const Icon(Icons.refresh),
            onPressed: vm.load,
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: vm,
        builder: (context, _) => RefreshIndicator(
          onRefresh: vm.load,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppTheme.space4,
                    AppTheme.space2,
                    AppTheme.space4,
                    AppTheme.space2,
                  ),
                  child: FilterBar(
                    selection: vm.selection,
                    lookups: vm.lookups,
                    onChanged: vm.setSelection,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: StateSwitcher(
                  state: vm.state,
                  onRetry: vm.load,
                  empty: SizedBox(
                    height: 360,
                    child: EmptyView(
                      message: l10n.noData,
                      icon: Icons.insights_outlined,
                    ),
                  ),
                  loaded: (_) => _StatsBody(vm: vm),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsBody extends StatelessWidget {
  const _StatsBody({required this.vm});

  final StatisticsViewModel vm;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final fmt = context.fmt;
    final summary = vm.summary;
    final series = vm.series;
    final e1rm = vm.oneRepMaxProgress;
    final muscles = vm.byMuscleGroup;
    final weekdays = vm.byWeekday;
    final top = vm.topExercises;
    // Chart values: weights converted to the user's unit, counts as they are.
    double plotted(Metric m, double v) =>
        m == Metric.volume ? fmt.inUnit(v) : v;
    String metricValue(Metric m, double v) => m == Metric.volume
        ? fmt.unitValue(v, decimals: 0)
        : fmt.number(v, decimals: 0);

    final charts = <Widget>[
      // Statistic 1: KPIs.
      LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth > 900
              ? 4
              : constraints.maxWidth > 560
              ? 3
              : 2;
          final width = (constraints.maxWidth - AppTheme.space4) / columns;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.space2),
            child: Wrap(
              children: [
                KpiTile(
                  width: width,
                  icon: Icons.calendar_month_outlined,
                  label: l10n.trainingDays,
                  value: summary.trainingDays.toDouble(),
                  format: (v) => fmt.number(v, decimals: 0),
                ),
                KpiTile(
                  width: width,
                  icon: Icons.repeat,
                  label: l10n.statsSets,
                  value: summary.totalSets.toDouble(),
                  format: (v) => fmt.number(v, decimals: 0),
                ),
                KpiTile(
                  width: width,
                  icon: Icons.fitness_center,
                  label: l10n.statsReps,
                  value: summary.totalReps.toDouble(),
                  format: (v) => fmt.number(v, decimals: 0),
                ),
                KpiTile(
                  width: width,
                  icon: Icons.scale_outlined,
                  label: l10n.statsVolume,
                  value: summary.totalVolumeKg,
                  format: fmt.volume,
                ),
                KpiTile(
                  width: width,
                  icon: Icons.bar_chart,
                  label: l10n.statsAvgVolume,
                  value: summary.averageVolumePerDayKg,
                  format: fmt.volume,
                ),
                KpiTile(
                  width: width,
                  icon: Icons.stacked_bar_chart,
                  label: l10n.statsAvgSets,
                  value: summary.averageSetsPerDay,
                  format: (v) => fmt.number(v),
                ),
                KpiTile(
                  width: width,
                  icon: Icons.emoji_events_outlined,
                  label: l10n.bestOneRepMax,
                  value: summary.bestOneRepMaxKg,
                  format: fmt.weight,
                  caption: summary.bestOneRepMaxExercise,
                ),
                KpiTile(
                  width: width,
                  icon: Icons.local_fire_department_outlined,
                  label: l10n.statsStreak,
                  value: summary.currentStreakWeeks.toDouble(),
                  format: (v) => l10n.statsWeeks(v.round()),
                ),
              ],
            ),
          );
        },
      ),
      // Statistic 2: progress over time (metric + grouping).
      ChartCard(
        title: l10n.chartOverTime,
        icon: Icons.timeline,
        controls: [
          ChoicePill<Metric>(
            label: l10n.metric,
            value: vm.seriesMetric,
            options: Metric.values,
            optionLabel: l10n.metricLabel,
            onSelected: vm.setSeriesMetric,
          ),
          ChoicePill<Grouping>(
            label: l10n.groupBy,
            value: vm.grouping,
            options: Grouping.values,
            optionLabel: l10n.grouping,
            onSelected: vm.setGrouping,
          ),
        ],
        child: SimpleBarChart(
          values: [for (final p in series) plotted(vm.seriesMetric, p.value)],
          xLabel: (i) => vm.grouping == Grouping.month
              ? fmt.period(series[i].start, Grouping.month, l10n)
              : fmt.shortDate(series[i].start),
          valueLabel: (v) => metricValue(vm.seriesMetric, v),
        ),
      ),
      // Statistic 3: estimated 1RM of one exercise.
      ChartCard(
        title: l10n.chartOneRepMax,
        icon: Icons.show_chart,
        controls: [
          if (vm.oneRepMaxExerciseId case final id?)
            ChoicePill<int>(
              label: l10n.exercise,
              value: id,
              options: [for (final e in vm.exercisesInData) e.id],
              optionLabel: (id) =>
                  vm.exercisesInData.firstWhere((e) => e.id == id).name,
              onSelected: vm.setOneRepMaxExercise,
            ),
        ],
        child: e1rm.isEmpty
            ? Text(l10n.noDataExercise)
            : TrendLineChart(
                values: [
                  for (final d in e1rm) fmt.inUnit(d.estimatedOneRepMaxKg),
                ],
                xLabel: (i) => fmt.shortDate(e1rm[i].date),
                valueLabel: (v) => fmt.unitValue(v, decimals: 0),
              ),
      ),
      // Statistic 4: distribution by muscle group (metric).
      ChartCard(
        title: l10n.chartMuscleGroups,
        icon: Icons.donut_large,
        controls: [
          ChoicePill<Metric>(
            label: l10n.metric,
            value: vm.muscleMetric,
            options: Metric.values,
            optionLabel: l10n.metricLabel,
            onSelected: vm.setMuscleMetric,
          ),
        ],
        child: DonutChart(
          labels: [for (final m in muscles) l10n.muscle(m.group)],
          values: [for (final m in muscles) plotted(vm.muscleMetric, m.value)],
          valueLabel: (v) => metricValue(vm.muscleMetric, v),
        ),
      ),
      // Statistic 5: training days per weekday.
      ChartCard(
        title: l10n.chartWeekdays,
        icon: Icons.view_week_outlined,
        child: SimpleBarChart(
          values: [for (final c in weekdays) c.toDouble()],
          xLabel: (i) => fmt.weekdayShort(i + 1),
          valueLabel: (v) => fmt.number(v, decimals: 0),
        ),
      ),
      // Statistic 6: ranking of exercises (criterion + size).
      ChartCard(
        title: l10n.chartTopExercises,
        icon: Icons.leaderboard_outlined,
        controls: [
          ChoicePill<bool>(
            label: l10n.rankBy,
            value: vm.rankByOneRepMax,
            options: const [false, true],
            optionLabel: (b) => b ? l10n.rankOneRepMax : l10n.volume,
            onSelected: vm.setRankByOneRepMax,
          ),
          ChoicePill<int>(
            label: l10n.show,
            value: vm.topN,
            options: const [3, 5, 10],
            optionLabel: (n) => l10n.topN(n),
            onSelected: vm.setTopN,
          ),
        ],
        child: RankingBars(
          labels: [for (final t in top) t.name],
          values: [for (final t in top) fmt.inUnit(t.value)],
          valueLabel: (v) =>
              fmt.unitValue(v, decimals: vm.rankByOneRepMax ? 1 : 0),
        ),
      ),
    ];

    return Column(
      children: [
        for (final (i, chart) in charts.indexed)
          FadeSlideIn(index: i, child: chart),
        const SizedBox(height: AppTheme.space5),
      ],
    );
  }
}
