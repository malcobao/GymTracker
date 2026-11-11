"""Writes lib/l10n/app_en.arb and app_es.arb (all texts of the app).

Run from the project root: python tool/gen_arb.py, then flutter gen-l10n.
Keeping both languages side by side here makes missing translations
impossible.
"""
import json

S = {}


def k(key, en, es, ph=None):
    S[key] = (en, es, ph)


I = {'type': 'int'}
T = {'type': 'String'}
N = {'type': 'num', 'format': 'decimalPattern'}

k('appTitle', 'Gym Tracker', 'Gym Tracker')
# navigation
k('navRoutines', 'Routines', 'Rutinas')
k('navStatistics', 'Statistics', 'Estadísticas')
k('navReports', 'Reports', 'Reportes')
k('navSettings', 'Settings', 'Ajustes')
# common
k('cancel', 'Cancel', 'Cancelar')
k('save', 'Save', 'Guardar')
k('create', 'Create', 'Crear')
k('delete', 'Delete', 'Eliminar')
k('edit', 'Edit', 'Editar')
k('archive', 'Archive', 'Archivar')
k('restore', 'Restore', 'Restaurar')
k('tryAgain', 'Try again', 'Reintentar')
k('loading', 'Loading', 'Cargando')
k('nameLabel', 'Name', 'Nombre')
k('descriptionLabel', 'Description (optional)', 'Descripción (opcional)')
# validation
k('errRequired', 'This field is required', 'Este campo es obligatorio')
k('errTooLong', 'Use at most {max} characters',
  'Usa como máximo {max} caracteres', {'max': I})
k('errNotANumber', 'Enter a number', 'Escribe un número')
k('errNotWholeNumber', 'Enter a whole number', 'Escribe un número entero')
k('errOutOfRange', 'Must be between {min} and {max}',
  'Debe estar entre {min} y {max}', {'min': N, 'max': N})
k('errDuplicateName', 'That name already exists', 'Ese nombre ya existe')
k('errAgeRange', 'Age must be between {min} and {max} years',
  'La edad debe estar entre {min} y {max} años', {'min': I, 'max': I})
# app errors
k('errorDuplicate', 'That name is already in use.',
  'Ese nombre ya está en uso.')
k('errorInvalidData', 'Some values are out of the allowed range.',
  'Algunos valores están fuera del rango permitido.')
k('errorInUse', 'It has {count} logged sets.',
  'Tiene {count} series registradas.', {'count': I})
k('errorNotFound', 'That item no longer exists.', 'Ese elemento ya no existe.')
k('errorStorage', 'Could not access the local database.',
  'No se pudo acceder a la base de datos local.')
# enums
k('sexMale', 'Male', 'Hombre')
k('sexFemale', 'Female', 'Mujer')
k('sexUnspecified', 'Prefer not to say', 'Prefiero no decirlo')
k('levelBeginner', 'Beginner', 'Principiante')
k('levelIntermediate', 'Intermediate', 'Intermedio')
k('levelAdvanced', 'Advanced', 'Avanzado')
k('goalStrength', 'Get stronger', 'Ganar fuerza')
k('goalMuscleGain', 'Build muscle', 'Ganar músculo')
k('goalFatLoss', 'Lose fat', 'Perder grasa')
k('goalGeneralFitness', 'General fitness', 'Condición física general')
for key, en, es in [
    ('Chest', 'Chest', 'Pecho'), ('Back', 'Back', 'Espalda'),
    ('Shoulders', 'Shoulders', 'Hombros'), ('Biceps', 'Biceps', 'Bíceps'),
    ('Triceps', 'Triceps', 'Tríceps'), ('Legs', 'Legs', 'Piernas'),
    ('Glutes', 'Glutes', 'Glúteos'), ('Core', 'Core', 'Core / abdomen'),
    ('FullBody', 'Full body', 'Cuerpo completo'), ('Other', 'Other', 'Otro')]:
    k('muscle' + key, en, es)
k('muscleNone', 'No muscle group', 'Sin grupo muscular')
# onboarding / profile
k('onboardingTitle', 'Tell us about you', 'Cuéntanos sobre ti')
k('onboardingIntro',
  'Used to personalise your training. You can change it any time.',
  'Se usa para personalizar tu entrenamiento. Puedes cambiarlo cuando quieras.')
k('editProfile', 'Edit profile', 'Editar perfil')
k('birthDate', 'Birth date', 'Fecha de nacimiento')
k('chooseDate', 'Choose a date', 'Elige una fecha')
k('sex', 'Sex', 'Sexo')
k('height', 'Height', 'Estatura')
k('bodyWeight', 'Body weight', 'Peso corporal')
k('experience', 'Experience', 'Experiencia')
k('mainGoal', 'Main goal', 'Objetivo principal')
k('startTraining', 'Start training', 'Empezar a entrenar')
k('profileSaved', 'Profile saved', 'Perfil guardado')
k('ageAndBmi', '{age} years · BMI {bmi}', '{age} años · IMC {bmi}',
  {'age': I, 'bmi': T})
