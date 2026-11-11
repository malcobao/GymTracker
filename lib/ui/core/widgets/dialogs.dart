import 'package:flutter/material.dart';

import '../../../domain/validation.dart';
import '../labels.dart';

/// Shows [message] in a snack bar if it is not null.
void showMessage(BuildContext context, String? message) {
  if (message == null || !context.mounted) return;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

/// Asks for a name and an optional description. Validates in real time,
/// including that the name is not in [takenNames]. Returns null if cancelled.
Future<({String name, String? description})?> showNameDialog(
  BuildContext context, {
  required String title,
  required String confirmLabel,
  String initialName = '',
  String? initialDescription,
  Iterable<String> takenNames = const [],
}) => showDialog(
  context: context,
  builder: (_) => _NameDialog(
    title: title,
    confirmLabel: confirmLabel,
    initialName: initialName,
    initialDescription: initialDescription,
    takenNames: takenNames,
  ),
);

class _NameDialog extends StatefulWidget {
  const _NameDialog({
    required this.title,
    required this.confirmLabel,
    required this.initialName,
    required this.initialDescription,
    required this.takenNames,
  });

  final String title;
  final String confirmLabel;
  final String initialName;
  final String? initialDescription;
  final Iterable<String> takenNames;

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.initialName);
  late final _description = TextEditingController(
    text: widget.initialDescription ?? '',
  );

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  void _confirm() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context)
        .pop((name: _name.text.trim(), description: _description.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _name,
              autofocus: true,
              maxLength: Validation.maxNameLength,
              decoration: InputDecoration(labelText: l10n.nameLabel),
              validator: (v) =>
                  l10n.field(Validation.name(v, taken: widget.takenNames)),
              onFieldSubmitted: (_) => _confirm(),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _description,
              maxLength: Validation.maxDescriptionLength,
              maxLines: 2,
              decoration: InputDecoration(labelText: l10n.descriptionLabel),
              validator: (v) => l10n.field(
                Validation.optionalText(
                  v,
                  max: Validation.maxDescriptionLength,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(onPressed: _confirm, child: Text(widget.confirmLabel)),
      ],
    );
  }
}

/// Asks the user to confirm an action. Returns true when confirmed.
Future<bool> confirmAction(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      final scheme = Theme.of(context).colorScheme;
      return AlertDialog(
        icon: destructive
            ? Icon(Icons.warning_amber_rounded, color: scheme.error)
            : null,
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            style: destructive
                ? FilledButton.styleFrom(
                    backgroundColor: scheme.error,
                    foregroundColor: scheme.onError,
                  )
                : null,
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      );
    },
  );
  return result ?? false;
}

/// What to do with an item the database refused to delete because logged
/// sets depend on it.
enum InUseChoice { archive, deleteEverything }

Future<InUseChoice?> askInUse(
  BuildContext context, {
  required String name,
  required int setCount,
}) => showDialog<InUseChoice>(
  context: context,
  builder: (context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return AlertDialog(
      icon: Icon(Icons.link, color: scheme.primary),
      title: Text(l10n.inUseTitle(name)),
      content: Text(l10n.inUseMessage(setCount)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: scheme.error),
          onPressed: () =>
              Navigator.of(context).pop(InUseChoice.deleteEverything),
          child: Text(l10n.deleteEverything),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(InUseChoice.archive),
          child: Text(l10n.archive),
        ),
      ],
    );
  },
);
