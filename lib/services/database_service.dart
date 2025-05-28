import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/todo_item.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'todo_database.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE todos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        dueDate INTEGER,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL
      )
    ''');
  }

  // 할일 추가
  Future<int> insertTodo(TodoItem todo) async {
    final db = await database;
    final now = DateTime.now();
    final todoWithTimestamp = todo.copyWith(updatedAt: now);
    return await db.insert('todos', todoWithTimestamp.toJson());
  }

  // 모든 할일 조회
  Future<List<TodoItem>> getAllTodos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'todos',
      orderBy: 'createdAt DESC',
    );

    return List.generate(maps.length, (i) {
      return TodoItem.fromJson(maps[i]);
    });
  }

  // 기간 없는 작업 조회
  Future<List<TodoItem>> getSimpleTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'todos',
      where: 'dueDate IS NULL',
      orderBy: 'createdAt DESC',
    );

    return List.generate(maps.length, (i) {
      return TodoItem.fromJson(maps[i]);
    });
  }

  // 기간 있는 작업 조회
  Future<List<TodoItem>> getDeadlineTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'todos',
      where: 'dueDate IS NOT NULL',
      orderBy: 'dueDate ASC',
    );

    return List.generate(maps.length, (i) {
      return TodoItem.fromJson(maps[i]);
    });
  }

  // 할일 업데이트
  Future<int> updateTodo(TodoItem todo) async {
    final db = await database;
    final updatedTodo = todo.copyWith(updatedAt: DateTime.now());
    return await db.update(
      'todos',
      updatedTodo.toJson(),
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  // 할일 삭제
  Future<int> deleteTodo(int id) async {
    final db = await database;
    return await db.delete('todos', where: 'id = ?', whereArgs: [id]);
  }

  // 완료된 할일들 삭제
  Future<int> deleteCompletedTodos() async {
    final db = await database;
    return await db.delete('todos', where: 'isCompleted = ?', whereArgs: [1]);
  }

  // 데이터베이스 닫기
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
