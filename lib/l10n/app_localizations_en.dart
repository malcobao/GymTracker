// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Gym Tracker';

  @override
  String get navRoutines => 'Routines';

  @override
  String get navStatistics => 'Statistics';

  @override
  String get navReports => 'Reports';

  @override
  String get navSettings => 'Settings';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get create => 'Create';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get archive => 'Archive';

  @override
  String get restore => 'Restore';

  @override
  String get tryAgain => 'Try again';

  @override
  String get loading => 'Loading';

  @override
  String get nameLabel => 'Name';

  @override
  String get descriptionLabel => 'Description (optional)';

  @override
  String get errRequired => 'This field is required';

  @override
  String errTooLong(int max) {
    return 'Use at most $max characters';
  }

  @override
  String get errNotANumber => 'Enter a number';

  @override
  String get errNotWholeNumber => 'Enter a whole number';

  @override
  String errOutOfRange(num min, num max) {
    final intl.NumberFormat minNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String minString = minNumberFormat.format(min);
    final intl.NumberFormat maxNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String maxString = maxNumberFormat.format(max);

    return 'Must be between $minString and $maxString';
  }

  @override
  String get errDuplicateName => 'That name already exists';

  @override
  String errAgeRange(int min, int max) {
    return 'Age must be between $min and $max years';
  }

  @override
  String get errorDuplicate => 'That name is already in use.';

  @override
  String get errorInvalidData => 'Some values are out of the allowed range.';

  @override
  String errorInUse(int count) {
    return 'It has $count logged sets.';
  }

  @override
  String get errorNotFound => 'That item no longer exists.';

  @override
  String get errorStorage => 'Could not access the local database.';

  @override
  String get sexMale => 'Male';

  @override
  String get sexFemale => 'Female';

  @override
  String get sexUnspecified => 'Prefer not to say';

  @override
  String get levelBeginner => 'Beginner';

  @override
  String get levelIntermediate => 'Intermediate';

  @override
  String get levelAdvanced => 'Advanced';

  @override
  String get goalStrength => 'Get stronger';

  @override
  String get goalMuscleGain => 'Build muscle';

  @override
  String get goalFatLoss => 'Lose fat';

  @override
  String get goalGeneralFitness => 'General fitness';

  @override
  String get muscleChest => 'Chest';

  @override
  String get muscleBack => 'Back';

  @override
  String get muscleShoulders => 'Shoulders';

  @override
  String get muscleBiceps => 'Biceps';

  @override
  String get muscleTriceps => 'Triceps';

  @override
  String get muscleLegs => 'Legs';

  @override
  String get muscleGlutes => 'Glutes';

  @override
  String get muscleCore => 'Core';

  @override
  String get muscleFullBody => 'Full body';

  @override
  String get muscleOther => 'Other';

  @override
  String get muscleNone => 'No muscle group';

  @override
  String get onboardingTitle => 'Tell us about you';

  @override
  String get onboardingIntro =>
      'Used to personalise your training. You can change it any time.';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get birthDate => 'Birth date';

  @override
  String get chooseDate => 'Choose a date';

  @override
  String get sex => 'Sex';

  @override
  String get height => 'Height';

  @override
  String get bodyWeight => 'Body weight';

  @override
  String get experience => 'Experience';

  @override
  String get mainGoal => 'Main goal';

  @override
  String get startTraining => 'Start training';

  @override
  String get profileSaved => 'Profile saved';

  @override
  String ageAndBmi(int age, String bmi) {
    return '$age years · BMI $bmi';
  }

  @override
  String get myRoutines => 'My routines';

  @override
  String get archivedRoutines => 'Archived routines';

  @override
  String get showArchived => 'Show archived';

  @override
  String get routineFab => 'Routine';

  @override
  String get noRoutines =>
      'No routines yet. Create your first one, such as \"Push day\".';

  @override
  String get noArchivedRoutines => 'No archived routines.';

  @override
  String get createRoutine => 'Create routine';

  @override
  String get newRoutine => 'New routine';

  @override
  String get editRoutine => 'Edit routine';

  @override
  String exerciseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count exercises',
      one: '1 exercise',
      zero: 'No exercises',
    );
    return '$_temp0';
  }

  @override
  String get routineCreated => 'Routine created';

  @override
  String get routineUpdated => 'Routine updated';

  @override
  String get routineArchived => 'Routine archived';

  @override
  String get routineRestored => 'Routine restored';

  @override
  String get routineDeleted => 'Routine deleted';

  @override
  String deleteTitle(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get deleteRoutineMessage =>
      'The routine and its exercises are deleted for good.';

  @override
  String get deleteExerciseMessage => 'The exercise is deleted for good.';

  @override
  String inUseTitle(String name) {
    return '\"$name\" has history';
  }

  @override
  String inUseMessage(int count) {
    return 'The database blocked the delete: $count logged sets depend on it (referential integrity). Archive it to hide it and keep the history, or delete it together with all its sets.';
  }

  @override
  String get deleteEverything => 'Delete everything';

  @override
  String get addExercise => 'Add exercise';

  @override
  String get editExercise => 'Edit exercise';

  @override
  String get noExercises => 'This routine has no exercises yet.';

  @override
  String get noArchivedExercises => 'No archived exercises.';

  @override
  String get archivedExercises => 'Archived exercises';

  @override
  String get startWorkout => 'Start today\'s workout';

  @override
  String get progressTooltip => 'Progress';

  @override
  String get moreOptions => 'More options';

  @override
  String get exerciseNameHint => 'Name, e.g. Bench press';

  @override
  String get muscleGroupOptional => 'Muscle group (optional)';

  @override
  String get targetSets => 'Target sets';

  @override
  String get targetReps => 'Target reps';

  @override
  String targetLabel(int sets, int reps) {
    return '$sets × $reps';
  }

  @override
  String targetSetsOnly(int sets) {
    return '$sets sets';
  }

  @override
  String targetRepsOnly(int reps) {
    return '$reps reps';
  }

  @override
  String get exerciseAdded => 'Exercise added';

  @override
  String get exerciseUpdated => 'Exercise updated';

  @override
  String get exerciseArchived => 'Exercise archived';

  @override
  String get exerciseRestored => 'Exercise restored';

  @override
  String get exerciseDeleted => 'Exercise deleted';

  @override
  String workoutOf(String date) {
    return 'Workout of $date';
  }

  @override
  String get weight => 'Weight';

  @override
  String get reps => 'Reps';

  @override
  String get logSet => 'Log set';

  @override
  String setLogged(int number) {
    return 'Set $number logged';
  }

  @override
  String setDeleted(int number) {
    return 'Set $number deleted';
  }

  @override
  String get setUpdated => 'Set updated';

  @override
  String editSet(int number) {
    return 'Edit set $number';
  }

  @override
  String deleteSet(int number) {
    return 'Delete set $number';
  }

  @override
  String get noExercisesWorkout => 'Add exercises to this routine first.';

  @override
  String targetPrefix(String target) {
    return 'Target: $target';
  }

  @override
  String get bestOneRepMax => 'Best estimated 1RM';

  @override
  String get changeSinceFirst => 'Change since first day';

  @override
  String get trainingDays => 'Training days';

  @override
  String get oneRepMaxPerDay => 'Estimated 1-rep max per day';

  @override
  String get epleyNote =>
      'Estimate uses the Epley formula: weight × (1 + reps / 30).';

  @override
  String get history => 'History';

  @override
  String get date => 'Date';

  @override
  String get topSet => 'Top set';

  @override
  String get estimated1rm => 'Est. 1RM';

  @override
  String get volume => 'Volume';

  @override
  String get noSetsForExercise => 'No sets logged for this exercise yet.';

  @override
  String get period => 'Period';

  @override
  String get last7Days => 'Last 7 days';

  @override
  String get last30Days => 'Last 30 days';

  @override
  String get last90Days => 'Last 90 days';

  @override
  String get lastYear => 'Last 12 months';

  @override
  String get allTime => 'All time';

  @override
  String get customRange => 'Custom range…';

  @override
  String get routine => 'Routine';

  @override
  String get allRoutines => 'All routines';

  @override
  String get exercise => 'Exercise';

  @override
  String get allExercises => 'All exercises';

  @override
  String get muscleGroup => 'Muscle group';

  @override
  String get allMuscleGroups => 'All muscle groups';

  @override
  String get filters => 'Filters';

  @override
  String get archivedTag => 'archived';

  @override
  String get statsSets => 'Sets';

  @override
  String get statsReps => 'Reps';

  @override
  String get statsVolume => 'Total volume';

  @override
  String get statsAvgVolume => 'Avg volume / session';

  @override
  String get statsAvgSets => 'Avg sets / session';

  @override
  String get statsStreak => 'Week streak';

  @override
  String statsWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count weeks',
      one: '1 week',
    );
    return '$_temp0';
  }

  @override
  String get chartOverTime => 'Progress over time';

  @override
  String get metric => 'Metric';

  @override
  String get groupBy => 'Group by';

  @override
  String get groupDay => 'Day';

  @override
  String get groupWeek => 'Week';

  @override
  String get groupMonth => 'Month';

  @override
  String get chartOneRepMax => 'Estimated 1RM progress';

  @override
  String get chooseExercise => 'Choose an exercise';

  @override
  String get chartMuscleGroups => 'Distribution by muscle group';

  @override
  String get chartWeekdays => 'Training days by weekday';

  @override
  String get chartTopExercises => 'Top exercises';

  @override
  String get rankBy => 'Rank by';

  @override
  String get rankOneRepMax => 'Best 1RM';

  @override
  String topN(int count) {
    return 'Top $count';
  }

  @override
  String get noData =>
      'No sets in this selection. Log a workout or load the sample data in Settings.';

  @override
  String get noDataExercise => 'No sets of this exercise in the period.';

  @override
  String get reportType => 'Report';

  @override
  String get reportSetLog => 'Set log';

  @override
  String get reportByExercise => 'Summary by exercise';

  @override
  String get reportByPeriod => 'Summary by period';

  @override
  String get reportRecords => 'Personal records';

  @override
  String get reportSetLogInfo => 'Every logged set, one row each.';

  @override
  String get reportByExerciseInfo =>
      'Days, sets, reps, volume and best lifts per exercise.';

  @override
  String get reportByPeriodInfo =>
      'Your training grouped by day, week or month.';

  @override
  String get reportRecordsInfo =>
      'Heaviest weight and best estimated 1RM per exercise, with dates.';

  @override
  String get show => 'Show';

  @override
  String get order => 'Order';

  @override
  String get sortBy => 'Sort by';

  @override
  String get ascending => 'Ascending';

  @override
  String get descending => 'Descending';

  @override
  String rowCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rows',
      one: '1 row',
    );
    return '$_temp0';
  }

  @override
  String get total => 'Total';

  @override
  String get copyCsv => 'Copy as CSV';

  @override
  String get csvCopied =>
      'Report copied as CSV. Paste it into Excel or Google Sheets.';

  @override
  String get colDate => 'Date';

  @override
  String get colPeriod => 'Period';

  @override
  String get colRoutine => 'Routine';

  @override
  String get colExercise => 'Exercise';

  @override
  String get colMuscleGroup => 'Muscle group';

  @override
  String get colSetNumber => 'Set';

  @override
  String get colWeight => 'Weight';

  @override
  String get colReps => 'Reps';

  @override
  String get colVolume => 'Volume';

  @override
  String get colSets => 'Sets';

  @override
  String get colDays => 'Days';

  @override
  String get colTopWeight => 'Top weight';

  @override
  String get colTopWeightDate => 'Top weight date';

  @override
  String get colBestOneRepMax => 'Best est. 1RM';

  @override
  String get colBestOneRepMaxDate => '1RM date';

  @override
  String weekOf(String date) {
    return 'Week of $date';
  }

  @override
  String get profileSection => 'Profile';

  @override
  String get appearance => 'Appearance';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'Automatic';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get accentColor => 'Accent color';

  @override
  String get weightUnit => 'Weight unit';

  @override
  String get databaseSection => 'Local database (SQLite)';

  @override
  String get databaseInfo =>
      'Everything is stored on this device in four related tables.';

  @override
  String tableRows(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rows',
      one: '1 row',
    );
    return '$_temp0';
  }

  @override
  String get tableProfile => 'profile — your profile';

  @override
  String get tableRoutines => 'routines — training plans';

  @override
  String get tableExercises => 'exercises — exercises of each routine';

  @override
  String get tableSets => 'workout_sets — every set lifted';

  @override
  String get loadSampleData => 'Load sample data';

  @override
  String get loadSampleDataInfo =>
      'Adds 3 routines and 8 weeks of workouts to try the statistics and reports.';

  @override
  String get sampleDataLoaded => 'Sample data loaded';

  @override
  String get deleteAllData => 'Delete all data';

  @override
  String get deleteAllDataMessage =>
      'Every routine, exercise, set and your profile are deleted from this device. This cannot be undone.';

  @override
  String get about => 'About';

  @override
  String get aboutText =>
      'Personal gym tracker. Works offline; your data never leaves this device.';
}
