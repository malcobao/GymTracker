import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Gym Tracker'**
  String get appTitle;

  /// No description provided for @navRoutines.
  ///
  /// In en, this message translates to:
  /// **'Routines'**
  String get navRoutines;

  /// No description provided for @navStatistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get navStatistics;

  /// No description provided for @navReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get navReports;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @archive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archive;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @descriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get descriptionLabel;

  /// No description provided for @errRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get errRequired;

  /// No description provided for @errTooLong.
  ///
  /// In en, this message translates to:
  /// **'Use at most {max} characters'**
  String errTooLong(int max);

  /// No description provided for @errNotANumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a number'**
  String get errNotANumber;

  /// No description provided for @errNotWholeNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a whole number'**
  String get errNotWholeNumber;

  /// No description provided for @errOutOfRange.
  ///
  /// In en, this message translates to:
  /// **'Must be between {min} and {max}'**
  String errOutOfRange(num min, num max);

  /// No description provided for @errDuplicateName.
  ///
  /// In en, this message translates to:
  /// **'That name already exists'**
  String get errDuplicateName;

  /// No description provided for @errAgeRange.
  ///
  /// In en, this message translates to:
  /// **'Age must be between {min} and {max} years'**
  String errAgeRange(int min, int max);

  /// No description provided for @errorDuplicate.
  ///
  /// In en, this message translates to:
  /// **'That name is already in use.'**
  String get errorDuplicate;

  /// No description provided for @errorInvalidData.
  ///
  /// In en, this message translates to:
  /// **'Some values are out of the allowed range.'**
  String get errorInvalidData;

  /// No description provided for @errorInUse.
  ///
  /// In en, this message translates to:
  /// **'It has {count} logged sets.'**
  String errorInUse(int count);

  /// No description provided for @errorNotFound.
  ///
  /// In en, this message translates to:
  /// **'That item no longer exists.'**
  String get errorNotFound;

  /// No description provided for @errorStorage.
  ///
  /// In en, this message translates to:
  /// **'Could not access the local database.'**
  String get errorStorage;

  /// No description provided for @sexMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get sexMale;

  /// No description provided for @sexFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get sexFemale;

  /// No description provided for @sexUnspecified.
  ///
  /// In en, this message translates to:
  /// **'Prefer not to say'**
  String get sexUnspecified;

  /// No description provided for @levelBeginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get levelBeginner;

  /// No description provided for @levelIntermediate.
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get levelIntermediate;

  /// No description provided for @levelAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get levelAdvanced;

  /// No description provided for @goalStrength.
  ///
  /// In en, this message translates to:
  /// **'Get stronger'**
  String get goalStrength;

  /// No description provided for @goalMuscleGain.
  ///
  /// In en, this message translates to:
  /// **'Build muscle'**
  String get goalMuscleGain;

  /// No description provided for @goalFatLoss.
  ///
  /// In en, this message translates to:
  /// **'Lose fat'**
  String get goalFatLoss;

  /// No description provided for @goalGeneralFitness.
  ///
  /// In en, this message translates to:
  /// **'General fitness'**
  String get goalGeneralFitness;

  /// No description provided for @muscleChest.
  ///
  /// In en, this message translates to:
  /// **'Chest'**
  String get muscleChest;

  /// No description provided for @muscleBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get muscleBack;

  /// No description provided for @muscleShoulders.
  ///
  /// In en, this message translates to:
  /// **'Shoulders'**
  String get muscleShoulders;

  /// No description provided for @muscleBiceps.
  ///
  /// In en, this message translates to:
  /// **'Biceps'**
  String get muscleBiceps;

  /// No description provided for @muscleTriceps.
  ///
  /// In en, this message translates to:
  /// **'Triceps'**
  String get muscleTriceps;

  /// No description provided for @muscleLegs.
  ///
  /// In en, this message translates to:
  /// **'Legs'**
  String get muscleLegs;

  /// No description provided for @muscleGlutes.
  ///
  /// In en, this message translates to:
  /// **'Glutes'**
  String get muscleGlutes;

  /// No description provided for @muscleCore.
  ///
  /// In en, this message translates to:
  /// **'Core'**
  String get muscleCore;

  /// No description provided for @muscleFullBody.
  ///
  /// In en, this message translates to:
  /// **'Full body'**
  String get muscleFullBody;

  /// No description provided for @muscleOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get muscleOther;

  /// No description provided for @muscleNone.
  ///
  /// In en, this message translates to:
  /// **'No muscle group'**
  String get muscleNone;

  /// No description provided for @onboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us about you'**
  String get onboardingTitle;

  /// No description provided for @onboardingIntro.
  ///
  /// In en, this message translates to:
  /// **'Used to personalise your training. You can change it any time.'**
  String get onboardingIntro;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfile;

  /// No description provided for @birthDate.
  ///
  /// In en, this message translates to:
  /// **'Birth date'**
  String get birthDate;

  /// No description provided for @chooseDate.
  ///
  /// In en, this message translates to:
  /// **'Choose a date'**
  String get chooseDate;

  /// No description provided for @sex.
  ///
  /// In en, this message translates to:
  /// **'Sex'**
  String get sex;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// No description provided for @bodyWeight.
  ///
  /// In en, this message translates to:
  /// **'Body weight'**
  String get bodyWeight;

  /// No description provided for @experience.
  ///
  /// In en, this message translates to:
  /// **'Experience'**
  String get experience;

  /// No description provided for @mainGoal.
  ///
  /// In en, this message translates to:
  /// **'Main goal'**
  String get mainGoal;

  /// No description provided for @startTraining.
  ///
  /// In en, this message translates to:
  /// **'Start training'**
  String get startTraining;

  /// No description provided for @profileSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile saved'**
  String get profileSaved;

  /// No description provided for @ageAndBmi.
  ///
  /// In en, this message translates to:
  /// **'{age} years · BMI {bmi}'**
  String ageAndBmi(int age, String bmi);

  /// No description provided for @myRoutines.
  ///
  /// In en, this message translates to:
  /// **'My routines'**
  String get myRoutines;

  /// No description provided for @archivedRoutines.
  ///
  /// In en, this message translates to:
  /// **'Archived routines'**
  String get archivedRoutines;

  /// No description provided for @showArchived.
  ///
  /// In en, this message translates to:
  /// **'Show archived'**
  String get showArchived;

  /// No description provided for @routineFab.
  ///
  /// In en, this message translates to:
  /// **'Routine'**
  String get routineFab;

  /// No description provided for @noRoutines.
  ///
  /// In en, this message translates to:
  /// **'No routines yet. Create your first one, such as \"Push day\".'**
  String get noRoutines;

  /// No description provided for @noArchivedRoutines.
  ///
  /// In en, this message translates to:
  /// **'No archived routines.'**
  String get noArchivedRoutines;

  /// No description provided for @createRoutine.
  ///
  /// In en, this message translates to:
  /// **'Create routine'**
  String get createRoutine;

  /// No description provided for @newRoutine.
  ///
  /// In en, this message translates to:
  /// **'New routine'**
  String get newRoutine;

  /// No description provided for @editRoutine.
  ///
  /// In en, this message translates to:
  /// **'Edit routine'**
  String get editRoutine;

  /// No description provided for @exerciseCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No exercises} =1{1 exercise} other{{count} exercises}}'**
  String exerciseCount(int count);

  /// No description provided for @routineCreated.
  ///
  /// In en, this message translates to:
  /// **'Routine created'**
  String get routineCreated;

  /// No description provided for @routineUpdated.
  ///
  /// In en, this message translates to:
  /// **'Routine updated'**
  String get routineUpdated;

  /// No description provided for @routineArchived.
  ///
  /// In en, this message translates to:
  /// **'Routine archived'**
  String get routineArchived;

  /// No description provided for @routineRestored.
  ///
  /// In en, this message translates to:
  /// **'Routine restored'**
  String get routineRestored;

  /// No description provided for @routineDeleted.
  ///
  /// In en, this message translates to:
  /// **'Routine deleted'**
  String get routineDeleted;

  /// No description provided for @deleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"?'**
  String deleteTitle(String name);

  /// No description provided for @deleteRoutineMessage.
  ///
  /// In en, this message translates to:
  /// **'The routine and its exercises are deleted for good.'**
  String get deleteRoutineMessage;

  /// No description provided for @deleteExerciseMessage.
  ///
  /// In en, this message translates to:
  /// **'The exercise is deleted for good.'**
  String get deleteExerciseMessage;

  /// No description provided for @inUseTitle.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" has history'**
  String inUseTitle(String name);

  /// No description provided for @inUseMessage.
  ///
  /// In en, this message translates to:
  /// **'The database blocked the delete: {count} logged sets depend on it (referential integrity). Archive it to hide it and keep the history, or delete it together with all its sets.'**
  String inUseMessage(int count);

  /// No description provided for @deleteEverything.
  ///
  /// In en, this message translates to:
  /// **'Delete everything'**
  String get deleteEverything;

  /// No description provided for @addExercise.
  ///
  /// In en, this message translates to:
  /// **'Add exercise'**
  String get addExercise;

  /// No description provided for @editExercise.
  ///
  /// In en, this message translates to:
  /// **'Edit exercise'**
  String get editExercise;

  /// No description provided for @noExercises.
  ///
  /// In en, this message translates to:
  /// **'This routine has no exercises yet.'**
  String get noExercises;

  /// No description provided for @noArchivedExercises.
  ///
  /// In en, this message translates to:
  /// **'No archived exercises.'**
  String get noArchivedExercises;

  /// No description provided for @archivedExercises.
  ///
  /// In en, this message translates to:
  /// **'Archived exercises'**
  String get archivedExercises;

  /// No description provided for @startWorkout.
  ///
  /// In en, this message translates to:
  /// **'Start today\'s workout'**
  String get startWorkout;

  /// No description provided for @progressTooltip.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progressTooltip;

  /// No description provided for @moreOptions.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get moreOptions;

  /// No description provided for @exerciseNameHint.
  ///
  /// In en, this message translates to:
  /// **'Name, e.g. Bench press'**
  String get exerciseNameHint;

  /// No description provided for @muscleGroupOptional.
  ///
  /// In en, this message translates to:
  /// **'Muscle group (optional)'**
  String get muscleGroupOptional;

  /// No description provided for @targetSets.
  ///
  /// In en, this message translates to:
  /// **'Target sets'**
  String get targetSets;

  /// No description provided for @targetReps.
  ///
  /// In en, this message translates to:
  /// **'Target reps'**
  String get targetReps;

  /// No description provided for @targetLabel.
  ///
  /// In en, this message translates to:
  /// **'{sets} × {reps}'**
  String targetLabel(int sets, int reps);

  /// No description provided for @targetSetsOnly.
  ///
  /// In en, this message translates to:
  /// **'{sets} sets'**
  String targetSetsOnly(int sets);

  /// No description provided for @targetRepsOnly.
  ///
  /// In en, this message translates to:
  /// **'{reps} reps'**
  String targetRepsOnly(int reps);

  /// No description provided for @exerciseAdded.
  ///
  /// In en, this message translates to:
  /// **'Exercise added'**
  String get exerciseAdded;

  /// No description provided for @exerciseUpdated.
  ///
  /// In en, this message translates to:
  /// **'Exercise updated'**
  String get exerciseUpdated;

  /// No description provided for @exerciseArchived.
  ///
  /// In en, this message translates to:
  /// **'Exercise archived'**
  String get exerciseArchived;

  /// No description provided for @exerciseRestored.
  ///
  /// In en, this message translates to:
  /// **'Exercise restored'**
  String get exerciseRestored;

  /// No description provided for @exerciseDeleted.
  ///
  /// In en, this message translates to:
  /// **'Exercise deleted'**
  String get exerciseDeleted;

  /// No description provided for @workoutOf.
  ///
  /// In en, this message translates to:
  /// **'Workout of {date}'**
  String workoutOf(String date);

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @reps.
  ///
  /// In en, this message translates to:
  /// **'Reps'**
  String get reps;

  /// No description provided for @logSet.
  ///
  /// In en, this message translates to:
  /// **'Log set'**
  String get logSet;

  /// No description provided for @setLogged.
  ///
  /// In en, this message translates to:
  /// **'Set {number} logged'**
  String setLogged(int number);

  /// No description provided for @setDeleted.
  ///
  /// In en, this message translates to:
  /// **'Set {number} deleted'**
  String setDeleted(int number);

  /// No description provided for @setUpdated.
  ///
  /// In en, this message translates to:
  /// **'Set updated'**
  String get setUpdated;

  /// No description provided for @editSet.
  ///
  /// In en, this message translates to:
  /// **'Edit set {number}'**
  String editSet(int number);

  /// No description provided for @deleteSet.
  ///
  /// In en, this message translates to:
  /// **'Delete set {number}'**
  String deleteSet(int number);

  /// No description provided for @noExercisesWorkout.
  ///
  /// In en, this message translates to:
  /// **'Add exercises to this routine first.'**
  String get noExercisesWorkout;

  /// No description provided for @targetPrefix.
  ///
  /// In en, this message translates to:
  /// **'Target: {target}'**
  String targetPrefix(String target);

  /// No description provided for @bestOneRepMax.
  ///
  /// In en, this message translates to:
  /// **'Best estimated 1RM'**
  String get bestOneRepMax;

  /// No description provided for @changeSinceFirst.
  ///
  /// In en, this message translates to:
  /// **'Change since first day'**
  String get changeSinceFirst;

  /// No description provided for @trainingDays.
  ///
  /// In en, this message translates to:
  /// **'Training days'**
  String get trainingDays;

  /// No description provided for @oneRepMaxPerDay.
  ///
  /// In en, this message translates to:
  /// **'Estimated 1-rep max per day'**
  String get oneRepMaxPerDay;

  /// No description provided for @epleyNote.
  ///
  /// In en, this message translates to:
  /// **'Estimate uses the Epley formula: weight × (1 + reps / 30).'**
  String get epleyNote;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @topSet.
  ///
  /// In en, this message translates to:
  /// **'Top set'**
  String get topSet;

  /// No description provided for @estimated1rm.
  ///
  /// In en, this message translates to:
  /// **'Est. 1RM'**
  String get estimated1rm;

  /// No description provided for @volume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get volume;

  /// No description provided for @noSetsForExercise.
  ///
  /// In en, this message translates to:
  /// **'No sets logged for this exercise yet.'**
  String get noSetsForExercise;

  /// No description provided for @period.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get period;

  /// No description provided for @last7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get last7Days;

  /// No description provided for @last30Days.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get last30Days;

  /// No description provided for @last90Days.
  ///
  /// In en, this message translates to:
  /// **'Last 90 days'**
  String get last90Days;

  /// No description provided for @lastYear.
  ///
  /// In en, this message translates to:
  /// **'Last 12 months'**
  String get lastYear;

  /// No description provided for @allTime.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get allTime;

  /// No description provided for @customRange.
  ///
  /// In en, this message translates to:
  /// **'Custom range…'**
  String get customRange;

  /// No description provided for @routine.
  ///
  /// In en, this message translates to:
  /// **'Routine'**
  String get routine;

  /// No description provided for @allRoutines.
  ///
  /// In en, this message translates to:
  /// **'All routines'**
  String get allRoutines;

  /// No description provided for @exercise.
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get exercise;

  /// No description provided for @allExercises.
  ///
  /// In en, this message translates to:
  /// **'All exercises'**
  String get allExercises;

  /// No description provided for @muscleGroup.
  ///
  /// In en, this message translates to:
  /// **'Muscle group'**
  String get muscleGroup;

  /// No description provided for @allMuscleGroups.
  ///
  /// In en, this message translates to:
  /// **'All muscle groups'**
  String get allMuscleGroups;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @archivedTag.
  ///
  /// In en, this message translates to:
  /// **'archived'**
  String get archivedTag;

  /// No description provided for @statsSets.
  ///
  /// In en, this message translates to:
  /// **'Sets'**
  String get statsSets;

  /// No description provided for @statsReps.
  ///
  /// In en, this message translates to:
  /// **'Reps'**
  String get statsReps;

  /// No description provided for @statsVolume.
  ///
  /// In en, this message translates to:
  /// **'Total volume'**
  String get statsVolume;

  /// No description provided for @statsAvgVolume.
  ///
  /// In en, this message translates to:
  /// **'Avg volume / session'**
  String get statsAvgVolume;

  /// No description provided for @statsAvgSets.
  ///
  /// In en, this message translates to:
  /// **'Avg sets / session'**
  String get statsAvgSets;

  /// No description provided for @statsStreak.
  ///
  /// In en, this message translates to:
  /// **'Week streak'**
  String get statsStreak;

  /// No description provided for @statsWeeks.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 week} other{{count} weeks}}'**
  String statsWeeks(int count);

  /// No description provided for @chartOverTime.
  ///
  /// In en, this message translates to:
  /// **'Progress over time'**
  String get chartOverTime;

  /// No description provided for @metric.
  ///
  /// In en, this message translates to:
  /// **'Metric'**
  String get metric;

  /// No description provided for @groupBy.
  ///
  /// In en, this message translates to:
  /// **'Group by'**
  String get groupBy;

  /// No description provided for @groupDay.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get groupDay;

  /// No description provided for @groupWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get groupWeek;

  /// No description provided for @groupMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get groupMonth;

  /// No description provided for @chartOneRepMax.
  ///
  /// In en, this message translates to:
  /// **'Estimated 1RM progress'**
  String get chartOneRepMax;

  /// No description provided for @chooseExercise.
  ///
  /// In en, this message translates to:
  /// **'Choose an exercise'**
  String get chooseExercise;

  /// No description provided for @chartMuscleGroups.
  ///
  /// In en, this message translates to:
  /// **'Distribution by muscle group'**
  String get chartMuscleGroups;

  /// No description provided for @chartWeekdays.
  ///
  /// In en, this message translates to:
  /// **'Training days by weekday'**
  String get chartWeekdays;

  /// No description provided for @chartTopExercises.
  ///
  /// In en, this message translates to:
  /// **'Top exercises'**
  String get chartTopExercises;

  /// No description provided for @rankBy.
  ///
  /// In en, this message translates to:
  /// **'Rank by'**
  String get rankBy;

  /// No description provided for @rankOneRepMax.
  ///
  /// In en, this message translates to:
  /// **'Best 1RM'**
  String get rankOneRepMax;

  /// No description provided for @topN.
  ///
  /// In en, this message translates to:
  /// **'Top {count}'**
  String topN(int count);

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No sets in this selection. Log a workout or load the sample data in Settings.'**
  String get noData;

  /// No description provided for @noDataExercise.
  ///
  /// In en, this message translates to:
  /// **'No sets of this exercise in the period.'**
  String get noDataExercise;

  /// No description provided for @reportType.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get reportType;

  /// No description provided for @reportSetLog.
  ///
  /// In en, this message translates to:
  /// **'Set log'**
  String get reportSetLog;

  /// No description provided for @reportByExercise.
  ///
  /// In en, this message translates to:
  /// **'Summary by exercise'**
  String get reportByExercise;

  /// No description provided for @reportByPeriod.
  ///
  /// In en, this message translates to:
  /// **'Summary by period'**
  String get reportByPeriod;

  /// No description provided for @reportRecords.
  ///
  /// In en, this message translates to:
  /// **'Personal records'**
  String get reportRecords;

  /// No description provided for @reportSetLogInfo.
  ///
  /// In en, this message translates to:
  /// **'Every logged set, one row each.'**
  String get reportSetLogInfo;

  /// No description provided for @reportByExerciseInfo.
  ///
  /// In en, this message translates to:
  /// **'Days, sets, reps, volume and best lifts per exercise.'**
  String get reportByExerciseInfo;

  /// No description provided for @reportByPeriodInfo.
  ///
  /// In en, this message translates to:
  /// **'Your training grouped by day, week or month.'**
  String get reportByPeriodInfo;

  /// No description provided for @reportRecordsInfo.
  ///
  /// In en, this message translates to:
  /// **'Heaviest weight and best estimated 1RM per exercise, with dates.'**
  String get reportRecordsInfo;

  /// No description provided for @show.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get show;

  /// No description provided for @order.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get order;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// No description provided for @ascending.
  ///
  /// In en, this message translates to:
  /// **'Ascending'**
  String get ascending;

  /// No description provided for @descending.
  ///
  /// In en, this message translates to:
  /// **'Descending'**
  String get descending;

  /// No description provided for @rowCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 row} other{{count} rows}}'**
  String rowCount(int count);

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @copyCsv.
  ///
  /// In en, this message translates to:
  /// **'Copy as CSV'**
  String get copyCsv;

  /// No description provided for @csvCopied.
  ///
  /// In en, this message translates to:
  /// **'Report copied as CSV. Paste it into Excel or Google Sheets.'**
  String get csvCopied;

  /// No description provided for @colDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get colDate;

  /// No description provided for @colPeriod.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get colPeriod;

  /// No description provided for @colRoutine.
  ///
  /// In en, this message translates to:
  /// **'Routine'**
  String get colRoutine;

  /// No description provided for @colExercise.
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get colExercise;

  /// No description provided for @colMuscleGroup.
  ///
  /// In en, this message translates to:
  /// **'Muscle group'**
  String get colMuscleGroup;

  /// No description provided for @colSetNumber.
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get colSetNumber;

  /// No description provided for @colWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get colWeight;

  /// No description provided for @colReps.
  ///
  /// In en, this message translates to:
  /// **'Reps'**
  String get colReps;

  /// No description provided for @colVolume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get colVolume;

  /// No description provided for @colSets.
  ///
  /// In en, this message translates to:
  /// **'Sets'**
  String get colSets;

  /// No description provided for @colDays.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get colDays;

  /// No description provided for @colTopWeight.
  ///
  /// In en, this message translates to:
  /// **'Top weight'**
  String get colTopWeight;

  /// No description provided for @colTopWeightDate.
  ///
  /// In en, this message translates to:
  /// **'Top weight date'**
  String get colTopWeightDate;

  /// No description provided for @colBestOneRepMax.
  ///
  /// In en, this message translates to:
  /// **'Best est. 1RM'**
  String get colBestOneRepMax;

  /// No description provided for @colBestOneRepMaxDate.
  ///
  /// In en, this message translates to:
  /// **'1RM date'**
  String get colBestOneRepMaxDate;

  /// No description provided for @weekOf.
  ///
  /// In en, this message translates to:
  /// **'Week of {date}'**
  String weekOf(String date);

  /// No description provided for @profileSection.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileSection;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get languageSystem;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @accentColor.
  ///
  /// In en, this message translates to:
  /// **'Accent color'**
  String get accentColor;

  /// No description provided for @weightUnit.
  ///
  /// In en, this message translates to:
  /// **'Weight unit'**
  String get weightUnit;

  /// No description provided for @databaseSection.
  ///
  /// In en, this message translates to:
  /// **'Local database (SQLite)'**
  String get databaseSection;

  /// No description provided for @databaseInfo.
  ///
  /// In en, this message translates to:
  /// **'Everything is stored on this device in four related tables.'**
  String get databaseInfo;

  /// No description provided for @tableRows.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 row} other{{count} rows}}'**
  String tableRows(int count);

  /// No description provided for @tableProfile.
  ///
  /// In en, this message translates to:
  /// **'profile — your profile'**
  String get tableProfile;

  /// No description provided for @tableRoutines.
  ///
  /// In en, this message translates to:
  /// **'routines — training plans'**
  String get tableRoutines;

  /// No description provided for @tableExercises.
  ///
  /// In en, this message translates to:
  /// **'exercises — exercises of each routine'**
  String get tableExercises;

  /// No description provided for @tableSets.
  ///
  /// In en, this message translates to:
  /// **'workout_sets — every set lifted'**
  String get tableSets;

  /// No description provided for @loadSampleData.
  ///
  /// In en, this message translates to:
  /// **'Load sample data'**
  String get loadSampleData;

  /// No description provided for @loadSampleDataInfo.
  ///
  /// In en, this message translates to:
  /// **'Adds 3 routines and 8 weeks of workouts to try the statistics and reports.'**
  String get loadSampleDataInfo;

  /// No description provided for @sampleDataLoaded.
  ///
  /// In en, this message translates to:
  /// **'Sample data loaded'**
  String get sampleDataLoaded;

  /// No description provided for @deleteAllData.
  ///
  /// In en, this message translates to:
  /// **'Delete all data'**
  String get deleteAllData;

  /// No description provided for @deleteAllDataMessage.
  ///
  /// In en, this message translates to:
  /// **'Every routine, exercise, set and your profile are deleted from this device. This cannot be undone.'**
  String get deleteAllDataMessage;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @aboutText.
  ///
  /// In en, this message translates to:
  /// **'Personal gym tracker. Works offline; your data never leaves this device.'**
  String get aboutText;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
