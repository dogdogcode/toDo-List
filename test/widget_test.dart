// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:todo/main.dart';
import 'package:todo/providers/todo_provider.dart';

void main() {
  testWidgets('Todo app smoke test', (WidgetTester tester) async {
    // Build our app with Provider and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => TodoProvider()),
        ],
        child: const TodoApp(),
      ),
    );

    // Wait for any animations to complete
    await tester.pumpAndSettle();

    // Verify that the navigation bar is displayed
    expect(find.text('일정'), findsOneWidget); // Calendar tab
    expect(find.text('할 일'), findsOneWidget); // Todo tab
    expect(find.text('프로필'), findsOneWidget); // Profile tab
  });
}
