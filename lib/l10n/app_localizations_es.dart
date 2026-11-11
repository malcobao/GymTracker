// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Gym Tracker';

  @override
  String get navRoutines => 'Rutinas';

  @override
  String get navStatistics => 'Estadísticas';

  @override
  String get navReports => 'Reportes';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get create => 'Crear';

  @override
  String get delete => 'Eliminar';

  @override
  String get edit => 'Editar';

  @override
  String get archive => 'Archivar';

  @override
  String get restore => 'Restaurar';

  @override
  String get tryAgain => 'Reintentar';

  @override
  String get loading => 'Cargando';

  @override
  String get nameLabel => 'Nombre';

  @override
  String get descriptionLabel => 'Descripción (opcional)';

  @override
  String get errRequired => 'Este campo es obligatorio';

  @override
  String errTooLong(int max) {
    return 'Usa como máximo $max caracteres';
  }

  @override
  String get errNotANumber => 'Escribe un número';

  @override
  String get errNotWholeNumber => 'Escribe un número entero';

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

    return 'Debe estar entre $minString y $maxString';
  }

  @override
  String get errDuplicateName => 'Ese nombre ya existe';

  @override
  String errAgeRange(int min, int max) {
    return 'La edad debe estar entre $min y $max años';
  }

  @override
  String get errorDuplicate => 'Ese nombre ya está en uso.';

  @override
  String get errorInvalidData =>
      'Algunos valores están fuera del rango permitido.';

  @override
  String errorInUse(int count) {
    return 'Tiene $count series registradas.';
  }

  @override
  String get errorNotFound => 'Ese elemento ya no existe.';

  @override
  String get errorStorage => 'No se pudo acceder a la base de datos local.';

  @override
  String get sexMale => 'Hombre';

  @override
  String get sexFemale => 'Mujer';

  @override
  String get sexUnspecified => 'Prefiero no decirlo';

  @override
  String get levelBeginner => 'Principiante';

  @override
  String get levelIntermediate => 'Intermedio';

  @override
  String get levelAdvanced => 'Avanzado';

  @override
  String get goalStrength => 'Ganar fuerza';

  @override
  String get goalMuscleGain => 'Ganar músculo';

  @override
  String get goalFatLoss => 'Perder grasa';

  @override
  String get goalGeneralFitness => 'Condición física general';

  @override
  String get muscleChest => 'Pecho';

  @override
  String get muscleBack => 'Espalda';

  @override
  String get muscleShoulders => 'Hombros';

  @override
  String get muscleBiceps => 'Bíceps';

  @override
  String get muscleTriceps => 'Tríceps';

  @override
  String get muscleLegs => 'Piernas';

  @override
  String get muscleGlutes => 'Glúteos';

  @override
  String get muscleCore => 'Core / abdomen';

  @override
  String get muscleFullBody => 'Cuerpo completo';

  @override
  String get muscleOther => 'Otro';

  @override
  String get muscleNone => 'Sin grupo muscular';

  @override
  String get onboardingTitle => 'Cuéntanos sobre ti';

  @override
  String get onboardingIntro =>
      'Se usa para personalizar tu entrenamiento. Puedes cambiarlo cuando quieras.';

  @override
  String get editProfile => 'Editar perfil';

  @override
  String get birthDate => 'Fecha de nacimiento';

  @override
  String get chooseDate => 'Elige una fecha';

  @override
  String get sex => 'Sexo';

  @override
  String get height => 'Estatura';

  @override
  String get bodyWeight => 'Peso corporal';

  @override
  String get experience => 'Experiencia';

  @override
  String get mainGoal => 'Objetivo principal';

  @override
  String get startTraining => 'Empezar a entrenar';

  @override
  String get profileSaved => 'Perfil guardado';

  @override
  String ageAndBmi(int age, String bmi) {
    return '$age años · IMC $bmi';
  }

  @override
  String get myRoutines => 'Mis rutinas';

  @override
  String get archivedRoutines => 'Rutinas archivadas';

  @override
  String get showArchived => 'Ver archivadas';

  @override
  String get routineFab => 'Rutina';

  @override
  String get noRoutines =>
      'Aún no tienes rutinas. Crea la primera, por ejemplo \"Empuje\".';

  @override
  String get noArchivedRoutines => 'No hay rutinas archivadas.';

  @override
  String get createRoutine => 'Crear rutina';

  @override
  String get newRoutine => 'Nueva rutina';

  @override
  String get editRoutine => 'Editar rutina';

  @override
  String exerciseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ejercicios',
      one: '1 ejercicio',
      zero: 'Sin ejercicios',
    );
    return '$_temp0';
  }

  @override
  String get routineCreated => 'Rutina creada';

  @override
  String get routineUpdated => 'Rutina actualizada';

  @override
  String get routineArchived => 'Rutina archivada';

  @override
  String get routineRestored => 'Rutina restaurada';

  @override
  String get routineDeleted => 'Rutina eliminada';

  @override
  String deleteTitle(String name) {
    return '¿Eliminar \"$name\"?';
  }

  @override
  String get deleteRoutineMessage =>
      'La rutina y sus ejercicios se eliminan definitivamente.';

  @override
  String get deleteExerciseMessage =>
      'El ejercicio se elimina definitivamente.';

  @override
  String inUseTitle(String name) {
    return '\"$name\" tiene historial';
  }

  @override
  String inUseMessage(int count) {
    return 'La base de datos bloqueó la eliminación: $count series registradas dependen de este elemento (integridad referencial). Archívalo para ocultarlo y conservar el historial, o elimínalo junto con todas sus series.';
  }

  @override
  String get deleteEverything => 'Eliminar todo';

  @override
  String get addExercise => 'Agregar ejercicio';

  @override
  String get editExercise => 'Editar ejercicio';

  @override
  String get noExercises => 'Esta rutina todavía no tiene ejercicios.';

  @override
  String get noArchivedExercises => 'No hay ejercicios archivados.';

  @override
  String get archivedExercises => 'Ejercicios archivados';

  @override
  String get startWorkout => 'Empezar el entrenamiento de hoy';

  @override
  String get progressTooltip => 'Progreso';

  @override
  String get moreOptions => 'Más opciones';

  @override
  String get exerciseNameHint => 'Nombre, p. ej. Press de banca';

  @override
  String get muscleGroupOptional => 'Grupo muscular (opcional)';

  @override
  String get targetSets => 'Series objetivo';

  @override
  String get targetReps => 'Repeticiones objetivo';

  @override
  String targetLabel(int sets, int reps) {
    return '$sets × $reps';
  }

  @override
  String targetSetsOnly(int sets) {
    return '$sets series';
  }

  @override
  String targetRepsOnly(int reps) {
    return '$reps reps';
  }

  @override
  String get exerciseAdded => 'Ejercicio agregado';

  @override
  String get exerciseUpdated => 'Ejercicio actualizado';

  @override
  String get exerciseArchived => 'Ejercicio archivado';

  @override
  String get exerciseRestored => 'Ejercicio restaurado';

  @override
  String get exerciseDeleted => 'Ejercicio eliminado';

  @override
  String workoutOf(String date) {
    return 'Entrenamiento del $date';
  }

  @override
  String get weight => 'Peso';

  @override
  String get reps => 'Reps';

  @override
  String get logSet => 'Registrar serie';

  @override
  String setLogged(int number) {
    return 'Serie $number registrada';
  }

  @override
  String setDeleted(int number) {
    return 'Serie $number eliminada';
  }

  @override
  String get setUpdated => 'Serie actualizada';

  @override
  String editSet(int number) {
    return 'Editar serie $number';
  }

  @override
  String deleteSet(int number) {
    return 'Eliminar serie $number';
  }

  @override
  String get noExercisesWorkout => 'Primero agrega ejercicios a esta rutina.';

  @override
  String targetPrefix(String target) {
    return 'Objetivo: $target';
  }

  @override
  String get bestOneRepMax => 'Mejor 1RM estimado';

  @override
  String get changeSinceFirst => 'Cambio desde el primer día';

  @override
  String get trainingDays => 'Días entrenados';

  @override
  String get oneRepMaxPerDay => '1RM estimado por día';

  @override
  String get epleyNote =>
      'Se estima con la fórmula de Epley: peso × (1 + reps / 30).';

  @override
  String get history => 'Historial';

  @override
  String get date => 'Fecha';

  @override
  String get topSet => 'Serie más pesada';

  @override
  String get estimated1rm => '1RM est.';

  @override
  String get volume => 'Volumen';

  @override
  String get noSetsForExercise => 'Aún no hay series de este ejercicio.';

  @override
  String get period => 'Periodo';

  @override
  String get last7Days => 'Últimos 7 días';

  @override
  String get last30Days => 'Últimos 30 días';

  @override
  String get last90Days => 'Últimos 90 días';

  @override
  String get lastYear => 'Últimos 12 meses';

  @override
  String get allTime => 'Todo el historial';

  @override
  String get customRange => 'Rango personalizado…';

  @override
  String get routine => 'Rutina';

  @override
  String get allRoutines => 'Todas las rutinas';

  @override
  String get exercise => 'Ejercicio';

  @override
  String get allExercises => 'Todos los ejercicios';

  @override
  String get muscleGroup => 'Grupo muscular';

  @override
  String get allMuscleGroups => 'Todos los grupos';

  @override
  String get filters => 'Filtros';

  @override
  String get archivedTag => 'archivado';

  @override
  String get statsSets => 'Series';

  @override
  String get statsReps => 'Repeticiones';

  @override
  String get statsVolume => 'Volumen total';

  @override
  String get statsAvgVolume => 'Volumen prom. / sesión';

  @override
  String get statsAvgSets => 'Series prom. / sesión';

  @override
  String get statsStreak => 'Racha semanal';

  @override
  String statsWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count semanas',
      one: '1 semana',
    );
    return '$_temp0';
  }

  @override
  String get chartOverTime => 'Progreso en el tiempo';

  @override
  String get metric => 'Métrica';

  @override
  String get groupBy => 'Agrupar por';

  @override
  String get groupDay => 'Día';

  @override
  String get groupWeek => 'Semana';

  @override
  String get groupMonth => 'Mes';

  @override
  String get chartOneRepMax => 'Progreso del 1RM estimado';

  @override
  String get chooseExercise => 'Elige un ejercicio';

  @override
  String get chartMuscleGroups => 'Distribución por grupo muscular';

  @override
  String get chartWeekdays => 'Días entrenados por día de la semana';

  @override
  String get chartTopExercises => 'Ejercicios destacados';

  @override
  String get rankBy => 'Clasificar por';

  @override
  String get rankOneRepMax => 'Mejor 1RM';

  @override
  String topN(int count) {
    return 'Top $count';
  }

  @override
  String get noData =>
      'No hay series en esta selección. Registra un entrenamiento o carga los datos de ejemplo en Ajustes.';

  @override
  String get noDataExercise => 'No hay series de este ejercicio en el periodo.';

  @override
  String get reportType => 'Reporte';

  @override
  String get reportSetLog => 'Registro de series';

  @override
  String get reportByExercise => 'Resumen por ejercicio';

  @override
  String get reportByPeriod => 'Resumen por periodo';

  @override
  String get reportRecords => 'Récords personales';

  @override
  String get reportSetLogInfo => 'Cada serie registrada, una por fila.';

  @override
  String get reportByExerciseInfo =>
      'Días, series, reps, volumen y mejores marcas por ejercicio.';

  @override
  String get reportByPeriodInfo =>
      'Tu entrenamiento agrupado por día, semana o mes.';

  @override
  String get reportRecordsInfo =>
      'Peso máximo y mejor 1RM estimado por ejercicio, con fechas.';

  @override
  String get show => 'Mostrar';

  @override
  String get order => 'Orden';

  @override
  String get sortBy => 'Ordenar por';

  @override
  String get ascending => 'Ascendente';

  @override
  String get descending => 'Descendente';

  @override
  String rowCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count filas',
      one: '1 fila',
    );
    return '$_temp0';
  }

  @override
  String get total => 'Total';

  @override
  String get copyCsv => 'Copiar como CSV';

  @override
  String get csvCopied =>
      'Reporte copiado como CSV. Pégalo en Excel o Google Sheets.';

  @override
  String get colDate => 'Fecha';

  @override
  String get colPeriod => 'Periodo';

  @override
  String get colRoutine => 'Rutina';

  @override
  String get colExercise => 'Ejercicio';

  @override
  String get colMuscleGroup => 'Grupo muscular';

  @override
  String get colSetNumber => 'Serie';

  @override
  String get colWeight => 'Peso';

  @override
  String get colReps => 'Reps';

  @override
  String get colVolume => 'Volumen';

  @override
  String get colSets => 'Series';

  @override
  String get colDays => 'Días';

  @override
  String get colTopWeight => 'Peso máximo';

  @override
  String get colTopWeightDate => 'Fecha peso máx.';

  @override
  String get colBestOneRepMax => 'Mejor 1RM est.';

  @override
  String get colBestOneRepMaxDate => 'Fecha 1RM';

  @override
  String weekOf(String date) {
    return 'Semana del $date';
  }

  @override
  String get profileSection => 'Perfil';

  @override
  String get appearance => 'Apariencia';

  @override
  String get language => 'Idioma';

  @override
  String get languageSystem => 'Automático';

  @override
  String get theme => 'Tema';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get accentColor => 'Color de acento';

  @override
  String get weightUnit => 'Unidad de peso';

  @override
  String get databaseSection => 'Base de datos local (SQLite)';

  @override
  String get databaseInfo =>
      'Todo se guarda en este dispositivo en cuatro tablas relacionadas.';

  @override
  String tableRows(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count filas',
      one: '1 fila',
    );
    return '$_temp0';
  }

  @override
  String get tableProfile => 'profile — tu perfil';

  @override
  String get tableRoutines => 'routines — rutinas de entrenamiento';

  @override
  String get tableExercises => 'exercises — ejercicios de cada rutina';

  @override
  String get tableSets => 'workout_sets — cada serie realizada';

  @override
  String get loadSampleData => 'Cargar datos de ejemplo';

  @override
  String get loadSampleDataInfo =>
      'Agrega 3 rutinas y 8 semanas de entrenamientos para probar estadísticas y reportes.';

  @override
  String get sampleDataLoaded => 'Datos de ejemplo cargados';

  @override
  String get deleteAllData => 'Borrar todos los datos';

  @override
  String get deleteAllDataMessage =>
      'Se borran de este dispositivo todas las rutinas, ejercicios, series y tu perfil. No se puede deshacer.';

  @override
  String get about => 'Acerca de';

  @override
  String get aboutText =>
      'Registro personal de gimnasio. Funciona sin internet; tus datos nunca salen de este dispositivo.';
}
