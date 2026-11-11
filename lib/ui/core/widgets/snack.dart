import 'package:flutter/material.dart';

/// Shows [message] in a snack bar if it is not null.
void showMessage(BuildContext context, String? message) {
  if (message == null || !context.mounted) return;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
