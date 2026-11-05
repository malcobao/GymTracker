import 'package:flutter/material.dart';

import '../core/widgets/empty_view.dart';

/// Placeholder home screen. Replaced by the routine list in milestone 4.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gym Tracker')),
      body: const EmptyView(message: 'Your routines will appear here.'),
    );
  }
}
