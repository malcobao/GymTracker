import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../app_theme.dart';

/// The app's chart widgets, built on fl_chart. They take ready-made values
/// (computed by `domain/statistics.dart`) and only draw; every chart
/// animates when its data changes and shows a tooltip on touch.

/// A titled card that holds one chart and the controls that configure it.
class ChartCard extends StatelessWidget {
  const ChartCard({
    required this.title,
    required this.child,
    this.icon,
    this.controls = const [],
    this.footer,
    super.key,
  });

  final String title;
  final IconData? icon;
  final Widget child;

  /// Parameter pickers shown under the title (chips, dropdowns…).
  final List<Widget> controls;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: theme.colorScheme.primary, size: 20),
                  const SizedBox(width: AppTheme.space2),
                ],
                Expanded(
                  child: Text(title, style: theme.textTheme.titleMedium),
                ),
              ],
            ),
            if (controls.isNotEmpty) ...[
              const SizedBox(height: AppTheme.space2),
              Wrap(
                spacing: AppTheme.space2,
                runSpacing: AppTheme.space2,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: controls,
              ),
            ],
            const SizedBox(height: AppTheme.space4),
            child,
            if (footer != null) ...[
              const SizedBox(height: AppTheme.space2),
              footer!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Line chart of values over ordered points (x = index).
class TrendLineChart extends StatelessWidget {
  const TrendLineChart({
    required this.values,
    required this.xLabel,
    required this.valueLabel,
    this.height = 220,
    super.key,
  });

  final List<double> values;

  /// Short label of point [i] for the x axis and the tooltip.
  final String Function(int i) xLabel;
  final String Function(double v) valueLabel;
  final double height;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final maxY = values.isEmpty ? 1.0 : values.reduce(math.max);
    final minY = values.isEmpty ? 0.0 : values.reduce(math.min);
    final pad = math.max((maxY - minY) * 0.15, maxY * 0.05);
    return SizedBox(
      height: height,
      child: LineChart(
        duration: AppTheme.slow,
        curve: Curves.easeOutCubic,
        LineChartData(
          minY: math.max(0, minY - pad),
          maxY: maxY + pad,
          gridData: FlGridData(
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) =>
                FlLine(color: scheme.outlineVariant, strokeWidth: 0.6),
          ),
          borderData: FlBorderData(show: false),
          titlesData: _titles(
            context,
            count: values.length,
            xLabel: xLabel,
            valueLabel: valueLabel,
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => scheme.inverseSurface,
              getTooltipItems: (spots) => [
                for (final s in spots)
                  LineTooltipItem(
                    '${xLabel(s.x.toInt())}\n${valueLabel(s.y)}',
                    TextStyle(color: scheme.onInverseSurface),
                  ),
              ],
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: [
                for (var i = 0; i < values.length; i++)
                  FlSpot(i.toDouble(), values[i]),
              ],
              isCurved: true,
              preventCurveOverShooting: true,
              color: scheme.primary,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(show: values.length <= 30),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    scheme.primary.withValues(alpha: 0.35),
                    scheme.primary.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Vertical bar chart (x = index).
class SimpleBarChart extends StatelessWidget {
  const SimpleBarChart({
    required this.values,
    required this.xLabel,
    required this.valueLabel,
    this.highlightMax = true,
    this.height = 220,
    super.key,
  });

  final List<double> values;
  final String Function(int i) xLabel;
  final String Function(double v) valueLabel;

  /// Paints the largest bar in the accent colour.
  final bool highlightMax;
  final double height;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final maxY = values.isEmpty ? 1.0 : math.max(values.reduce(math.max), 1.0);
    final barWidth = values.isEmpty
        ? 16.0
        : (240 / values.length).clamp(4.0, 28.0);
    return SizedBox(
      height: height,
      child: BarChart(
        duration: AppTheme.slow,
        curve: Curves.easeOutCubic,
        BarChartData(
          maxY: maxY * 1.15,
          gridData: FlGridData(
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) =>
                FlLine(color: scheme.outlineVariant, strokeWidth: 0.6),
          ),
          borderData: FlBorderData(show: false),
          titlesData: _titles(
            context,
            count: values.length,
            xLabel: xLabel,
            valueLabel: valueLabel,
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => scheme.inverseSurface,
              getTooltipItem: (group, _, rod, _) => BarTooltipItem(
                '${xLabel(group.x)}\n${valueLabel(rod.toY)}',
                TextStyle(color: scheme.onInverseSurface),
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < values.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: values[i],
                    width: barWidth,
                    color: highlightMax && values[i] == maxY
                        ? scheme.tertiary
                        : scheme.primary,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(6),
                    ),
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: maxY * 1.15,
                      color: scheme.surfaceContainerHighest.withValues(
                        alpha: 0.4,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// Donut chart with a legend; touching a slice enlarges it.
class DonutChart extends StatefulWidget {
  const DonutChart({
    required this.labels,
    required this.values,
    required this.valueLabel,
    super.key,
  });

  final List<String> labels;
  final List<double> values;
  final String Function(double v) valueLabel;

  @override
  State<DonutChart> createState() => _DonutChartState();
}

class _DonutChartState extends State<DonutChart> {
  int _touched = -1;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = AppTheme.chartPalette(scheme);
    final total = widget.values.fold(0.0, (a, b) => a + b);
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth > 420;
        final chart = SizedBox(
          height: 200,
          width: 200,
          child: PieChart(
            duration: AppTheme.slow,
            curve: Curves.easeOutCubic,
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 48,
              pieTouchData: PieTouchData(
                touchCallback: (event, response) => setState(() {
                  _touched = event.isInterestedForInteractions
                      ? response?.touchedSection?.touchedSectionIndex ?? -1
                      : -1;
                }),
              ),
              sections: [
                for (var i = 0; i < widget.values.length; i++)
                  PieChartSectionData(
                    value: widget.values[i],
                    color: colors[i % colors.length],
                    radius: i == _touched ? 58 : 48,
                    title: total == 0
                        ? ''
                        : '${(widget.values[i] / total * 100).round()}%',
                    showTitle: total > 0 && widget.values[i] / total >= 0.06,
                    titleStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _onColor(colors[i % colors.length]),
                    ),
                  ),
              ],
            ),
          ),
        );
        final legend = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < widget.values.length; i++)
              AnimatedDefaultTextStyle(
                duration: AppTheme.fast,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontWeight: i == _touched ? FontWeight.bold : null,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: colors[i % colors.length],
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: AppTheme.space2),
                      Flexible(
                        child: Text(
                          '${widget.labels[i]} · '
                          '${widget.valueLabel(widget.values[i])}',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
        return wide
            ? Row(
                children: [
                  chart,
                  const SizedBox(width: AppTheme.space5),
                  Expanded(child: legend),
                ],
              )
            : Column(
                children: [
                  Center(child: chart),
                  const SizedBox(height: AppTheme.space4),
                  legend,
                ],
              );
      },
    );
  }

  static Color _onColor(Color c) =>
      ThemeData.estimateBrightnessForColor(c) == Brightness.dark
      ? Colors.white
      : Colors.black;
}

/// Horizontal bars for a ranking; the bars grow in when shown.
class RankingBars extends StatelessWidget {
  const RankingBars({
    required this.labels,
    required this.values,
    required this.valueLabel,
    super.key,
  });

  final List<String> labels;
  final List<double> values;
  final String Function(double v) valueLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = AppTheme.chartPalette(theme.colorScheme);
    final max = values.isEmpty ? 1.0 : math.max(values.reduce(math.max), 1e-9);
    return Column(
      children: [
        for (var i = 0; i < values.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppTheme.space1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('${i + 1}. ', style: theme.textTheme.labelLarge),
                    Expanded(
                      child: Text(labels[i], overflow: TextOverflow.ellipsis),
                    ),
                    Text(
                      valueLabel(values[i]),
                      style: theme.textTheme.labelLarge,
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.space1),
                TweenAnimationBuilder<double>(
                  key: ValueKey('${labels[i]}-${values[i]}'),
                  tween: Tween(begin: 0, end: values[i] / max),
                  duration: AppTheme.slow + Duration(milliseconds: 80 * i),
                  curve: Curves.easeOutCubic,
                  builder: (context, v, _) => ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: v,
                      minHeight: 10,
                      color: colors[i % colors.length],
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Axis titles shared by the line and bar charts: at most ~6 x labels.
FlTitlesData _titles(
  BuildContext context, {
  required int count,
  required String Function(int) xLabel,
  required String Function(double) valueLabel,
}) {
  final style = Theme.of(context).textTheme.labelSmall;
  final step = count <= 8 ? 1 : (count / 6).ceil();
  return FlTitlesData(
    topTitles: const AxisTitles(),
    rightTitles: const AxisTitles(),
    leftTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 40,
        getTitlesWidget: (value, meta) => value == meta.max || value == meta.min
            ? const SizedBox.shrink()
            : SideTitleWidget(
                meta: meta,
                child: Text(
                  NumberFormat.compact(
                    locale: Localizations.localeOf(context).toLanguageTag(),
                  ).format(value),
                  style: style,
                ),
              ),
      ),
    ),
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 28,
        interval: 1,
        getTitlesWidget: (value, meta) {
          final i = value.toInt();
          if (value != i || i < 0 || i >= count || i % step != 0) {
            return const SizedBox.shrink();
          }
          return SideTitleWidget(
            meta: meta,
            child: Text(xLabel(i), style: style),
          );
        },
      ),
    ),
  );
}
