// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:spendsense_pwa/main.dart';
import 'package:spendsense_pwa/screens/auth/login_screen.dart';

void main() {
  testWidgets('Login screen loads and displays correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SpendSenseApp());

    // Wait for the app to initialize, which includes checking auth status.
    await tester.pumpAndSettle();

    // Verify that the LoginScreen is rendered.
    expect(find.byType(LoginScreen), findsOneWidget);

    // Verify that key widgets on the login screen are present.
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });
}
