import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:todo/providers/todo_provider.dart';
import 'package:todo/screens/home_screen.dart';
// It's good to also import CalendarScreen if we are verifying its presence by type,
// though find.byType(TableCalendar) is also a strong indicator.
import 'package:todo/screens/calendar_screen.dart';


void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Helper function to pump HomeScreen with a TodoProvider
  Future<void> pumpHomeScreen(WidgetTester tester, TodoProvider todoProvider) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<TodoProvider>.value(
        value: todoProvider,
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );
  }

  group('HomeScreen Navigation Tests', () {
    testWidgets('shows Home content initially and navigates to Calendar', (WidgetTester tester) async {
      final todoProvider = TodoProvider();
      // Add some data to make "기간 없음" section header appear if it depends on tasks count
      todoProvider.allTodos.add(TodoItem(id:1, title: "Test simple task", createdAt: DateTime.now()));


      await pumpHomeScreen(tester, todoProvider);
      await tester.pumpAndSettle();


      // Expect to find "Home" specific content.
      // Using the section header text added in a previous step.
      expect(find.text('기간 없음'), findsOneWidget);
      expect(find.byType(TableCalendar), findsNothing); // Calendar should not be visible

      // Find the "Calendar" icon in the BottomNavigationBar and tap it.
      await tester.tap(find.byIcon(Icons.calendar_today));
      await tester.pumpAndSettle(); // Wait for navigation and UI rebuild

      // Expect to find TableCalendar (indicating CalendarScreen is now visible).
      expect(find.byType(TableCalendar), findsOneWidget);
      // Home specific content should be gone (or offstage)
      expect(find.text('기간 없음'), findsNothing);
    });

    testWidgets('navigates from Calendar back to Home', (WidgetTester tester) async {
      final todoProvider = TodoProvider();
      todoProvider.allTodos.add(TodoItem(id:1, title: "Test simple task", createdAt: DateTime.now()));

      await pumpHomeScreen(tester, todoProvider);
      await tester.pumpAndSettle();

      // 1. Navigate to Calendar screen
      await tester.tap(find.byIcon(Icons.calendar_today));
      await tester.pumpAndSettle();

      // Verify we are on Calendar screen
      expect(find.byType(TableCalendar), findsOneWidget);
      expect(find.text('기간 없음'), findsNothing);

      // 2. Navigate back to Home screen
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();

      // Verify we are back on Home screen
      expect(find.text('기간 없음'), findsOneWidget);
      expect(find.byType(TableCalendar), findsNothing);
    });
  });
}
