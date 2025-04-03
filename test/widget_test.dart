// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:simple_session_manager/examples/managing_session.dart';
import 'package:simple_session_manager/simple_session_manager.dart';

void main() {
  testWidgets('Test Session Management', (WidgetTester tester) async {
    bool onSessionTimeoutCalled = false;
    bool onActivityDetectedCalled = false;

    // Create a custom SimpleSessionManager for testing.
    await tester.pumpWidget(SimpleSessionManager(
        sessionMonitor: true,
        sessionTimeoutDuration: const Duration(seconds: 1),
        onSessionTimeout: () {
          onSessionTimeoutCalled = true;
        },
        onInactivityTimeout: () {
          onActivityDetectedCalled = true;
        },
        child: const MyBaseApp()));

    // Wait for the session timeout duration (1 second).
    await tester.pump(const Duration(seconds: 2));

    // Check if onSessionTimeout is called.
    expect(onSessionTimeoutCalled, true);

    //reset value
    onSessionTimeoutCalled = false;

    //simulate user tap
    await tester.tap(find.byType(MyBaseApp));
    await tester.pump(const Duration(milliseconds: 500));

    // Check if onActivityDetected is called.
    expect(onActivityDetectedCalled, true);
  });
}
