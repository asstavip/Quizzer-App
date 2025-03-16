import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class QuizDatabaseHelper {
  static final QuizDatabaseHelper _instance = QuizDatabaseHelper._internal();
  static Database? _database;

  factory QuizDatabaseHelper() => _instance;

  QuizDatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'quiz_history.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
    );
  }

  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE quiz_history(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        date TEXT,
        score INTEGER,
        total_questions INTEGER,
        questions TEXT,
        user_answers TEXT
      )
    ''');
  }

  Future<int> saveQuiz(Map<String, dynamic> quiz) async {
    final db = await database;
    return await db.insert('quiz_history', quiz);
  }

  Future<List<Map<String, dynamic>>> getQuizHistory() async {
    final db = await database;
    return await db.query('quiz_history', orderBy: 'date DESC');
  }

  Future<Map<String, dynamic>?> getQuiz(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'quiz_history',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  Future<int> deleteQuiz(int id) async {
    final db = await database;
    return await db.delete(
      'quiz_history',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}