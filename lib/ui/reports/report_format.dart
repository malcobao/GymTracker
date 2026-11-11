import '../../domain/models/enums.dart';
import '../../domain/reports.dart';
import '../../domain/statistics.dart';
import '../core/labels.dart';

/// Turns typed report cells into text, in the user's language and unit.
class ReportFormatter {
  ReportFormatter(this.l10n, this.fmt, this.grouping);

  final AppLocalizations l10n;
  final Fmt fmt;
  final Grouping grouping;

  String cell(ReportColumn column, Object? value) =>
      switch ((column.kind, value)) {
        (_, null) => '',
        (ColumnKind.date, final DateTime d) =>
          column == ReportColumn.period
              ? fmt.period(d, grouping, l10n)
              : fmt.date(d),
        (ColumnKind.weight, final num v) =>
          column == ReportColumn.volume
              ? fmt.volume(v.toDouble())
              : fmt.weight(v.toDouble()),
        (ColumnKind.integer, final num v) => fmt.number(v, decimals: 0),
        (ColumnKind.muscleGroup, final MuscleGroup g) => l10n.muscle(g),
        _ => value.toString(),
      };

  /// Comma-separated values with a header, quoted where needed, plus the
  /// totals row; opens in Excel or Google Sheets.
  String csv(ReportTable table) {
    String quote(String s) =>
        s.contains(RegExp(r'[",\n]')) ? '"${s.replaceAll('"', '""')}"' : s;
    final lines = [
      table.columns.map((c) => quote(l10n.column(c))).join(','),
      for (final row in table.rows)
        [
          for (var i = 0; i < row.length; i++)
            quote(cell(table.columns[i], row[i])),
        ].join(','),
      if (table.totals case final totals?)
        [
          for (var i = 0; i < totals.length; i++)
            quote(i == 0 ? l10n.total : cell(table.columns[i], totals[i])),
        ].join(','),
    ];
    return lines.join('\n');
  }
}