# routines
k('myRoutines', 'My routines', 'Mis rutinas')
k('archivedRoutines', 'Archived routines', 'Rutinas archivadas')
k('showArchived', 'Show archived', 'Ver archivadas')
k('routineFab', 'Routine', 'Rutina')
k('noRoutines', 'No routines yet. Create your first one, such as "Push day".',
  'Aún no tienes rutinas. Crea la primera, por ejemplo "Empuje".')
k('noArchivedRoutines', 'No archived routines.', 'No hay rutinas archivadas.')
k('createRoutine', 'Create routine', 'Crear rutina')
k('newRoutine', 'New routine', 'Nueva rutina')
k('editRoutine', 'Edit routine', 'Editar rutina')
k('exerciseCount',
  '{count, plural, =0{No exercises} =1{1 exercise} other{{count} exercises}}',
  '{count, plural, =0{Sin ejercicios} =1{1 ejercicio} other{{count} ejercicios}}',
  {'count': I})
k('routineCreated', 'Routine created', 'Rutina creada')
k('routineUpdated', 'Routine updated', 'Rutina actualizada')
k('routineArchived', 'Routine archived', 'Rutina archivada')
k('routineRestored', 'Routine restored', 'Rutina restaurada')
k('routineDeleted', 'Routine deleted', 'Rutina eliminada')
k('deleteTitle', 'Delete "{name}"?', '¿Eliminar "{name}"?', {'name': T})
k('deleteRoutineMessage',
  'The routine and its exercises are deleted for good.',
  'La rutina y sus ejercicios se eliminan definitivamente.')
k('deleteExerciseMessage', 'The exercise is deleted for good.',
  'El ejercicio se elimina definitivamente.')
k('inUseTitle', '"{name}" has history', '"{name}" tiene historial',
  {'name': T})
k('inUseMessage',
  'The database blocked the delete: {count} logged sets depend on it '
  '(referential integrity). Archive it to hide it and keep the history, '
  'or delete it together with all its sets.',
  'La base de datos bloqueó la eliminación: {count} series registradas '
  'dependen de este elemento (integridad referencial). Archívalo para '
  'ocultarlo y conservar el historial, o elimínalo junto con todas sus series.',
  {'count': I})
k('deleteEverything', 'Delete everything', 'Eliminar todo')
# routine detail / exercises
k('addExercise', 'Add exercise', 'Agregar ejercicio')
k('editExercise', 'Edit exercise', 'Editar ejercicio')
k('noExercises', 'This routine has no exercises yet.',
  'Esta rutina todavía no tiene ejercicios.')
k('noArchivedExercises', 'No archived exercises.', 'No hay ejercicios archivados.')
k('archivedExercises', 'Archived exercises', 'Ejercicios archivados')
k('startWorkout', "Start today's workout", 'Empezar el entrenamiento de hoy')
k('progressTooltip', 'Progress', 'Progreso')
k('moreOptions', 'More options', 'Más opciones')
k('exerciseNameHint', 'Name, e.g. Bench press',
  'Nombre, p. ej. Press de banca')
k('muscleGroupOptional', 'Muscle group (optional)',
  'Grupo muscular (opcional)')
k('targetSets', 'Target sets', 'Series objetivo')
k('targetReps', 'Target reps', 'Repeticiones objetivo')
k('targetLabel', '{sets} × {reps}', '{sets} × {reps}',
  {'sets': I, 'reps': I})
k('targetSetsOnly', '{sets} sets', '{sets} series', {'sets': I})
k('targetRepsOnly', '{reps} reps', '{reps} reps', {'reps': I})
k('exerciseAdded', 'Exercise added', 'Ejercicio agregado')
k('exerciseUpdated', 'Exercise updated', 'Ejercicio actualizado')
k('exerciseArchived', 'Exercise archived', 'Ejercicio archivado')
k('exerciseRestored', 'Exercise restored', 'Ejercicio restaurado')
k('exerciseDeleted', 'Exercise deleted', 'Ejercicio eliminado')
# workout
k('workoutOf', 'Workout of {date}', 'Entrenamiento del {date}', {'date': T})
k('weight', 'Weight', 'Peso')
k('reps', 'Reps', 'Reps')
k('logSet', 'Log set', 'Registrar serie')
k('setLogged', 'Set {number} logged', 'Serie {number} registrada',
  {'number': I})
k('setDeleted', 'Set {number} deleted', 'Serie {number} eliminada',
  {'number': I})
