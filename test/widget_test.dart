// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo/main.dart'; // MyApp import
import 'package:todo/utils/time_helper.dart'; // TimeHelper for greeting

void main() {
  testWidgets('Todo app smoke test - HomeScreen loads', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Wait for any animations or async operations to complete
    await tester.pumpAndSettle();

    // Verify that the greeting message is displayed (dynamic, so check for part of it)
    expect(find.textContaining('사용자님', findRichText: true), findsOneWidget);

    // Verify that "오늘의 진행률" is displayed
    expect(find.textContaining('오늘의 진행률'), findsOneWidget);

    // Verify that the FAB is present
    expect(find.byIcon(Icons.add), findsOneWidget);

    // Verify bottom navigation bar items
    expect(find.text('홈'), findsOneWidget);
    expect(find.text('목록'), findsOneWidget);
  });
}
