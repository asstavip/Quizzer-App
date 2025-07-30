import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pdf_uploader/domain/quiz_history.dart';
import 'package:pdf_uploader/utils/functions.dart';

class HistoryService {
  static const String _boxName = 'quiz_history';

  static Future<void> initHive() async {
    await Hive.initFlutter();
    Hive.registerAdapter(QuizHistoryAdapter());
    await Hive.openBox<QuizHistory>(_boxName);
  }

  // Save quiz history
  static Future<bool> saveQuizHistory(QuizHistory history) async {
    try {
      final box = Hive.box<QuizHistory>(_boxName);
      await box.add(history);
      return true;
    } catch (e) {
      debugPrint('Error saving quiz history: $e');
      return false;
    }
  }

  // Get all saved quiz history
  static Future<List<QuizHistory>> getQuizHistory() async {
    try {
      final box = Hive.box<QuizHistory>(_boxName);
      return box.values.toList();
    } catch (e) {
      debugPrint('Error retrieving quiz history: $e');
      return [];
    }
  }

  // Clear all history
  static Future<bool> clearHistory() async {
    try {
      final box = Hive.box<QuizHistory>(_boxName);
      await box.clear();
      return true;
    } catch (e) {
      debugPrint('Error clearing quiz history: $e');
      return false;
    }
  }

  // Delete a specific quiz history item
  static Future<bool> deleteQuizHistoryItem(QuizHistory itemToDelete) async {
    try {
      final box = Hive.box<QuizHistory>(_boxName);

      // Find the item with the matching date
      final Map<dynamic, QuizHistory> map = box.toMap();
      dynamic keyToDelete;

      map.forEach((key, value) {
        if (value.date == itemToDelete.date) {
          keyToDelete = key;
        }
      });

      if (keyToDelete != null) {
        await box.delete(keyToDelete);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting quiz history item: $e');
      return false;
    }
  }
}