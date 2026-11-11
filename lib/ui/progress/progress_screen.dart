import 'package:flutter/material.dart';

import '../../domain/models/enums.dart';
import '../../domain/models/user_profile.dart' show dateOnly;
import '../../domain/progress_calculator.dart';
import '../../utils/units.dart';
import '../core/view_models/view_state.dart';
import '../core/widgets/empty_view.dart';
import '../core/widgets/error_view.dart';
import '../core/widgets/loading_view.dart';
import 'progress_chart.dart';
import 'progress_view_model.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({
    required this.viewModel,
    required this.exerciseName,
    required this.unit,
    super.key,
  });

  final ProgressViewModel viewModel;
  final String exerciseName;
  final WeightUnit unit;

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.load();
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.viewModel;
    return Scaffold(
      appBar: AppBar(title: Text(widget.exerciseName)),
      body: ListenableBuilder(
        listenable: vm,
        builder: (context, _) => switch (vm.state) {
          Loading() => const LoadingView(),
          Failed(:final message) => ErrorView(
            message: message,
            onRetry: vm.load,
          ),
          Empty() => const EmptyView(
            message: 'No sets logged yet. Train this exercise to see progress.',
          ),
          Loaded(data: final days) => _ProgressBody(
            days: days,
            unit: widget.unit,
          ),
        },
      ),
    );
  }
}

class _ProgressBody extends StatelessWidget {
  const _ProgressBody({required this.days, required this.unit});

  final List<DailyProgress> days;
  final WeightUnit unit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final first = days.first;
    final latest = days.last;
    final best = days
        .map((d) => d.estimatedOneRepMaxKg)
        .reduce((a, b) => a > b ? a : b);
    final change = latest.estimatedOneRepMaxKg - first.estimatedOneRepMaxKg;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _Stat(label: 'Best estimated 1RM', value: Units.format(best, unit)),
            _Stat(
              label: 'Change since first day',
              value:
                  '${change >= 0 ? '+' : '−'}${Units.format(change.abs(), unit)}',
            ),
            _Stat(label: 'Training days', value: '${days.length}'),
          ],
        ),
        const SizedBox(height: 16),
        Text('Estimated 1-rep max per day', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        SizedBox(
          height: 180,
          child: ProgressChart(
            values: [
              for (final d in days) Units.fromKg(d.estimatedOneRepMaxKg, unit),
            ],
            color: theme.colorScheme.primary,
            gridColor: theme.colorScheme.outlineVariant,
            semanticLabel:
                'Estimated one-rep max went from '
                '${Units.format(first.estimatedOneRepMaxKg, unit)} to '
                '${Units.format(latest.estimatedOneRepMaxKg, unit)} '
                'over ${days.length} training days',
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Estimate uses the Epley formula: weight × (1 + reps / 30).',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        Text('History', style: theme.textTheme.titleSmall),
        DataTable(
          columnSpacing: 16,
          columns: const [
            DataColumn(label: Text('Date')),
            DataColumn(label: Text('Top set'), numeric: true),
            DataColumn(label: Text('Est. 1RM'), numeric: true),
            DataColumn(label: Text('Volume'), numeric: true),
          ],
          rows: [
            for (final d in days.reversed)
              DataRow(
                cells: [
                  DataCell(Text(dateOnly(d.date))),
                  DataCell(Text(Units.format(d.topWeightKg, unit))),
                  DataCell(Text(Units.format(d.estimatedOneRepMaxKg, unit))),
                  DataCell(Text(Units.format(d.volumeKg, unit))),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card.outlined(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.textTheme.bodySmall),
            Text(value, style: theme.textTheme.titleLarge),
          ],
        ),
      ),
    );
  }
}
