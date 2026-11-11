import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../data/errors/app_exception.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/exercise.dart';
import '../../domain/reports.dart';
import '../../domain/statistics.dart';
import '../../domain/validation.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/units.dart';
import 'view_models/session_controller.dart';

export '../../l10n/app_localizations.dart';

/// Shortcuts: `context.l10n` for texts, `context.fmt` for numbers and dates
/// in the current language and weight unit.
extension ContextL10n on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
  Fmt get fmt => Fmt(
    Localizations.localeOf(this).toLanguageTag(),
    watch<SessionController>().unit,
  );

  /// Like [fmt], for callbacks (outside `build`).
  Fmt get fmtNow => Fmt(
    Localizations.localeOf(this).toLanguageTag(),
    read<SessionController>().unit,
  );
}

/// Formats numbers, weights and dates for one locale and weight unit.
class Fmt {
  Fmt(this.locale, this.unit);

  final String locale;
  final WeightUnit unit;

  /// Up to [decimals] decimals, grouped thousands: "1,250.5" / "1.250,5".
  String number(num value, {int decimals = 1}) => (NumberFormat.decimalPattern(
    locale,
  )..maximumFractionDigits = decimals).format(value);

  /// Weight stored in kg, shown in the user's unit: "62.5 kg" / "137.8 lb".
  String weight(double kg, {int decimals = 1}) =>
      '${number(Units.fromKg(kg, unit), decimals: decimals)} ${unit.dbValue}';

  /// [kg] converted to the user's unit (charts plot these values).
  double inUnit(double kg) => Units.fromKg(kg, unit);

  /// A value already in the user's unit, with the unit: "137.8 lb".
  String unitValue(double value, {int decimals = 1}) =>
      '${number(value, decimals: decimals)} ${unit.dbValue}';

  /// Large weights without decimals: "12,340 kg".
  String volume(double kg) => weight(kg, decimals: 0);

  String date(DateTime d) => DateFormat.yMMMd(locale).format(d);
  String shortDate(DateTime d) => DateFormat.MMMd(locale).format(d);
  String weekdayShort(int weekday) =>
      DateFormat.E(locale)
          .format(DateTime(2024, 1, weekday)); // 2024-01-01 = Monday

  String period(DateTime start, Grouping grouping, AppLocalizations l10n) =>
      switch (grouping) {
        Grouping.day => date(start),
        Grouping.week => l10n.weekOf(shortDate(start)),
        Grouping.month => DateFormat.yMMM(locale).format(start),
      };
}

/// Translated names of enums, errors and validation results.
extension Labels on AppLocalizations {
  String sexLabel(Sex value) => switch (value) {
    Sex.male => sexMale,
    Sex.female => sexFemale,
    Sex.unspecified => sexUnspecified,
  };

  String level(ExperienceLevel value) => switch (value) {
    ExperienceLevel.beginner => levelBeginner,
    ExperienceLevel.intermediate => levelIntermediate,
    ExperienceLevel.advanced => levelAdvanced,
  };

  String goal(Goal value) => switch (value) {
    Goal.strength => goalStrength,
    Goal.muscleGain => goalMuscleGain,
    Goal.fatLoss => goalFatLoss,
    Goal.generalFitness => goalGeneralFitness,
  };

  String muscle(MuscleGroup? value) => switch (value) {
    null => muscleNone,
    MuscleGroup.chest => muscleChest,
    MuscleGroup.back => muscleBack,
    MuscleGroup.shoulders => muscleShoulders,
    MuscleGroup.biceps => muscleBiceps,
    MuscleGroup.triceps => muscleTriceps,
    MuscleGroup.legs => muscleLegs,
    MuscleGroup.glutes => muscleGlutes,
    MuscleGroup.core => muscleCore,
    MuscleGroup.fullBody => muscleFullBody,
    MuscleGroup.other => muscleOther,
  };

  String metricLabel(Metric value) => switch (value) {
    Metric.volume => volume,
    Metric.sets => statsSets,
    Metric.reps => statsReps,
  };

  String grouping(Grouping value) => switch (value) {
    Grouping.day => groupDay,
    Grouping.week => groupWeek,
    Grouping.month => groupMonth,
  };

  String reportTypeLabel(ReportType value) => switch (value) {
    ReportType.setLog => reportSetLog,
    ReportType.byExercise => reportByExercise,
    ReportType.byPeriod => reportByPeriod,
    ReportType.personalRecords => reportRecords,
  };

  String reportInfo(ReportType value) => switch (value) {
    ReportType.setLog => reportSetLogInfo,
    ReportType.byExercise => reportByExerciseInfo,
    ReportType.byPeriod => reportByPeriodInfo,
    ReportType.personalRecords => reportRecordsInfo,
  };

  String column(ReportColumn value) => switch (value) {
    ReportColumn.date => colDate,
    ReportColumn.period => colPeriod,
    ReportColumn.routine => colRoutine,
    ReportColumn.exercise => colExercise,
    ReportColumn.muscleGroup => colMuscleGroup,
    ReportColumn.setNumber => colSetNumber,
    ReportColumn.weight => colWeight,
    ReportColumn.reps => colReps,
    ReportColumn.volume => colVolume,
    ReportColumn.sets => colSets,
    ReportColumn.days => colDays,
    ReportColumn.topWeight => colTopWeight,
    ReportColumn.topWeightDate => colTopWeightDate,
    ReportColumn.bestOneRepMax => colBestOneRepMax,
    ReportColumn.bestOneRepMaxDate => colBestOneRepMaxDate,
  };

  /// "3 × 8", "3 sets", "8 reps" or null when the exercise has no target.
  String? target(Exercise e) => switch ((e.targetSets, e.targetReps)) {
    (final int s, final int r) => targetLabel(s, r),
    (final int s, null) => targetSetsOnly(s),
    (null, final int r) => targetRepsOnly(r),
    (null, null) => null,
  };

  /// The message for a failed repository call.
  String error(Exception error) => switch (error) {
    DuplicateException() => errorDuplicate,
    InvalidDataException() => errorInvalidData,
    InUseException(:final setCount) => errorInUse(setCount),
    NotFoundException() => errorNotFound,
    _ => errorStorage,
  };

  /// The message for a field that failed validation (null when valid).
  String? field(FieldError? error) => switch (error) {
    null => null,
    FieldError(code: FieldErrorCode.required) => errRequired,
    FieldError(code: FieldErrorCode.tooLong, :final max) => errTooLong(
      max!.toInt(),
    ),
    FieldError(code: FieldErrorCode.notANumber) => errNotANumber,
    FieldError(code: FieldErrorCode.notAWholeNumber) => errNotWholeNumber,
    FieldError(code: FieldErrorCode.outOfRange, :final min, :final max) =>
      errOutOfRange(min!, max!),
    FieldError(code: FieldErrorCode.duplicate) => errDuplicateName,
  };
}
