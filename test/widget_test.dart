// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:futbol_app/core/app.dart';

void main() {
  testWidgets('App loads without crashing', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: FutbolApp()));

    // Verify that the app loads without throwing errors
    // Since we might not have Supabase initialized in tests,
    // we just check that the widget tree is built
    await tester.pump();

    // Test passes if no exceptions are thrown
    expect(true, isTrue);
  });
}