k('setUpdated', 'Set updated', 'Serie actualizada')
k('editSet', 'Edit set {number}', 'Editar serie {number}', {'number': I})
k('deleteSet', 'Delete set {number}', 'Eliminar serie {number}',
  {'number': I})
k('noExercisesWorkout', 'Add exercises to this routine first.',
  'Primero agrega ejercicios a esta rutina.')
k('targetPrefix', 'Target: {target}', 'Objetivo: {target}', {'target': T})
# progress
k('bestOneRepMax', 'Best estimated 1RM', 'Mejor 1RM estimado')
k('changeSinceFirst', 'Change since first day', 'Cambio desde el primer día')
k('trainingDays', 'Training days', 'Días entrenados')
k('oneRepMaxPerDay', 'Estimated 1-rep max per day', '1RM estimado por día')
k('epleyNote', 'Estimate uses the Epley formula: weight × (1 + reps / 30).',
  'Se estima con la fórmula de Epley: peso × (1 + reps / 30).')
k('history', 'History', 'Historial')
k('date', 'Date', 'Fecha')
k('topSet', 'Top set', 'Serie más pesada')
k('estimated1rm', 'Est. 1RM', '1RM est.')
k('volume', 'Volume', 'Volumen')
k('noSetsForExercise', 'No sets logged for this exercise yet.',
  'Aún no hay series de este ejercicio.')
# filters
k('period', 'Period', 'Periodo')
k('last7Days', 'Last 7 days', 'Últimos 7 días')
k('last30Days', 'Last 30 days', 'Últimos 30 días')
k('last90Days', 'Last 90 days', 'Últimos 90 días')
k('lastYear', 'Last 12 months', 'Últimos 12 meses')
k('allTime', 'All time', 'Todo el historial')
k('customRange', 'Custom range…', 'Rango personalizado…')
k('routine', 'Routine', 'Rutina')
k('allRoutines', 'All routines', 'Todas las rutinas')
k('exercise', 'Exercise', 'Ejercicio')
k('allExercises', 'All exercises', 'Todos los ejercicios')
k('muscleGroup', 'Muscle group', 'Grupo muscular')
k('allMuscleGroups', 'All muscle groups', 'Todos los grupos')
k('filters', 'Filters', 'Filtros')
k('archivedTag', 'archived', 'archivado')
# statistics
k('statsSets', 'Sets', 'Series')
k('statsReps', 'Reps', 'Repeticiones')
k('statsVolume', 'Total volume', 'Volumen total')
k('statsAvgVolume', 'Avg volume / session', 'Volumen prom. / sesión')
k('statsAvgSets', 'Avg sets / session', 'Series prom. / sesión')
k('statsStreak', 'Week streak', 'Racha semanal')
k('statsWeeks', '{count, plural, =1{1 week} other{{count} weeks}}',
  '{count, plural, =1{1 semana} other{{count} semanas}}', {'count': I})
k('chartOverTime', 'Progress over time', 'Progreso en el tiempo')
k('metric', 'Metric', 'Métrica')
k('groupBy', 'Group by', 'Agrupar por')
k('groupDay', 'Day', 'Día')
k('groupWeek', 'Week', 'Semana')
k('groupMonth', 'Month', 'Mes')
k('chartOneRepMax', 'Estimated 1RM progress', 'Progreso del 1RM estimado')
k('chooseExercise', 'Choose an exercise', 'Elige un ejercicio')
k('chartMuscleGroups', 'Distribution by muscle group',
  'Distribución por grupo muscular')
k('chartWeekdays', 'Training days by weekday',
  'Días entrenados por día de la semana')
k('chartTopExercises', 'Top exercises', 'Ejercicios destacados')
k('rankBy', 'Rank by', 'Clasificar por')
k('rankOneRepMax', 'Best 1RM', 'Mejor 1RM')
k('topN', 'Top {count}', 'Top {count}', {'count': I})
k('noData',
  'No sets in this selection. Log a workout or load the sample data in Settings.',
  'No hay series en esta selección. Registra un entrenamiento o carga los '
  'datos de ejemplo en Ajustes.')
k('noDataExercise', 'No sets of this exercise in the period.',
  'No hay series de este ejercicio en el periodo.')
# reports
k('reportType', 'Report', 'Reporte')
k('reportSetLog', 'Set log', 'Registro de series')
k('reportByExercise', 'Summary by exercise', 'Resumen por ejercicio')
k('reportByPeriod', 'Summary by period', 'Resumen por periodo')
k('reportRecords', 'Personal records', 'Récords personales')
k('reportSetLogInfo', 'Every logged set, one row each.',
  'Cada serie registrada, una por fila.')
k('reportByExerciseInfo',
  'Days, sets, reps, volume and best lifts per exercise.',
  'Días, series, reps, volumen y mejores marcas por ejercicio.')
