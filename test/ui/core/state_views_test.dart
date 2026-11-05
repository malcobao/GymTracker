import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/ui/core/widgets/empty_view.dart';
import 'package:gym_tracker/ui/core/widgets/error_view.dart';
import 'package:gym_tracker/ui/core/widgets/loading_view.dart';

Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('LoadingView shows a progress indicator', (tester) async {
    await tester.pumpWidget(wrap(const LoadingView()));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.bySemanticsLabel('Loading'), findsOneWidget);
  });

  testWidgets('ErrorView shows the message and calls onRetry', (tester) async {
    var retries = 0;
    await tester.pumpWidget(
      wrap(ErrorView(message: 'No connection', onRetry: () => retries++)),
    );
    expect(find.text('No connection'), findsOneWidget);
    await tester.tap(find.text('Try again'));
    expect(retries, 1);
  });

  testWidgets('ErrorView hides the retry button without onRetry', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(const ErrorView(message: 'Failed')));
    expect(find.text('Try again'), findsNothing);
  });

  testWidgets('EmptyView shows its action when given', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      wrap(
        EmptyView(
          message: 'No routines yet',
          actionLabel: 'Create routine',
          onAction: () => taps++,
        ),
      ),
    );
    await tester.tap(find.text('Create routine'));
    expect(taps, 1);
  });
}
