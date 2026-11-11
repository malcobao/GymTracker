import 'package:flutter/material.dart';

import '../../data/repositories/routine_repository.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/exercise.dart';
import '../../domain/validation.dart';
import '../core/labels.dart';

/// Add or edit an exercise, validated while typing. Returns null if
/// cancelled.
Future<ExerciseDraft?> showExerciseDialog(
  BuildContext context, {
  Exercise? existing,
  Iterable<String> takenNames = const [],
}) => showDialog(
  context: context,
  builder: (_) => _ExerciseDialog(existing: existing, takenNames: takenNames),
);

class _ExerciseDialog extends StatefulWidget {
  const _ExerciseDialog({required this.existing, required this.takenNames});

  final Exercise? existing;
  final Iterable<String> takenNames;

  @override
  State<_ExerciseDialog> createState() => _ExerciseDialogState();
}

class _ExerciseDialogState extends State<_ExerciseDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.existing?.name ?? '');
  late final _sets = TextEditingController(
    text: widget.existing?.targetSets?.toString() ?? '',
  );
  late final _reps = TextEditingController(
    text: widget.existing?.targetReps?.toString() ?? '',
  );
  late MuscleGroup? _group = widget.existing?.muscleGroup;

  @override
  void dispose() {
    _name.dispose();
    _sets.dispose();
    _reps.dispose();
    super.dispose();
  }

  void _confirm() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      ExerciseDraft(
        name: _name.text.trim(),
        muscleGroup: _group,
        targetSets: int.tryParse(_sets.text.trim()),
        targetReps: int.tryParse(_reps.text.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final taken = widget.takenNames.where((n) => n != widget.existing?.name);
    return AlertDialog(
      title: Text(
        widget.existing == null ? l10n.addExercise : l10n.editExercise,
      ),
      content: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _name,
                autofocus: widget.existing == null,
                maxLength: Validation.maxNameLength,
                decoration: InputDecoration(labelText: l10n.exerciseNameHint),
                validator: (v) => l10n.field(Validation.name(v, taken: taken)),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<MuscleGroup?>(
                isExpanded: true,
                initialValue: _group,
                decoration: InputDecoration(
                  labelText: l10n.muscleGroupOptional,
                ),
                items: [
                  DropdownMenuItem(value: null, child: Text(l10n.muscleNone)),
                  for (final g in MuscleGroup.values)
                    DropdownMenuItem(value: g, child: Text(l10n.muscle(g))),
                ],
                onChanged: (g) => setState(() => _group = g),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _sets,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: l10n.targetSets),
                      validator: (v) => l10n.field(
                        Validation.optionalCount(
                          v,
                          max: Validation.maxTargetSets,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _reps,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: l10n.targetReps),
                      validator: (v) => l10n.field(
                        Validation.optionalCount(
                          v,
                          max: Validation.maxTargetReps,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(onPressed: _confirm, child: Text(l10n.save)),
      ],
    );
  }
}