k('reportByPeriodInfo', 'Your training grouped by day, week or month.',
  'Tu entrenamiento agrupado por día, semana o mes.')
k('reportRecordsInfo',
  'Heaviest weight and best estimated 1RM per exercise, with dates.',
  'Peso máximo y mejor 1RM estimado por ejercicio, con fechas.')
k('show', 'Show', 'Mostrar')
k('order', 'Order', 'Orden')
k('sortBy', 'Sort by', 'Ordenar por')
k('ascending', 'Ascending', 'Ascendente')
k('descending', 'Descending', 'Descendente')
k('rowCount', '{count, plural, =1{1 row} other{{count} rows}}',
  '{count, plural, =1{1 fila} other{{count} filas}}', {'count': I})
k('total', 'Total', 'Total')
k('copyCsv', 'Copy as CSV', 'Copiar como CSV')
k('csvCopied', 'Report copied as CSV. Paste it into Excel or Google Sheets.',
  'Reporte copiado como CSV. Pégalo en Excel o Google Sheets.')
k('colDate', 'Date', 'Fecha')
k('colPeriod', 'Period', 'Periodo')
k('colRoutine', 'Routine', 'Rutina')
k('colExercise', 'Exercise', 'Ejercicio')
k('colMuscleGroup', 'Muscle group', 'Grupo muscular')
k('colSetNumber', 'Set', 'Serie')
k('colWeight', 'Weight', 'Peso')
k('colReps', 'Reps', 'Reps')
k('colVolume', 'Volume', 'Volumen')
k('colSets', 'Sets', 'Series')
k('colDays', 'Days', 'Días')
k('colTopWeight', 'Top weight', 'Peso máximo')
k('colTopWeightDate', 'Top weight date', 'Fecha peso máx.')
k('colBestOneRepMax', 'Best est. 1RM', 'Mejor 1RM est.')
k('colBestOneRepMaxDate', '1RM date', 'Fecha 1RM')
k('weekOf', 'Week of {date}', 'Semana del {date}', {'date': T})
# settings
k('profileSection', 'Profile', 'Perfil')
k('appearance', 'Appearance', 'Apariencia')
k('language', 'Language', 'Idioma')
k('languageSystem', 'Automatic', 'Automático')
k('theme', 'Theme', 'Tema')
k('themeSystem', 'System', 'Sistema')
k('themeLight', 'Light', 'Claro')
k('themeDark', 'Dark', 'Oscuro')
k('accentColor', 'Accent color', 'Color de acento')
k('weightUnit', 'Weight unit', 'Unidad de peso')
k('databaseSection', 'Local database (SQLite)', 'Base de datos local (SQLite)')
k('databaseInfo', 'Everything is stored on this device in four related tables.',
  'Todo se guarda en este dispositivo en cuatro tablas relacionadas.')
k('tableRows', '{count, plural, =1{1 row} other{{count} rows}}',
  '{count, plural, =1{1 fila} other{{count} filas}}', {'count': I})
k('tableProfile', 'profile — your profile', 'profile — tu perfil')
k('tableRoutines', 'routines — training plans',
  'routines — rutinas de entrenamiento')
k('tableExercises', 'exercises — exercises of each routine',
  'exercises — ejercicios de cada rutina')
k('tableSets', 'workout_sets — every set lifted',
  'workout_sets — cada serie realizada')
k('loadSampleData', 'Load sample data', 'Cargar datos de ejemplo')
k('loadSampleDataInfo',
  'Adds 3 routines and 8 weeks of workouts to try the statistics and reports.',
  'Agrega 3 rutinas y 8 semanas de entrenamientos para probar estadísticas '
  'y reportes.')
k('sampleDataLoaded', 'Sample data loaded', 'Datos de ejemplo cargados')
k('deleteAllData', 'Delete all data', 'Borrar todos los datos')
k('deleteAllDataMessage',
  'Every routine, exercise, set and your profile are deleted from this '
  'device. This cannot be undone.',
  'Se borran de este dispositivo todas las rutinas, ejercicios, series y tu '
  'perfil. No se puede deshacer.')
k('about', 'About', 'Acerca de')
k('aboutText',
  'Personal gym tracker. Works offline; your data never leaves this device.',
  'Registro personal de gimnasio. Funciona sin internet; tus datos nunca '
  'salen de este dispositivo.')

en = {'@@locale': 'en'}
es = {'@@locale': 'es'}
for key, (e, s, ph) in S.items():
    en[key] = e
    es[key] = s
    if ph:
        en['@' + key] = {'placeholders': ph}
for name, data in (('app_en.arb', en), ('app_es.arb', es)):
    with open('lib/l10n/' + name, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
        f.write('\n')
print(len(S), 'texts')
