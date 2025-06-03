import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/todo_provider.dart';
import '../models/todo_item.dart'; // Assuming TodoItem model path

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<TodoItem> _selectedDayTasks = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    // It's good practice to load initial tasks for the selected day
    // if provider is already available, but eventLoader and ListView will handle it.
  }

  List<TodoItem> _getTasksForDay(DateTime day, TodoProvider provider) {
    return provider.allTodos.where((task) {
      if (task.dueDate == null) return false;
      return isSameDay(task.dueDate, day);
    }).toList();
  }

  void _updateSelectedDayTasks(DateTime day, TodoProvider provider) {
    setState(() {
      _selectedDayTasks = _getTasksForDay(day, provider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Get theme
    return Scaffold(
      backgroundColor: Colors.transparent, // Make scaffold background transparent
      appBar: AppBar(
        title: const Text('Calendar'),
        backgroundColor: Colors.transparent, // Make AppBar transparent
        elevation: 0, // Remove AppBar shadow
      ),
      body: Consumer<TodoProvider>(
        builder: (context, todoProvider, child) {
          // Update tasks for the selected day when the provider notifies listeners,
          // or when the selected day changes.
          // This call ensures that if todos are added/removed/updated, the list refreshes.
          // We call it here because Consumer rebuilds this part.
          // We might need a more sophisticated way if this causes too many rebuilds.
          // For now, this ensures data consistency.
          WidgetsBinding.instance.addPostFrameCallback((_) {
             if (mounted && _selectedDay != null) {
               // Check if _selectedDayTasks needs update based on todoProvider.allTodos
               // This is a bit tricky; a direct call to _updateSelectedDayTasks might be too frequent.
               // Let's rely on onDaySelected to update _selectedDayTasks for now and eventLoader for markers.
               // If tasks change for the currently selected day, this consumer will rebuild the list.
               final currentTasks = _getTasksForDay(_selectedDay!, todoProvider);
               if (_selectedDayTasks.length != currentTasks.length || !_selectedDayTasks.every((task) => currentTasks.contains(task))) {
                  // Basic check, might need deep comparison or a versioning mechanism in provider
                  _selectedDayTasks = currentTasks;
               }
             }
          });


          return Column(
            children: [
              TableCalendar<TodoItem>( // Specify the event type
                firstDay: DateTime.utc(2010, 10, 16),
                lastDay: DateTime.utc(2030, 3, 14),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                eventLoader: (day) => _getTasksForDay(day, todoProvider),
                onDaySelected: (selectedDay, focusedDay) {
                  if (!isSameDay(_selectedDay, selectedDay)) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                      _selectedDayTasks = _getTasksForDay(selectedDay, todoProvider);
                    });
                  }
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                  // Optionally, update tasks if the selected day is on a new page
                  // and you want the list below to reflect the first selectable day of the new page
                  // For now, tasks list only updates on explicit day selection.
                },
                calendarFormat: CalendarFormat.month,
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: theme.textTheme.titleLarge ?? const TextStyle(), // Apply theme text style
                ),
                daysOfWeekStyle: DaysOfWeekStyle( // Style for Mon, Tue, etc.
                  weekdayStyle: TextStyle(color: theme.textTheme.bodySmall?.color?.withOpacity(0.7)),
                  weekendStyle: TextStyle(color: theme.colorScheme.secondary.withOpacity(0.7)),
                ),
                calendarStyle: CalendarStyle(
                  defaultTextStyle: TextStyle(color: theme.textTheme.bodyLarge?.color),
                  weekendTextStyle: TextStyle(color: theme.colorScheme.secondary),
                  outsideTextStyle: TextStyle(color: theme.textTheme.bodySmall?.color?.withOpacity(0.5)),
                  selectedDecoration: BoxDecoration(
                    color: theme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  // Style for event markers
                  markersMaxCount: 1,
                  markerDecoration: BoxDecoration(
                    color: theme.colorScheme.secondary.withOpacity(0.7), // Use secondary color for markers
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(height: 16.0), // Increased spacing
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0), // Adjusted padding
                child: Text(
                  _selectedDay != null
                      ? 'Tasks for ${MaterialLocalizations.of(context).formatShortDate(_selectedDay!)}'
                      : 'Select a day to see tasks',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: _selectedDayTasks.isNotEmpty
                    ? ListView.builder(
                        itemCount: _selectedDayTasks.length,
                        itemBuilder: (context, index) {
                          final task = _selectedDayTasks[index];
                          return Padding( // Added padding around ListTile
                            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                            child: ListTile(
                              title: Text(
                                task.title,
                                style: theme.textTheme.titleMedium,
                              ),
                              subtitle: task.description != null && task.description!.isNotEmpty
                                  ? Text(
                                      task.description!,
                                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodySmall?.color),
                                    )
                                  : null,
                              tileColor: theme.cardColor.withOpacity(isSameDay(_selectedDay, task.dueDate) ? 0.1 : 0.05), // Subtle background
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        },
                      )
                    : Center( // Centered "No tasks" message
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'No tasks for this day.',
                            style: theme.textTheme.bodyLarge?.copyWith(color: theme.textTheme.bodySmall?.color),
                          ),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
