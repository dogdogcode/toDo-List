import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:todo/models/todo_item.dart';
import 'package:todo/providers/todo_provider.dart';
import 'package:todo/screens/calendar_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Helper function to pump CalendarScreen with a TodoProvider
  Future<void> pumpCalendarScreen(WidgetTester tester, TodoProvider todoProvider) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<TodoProvider>.value(
        value: todoProvider,
        child: const MaterialApp(
          home: CalendarScreen(),
        ),
      ),
    );
  }

  group('CalendarScreen Tests', () {
    testWidgets('displays calendar and initial "No tasks for this day" message', (WidgetTester tester) async {
      final todoProvider = TodoProvider(); // Real instance

      await pumpCalendarScreen(tester, todoProvider);

      // Verify TableCalendar is present
      expect(find.byType(TableCalendar), findsOneWidget);

      // Verify "No tasks for this day." message is present (assuming today has no tasks)
      // Note: The exact text might depend on the selected day's tasks.
      // We rely on the default initial state where _selectedDay is DateTime.now() and usually has no tasks.
      expect(find.text('No tasks for this day.'), findsOneWidget);

      // Verify AppBar title
      expect(find.text('Calendar'), findsOneWidget);
    });

    testWidgets('displays tasks for selected day and event markers', (WidgetTester tester) async {
      final todoProvider = TodoProvider();
      final today = DateTime.now();
      final taskDate = DateTime(today.year, today.month, today.day, 10); // Specific time for due date

      // Add a task for today
      final testTask = TodoItem(
        id: 1,
        title: 'Test Task for Today',
        description: 'Description for today task',
        dueDate: taskDate,
        createdAt: DateTime.now(),
      );
      // Simulate adding to provider by directly manipulating its list (for testing simplicity)
      // In a real scenario with DB, you'd use provider methods and wait for futures.
      todoProvider.allTodos.add(testTask);
      todoProvider.simpleTasks.add(testTask); // Assuming it might go here if no deadline logic is complex

      await pumpCalendarScreen(tester, todoProvider);
      await tester.pumpAndSettle(); // Allow provider and UI to update

      // Tap on today's date in the calendar to ensure it's selected
      // Finding the exact day text can be tricky. `TableCalendar` usually renders day numbers as Text.
      // This assumes `today.day.toString()` is unique enough on the visible calendar.
      // A more robust finder might be needed if days from other months are visible with the same number.
      // For now, we assume it is sufficient.
      // final String dayToTap = today.day.toString();
      // await tester.tap(find.text(dayToTap).first); // .first if multiple (e.g. from prev/next month)

      // Instead of tapping, onDaySelected is called with _selectedDay = _focusedDay (DateTime.now())
      // in initState. So tasks for today should load if any.
      // We need to ensure the ListView rebuilds. The Consumer should handle this.
      // Let's pump again to be sure after provider has been updated.

      await tester.pumpAndSettle(); // Let UI rebuild after tasks are potentially loaded for the initial _selectedDay

      // Check if the task is displayed
      expect(find.text('Test Task for Today'), findsOneWidget);
      expect(find.text('Description for today task'), findsOneWidget);

      // Check for event marker (TableCalendar should render markers based on eventLoader)
      // This is harder to verify directly without knowing TableCalendar's internals for markers.
      // However, if eventLoader is called and returns events, markers *should* appear.
      // We can infer this if the task is loaded correctly after selection.
      // A more direct test for markers would require a custom finder or deeper widget inspection.
    });
     testWidgets('selecting a different day updates the task list', (WidgetTester tester) async {
      final todoProvider = TodoProvider();
      final today = DateTime.now();
      final tomorrow = today.add(const Duration(days: 1));

      final taskToday = TodoItem(id: 1, title: 'Task Today', dueDate: today, createdAt: today);
      final taskTomorrow = TodoItem(id: 2, title: 'Task Tomorrow', dueDate: tomorrow, createdAt: today);

      todoProvider.allTodos.addAll([taskToday, taskTomorrow]);

      await pumpCalendarScreen(tester, todoProvider);
      await tester.pumpAndSettle();

      // Initially, today is selected, so "Task Today" should be visible
      expect(find.text('Task Today'), findsOneWidget);
      expect(find.text('Task Tomorrow'), findsNothing);

      // Tap on tomorrow's date
      // Ensure tomorrow is visible on the calendar, adjust if necessary (e.g. go to next page)
      // For simplicity, assuming tomorrow is on the same calendar page.
      String tomorrowDayString = tomorrow.day.toString();

      // Find all text widgets with tomorrow's day number.
      // This is to handle cases where the day number might appear for previous/next month as well.
      // We want to tap the one that's not greyed out (i.e., part of the current month).
      // `TableCalendar` usually has specific styling or parent widgets for days outside the current month.
      // This is a simplified approach. A more robust test would find the specific `InkWell` or `GestureDetector`
      // for the day cell based on its properties, not just the text.

      // First, try to find a non-greyed out version.
      // This is hard without specific knowledge of TableCalendar's internal structure for active vs inactive days.
      // We'll tap the first one found for now, which is a common simplification.

      // If today is near the end of the month, tomorrow might be on the next page.
      if (tomorrow.month != today.month) {
        // Find the "next page" button (usually an arrow icon) and tap it.
        await tester.tap(find.byIcon(Icons.chevron_right));
        await tester.pumpAndSettle();
      }

      await tester.tap(find.text(tomorrowDayString).first);
      await tester.pumpAndSettle();

      // Now, "Task Tomorrow" should be visible, and "Task Today" should not.
      expect(find.text('Task Today'), findsNothing);
      expect(find.text('Task Tomorrow'), findsOneWidget);
    });
  });
}
