import 'package:flutter/material.dart';

import '../../../domain/validation.dart';

/// Asks for a name (and optionally a description). Returns null if cancelled.
Future<({String name, String? description})?> showNameDialog(
  BuildContext context, {
  required String title,
  String initialName = '',
  bool askDescription = false,
  String confirmLabel = 'Save',
}) {
  return showDialog(
    context: context,
    builder: (context) => _NameDialog(
      title: title,
      initialName: initialName,
      askDescription: askDescription,
      confirmLabel: confirmLabel,
    ),
  );
}

class _NameDialog extends StatefulWidget {
  const _NameDialog({
    required this.title,
    required this.initialName,
    required this.askDescription,
    required this.confirmLabel,
  });

  final String title;
  final String initialName;
  final bool askDescription;
  final String confirmLabel;

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.initialName);
  final _description = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  void _confirm() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop((
      name: _name.text.trim(),
      description: widget.askDescription ? _description.text.trim() : null,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _name,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: Validation.requiredName,
              onFieldSubmitted: (_) => _confirm(),
            ),
            if (widget.askDescription)
              TextFormField(
                controller: _description,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                ),
                maxLength: 500,
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
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
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}
