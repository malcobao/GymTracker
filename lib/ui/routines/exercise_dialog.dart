import 'package:flutter/material.dart';

import '../../data/repositories/routine_repository.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/exercise.dart';
import '../../domain/validation.dart';

/// Add or edit an exercise. Returns null if cancelled.
Future<ExerciseDraft?> showExerciseDialog(
  BuildContext context, {
  Exercise? existing,
}) => showDialog(
  context: context,
  builder: (context) => _ExerciseDialog(existing: existing),
);

class _ExerciseDialog extends StatefulWidget {
  const _ExerciseDialog({this.existing});

  final Exercise? existing;

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
    return AlertDialog(
      title: Text(widget.existing == null ? 'Add exercise' : 'Edit exercise'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _name,
                autofocus: widget.existing == null,
                decoration: const InputDecoration(
                  labelText: 'Name, e.g. Bench press',
                ),
                validator: Validation.requiredName,
              ),
              DropdownButtonFormField<MuscleGroup?>(
                initialValue: _group,
                decoration: const InputDecoration(
                  labelText: 'Muscle group (optional)',
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('None')),
                  for (final g in MuscleGroup.values)
                    DropdownMenuItem(value: g, child: Text(g.label)),
                ],
                onChanged: (v) => setState(() => _group = v),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _sets,
                      decoration: const InputDecoration(
                        labelText: 'Target sets',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) => Validation.optionalCount(v, max: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _reps,
                      decoration: const InputDecoration(
                        labelText: 'Target reps',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) => Validation.optionalCount(v, max: 100),
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
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _confirm, child: const Text('Save')),
      ],
    );
  }
}
