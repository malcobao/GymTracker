import 'package:flutter/material.dart';

/// Shown while a screen's data is loading.
class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(semanticsLabel: 'Loading'),
    );
  }
}
