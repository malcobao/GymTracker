import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/main.dart';

void main() {
  testWidgets('app starts on the home screen', (tester) async {
    await tester.pumpWidget(GymTrackerApp());
    await tester.pumpAndSettle();
    expect(find.text('Gym Tracker'), findsOneWidget);
    expect(find.text('Your routines will appear here.'), findsOneWidget);
  });
}
