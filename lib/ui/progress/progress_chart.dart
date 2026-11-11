import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A minimal line chart (no extra package): one point per training day,
/// evenly spaced, with the y-axis fitted to the data.
class ProgressChart extends StatelessWidget {
  const ProgressChart({
    required this.values,
    required this.color,
    required this.gridColor,
    required this.semanticLabel,
    super.key,
  });

  final List<double> values;
  final Color color;
  final Color gridColor;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      child: CustomPaint(
        size: Size.infinite,
        painter: _LinePainter(
          values: values,
          color: color,
          gridColor: gridColor,
          textStyle: Theme.of(context).textTheme.bodySmall!,
        ),
      ),
    );
  }
}

class _LinePainter extends CustomPainter {
  _LinePainter({
    required this.values,
    required this.color,
    required this.gridColor,
    required this.textStyle,
  });

  final List<double> values;
  final Color color;
  final Color gridColor;
  final TextStyle textStyle;

  static const _leftPad = 44.0;
  static const _vPad = 8.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    var lo = values.reduce(math.min);
    var hi = values.reduce(math.max);
    if (hi - lo < 1) {
      lo -= 1;
      hi += 1;
    }
    final width = size.width - _leftPad;
    final height = size.height - 2 * _vPad;
    double x(int i) =>
        _leftPad +
        (values.length == 1 ? width / 2 : width * i / (values.length - 1));
    double y(double v) => _vPad + height * (1 - (v - lo) / (hi - lo));

    final grid = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (final v in [lo, (lo + hi) / 2, hi]) {
      canvas.drawLine(Offset(_leftPad, y(v)), Offset(size.width, y(v)), grid);
      final label = TextPainter(
        text: TextSpan(text: v.toStringAsFixed(0), style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      label.paint(canvas, Offset(0, y(v) - label.height / 2));
    }

    final line = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    final path = Path()..moveTo(x(0), y(values.first));
    for (var i = 1; i < values.length; i++) {
      path.lineTo(x(i), y(values[i]));
    }
    canvas.drawPath(path, line);
    final dot = Paint()..color = color;
    for (var i = 0; i < values.length; i++) {
      canvas.drawCircle(Offset(x(i), y(values[i])), 3.5, dot);
    }
  }

  @override
  bool shouldRepaint(_LinePainter old) =>
      old.values != values || old.color != color;
}
