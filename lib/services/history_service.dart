import 'package:pdf_uploader/domain/quiz_history.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryService {
  static const String _storageKey = 'quiz_history';

  // Save quiz history
  static Future<bool> saveQuizHistory(QuizHistory history) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? storedHistory = prefs.getString(_storageKey);

      List<QuizHistory> historyList = [];
      if (storedHistory != null && storedHistory.isNotEmpty) {
        historyList = QuizHistory.fromJsonList(storedHistory);
      }

      historyList.add(history);

      return await prefs.setString(
          _storageKey, QuizHistory.toJsonList(historyList));
    } catch (e) {
      print('Error saving quiz history: $e');
      return false;
    }
  }

  // Get all saved quiz history
  static Future<List<QuizHistory>> getQuizHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? storedHistory = prefs.getString(_storageKey);

      if (storedHistory == null || storedHistory.isEmpty) {
        return [];
      }

      return QuizHistory.fromJsonList(storedHistory);
    } catch (e) {
      print('Error retrieving quiz history: $e');
      return [];
    }
  }

  // Clear all history
  static Future<bool> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.remove(_storageKey);
  }

  // Add this method to the HistoryService class
  static Future<bool> deleteQuizHistoryItem(QuizHistory itemToDelete) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? storedHistory = prefs.getString(_storageKey);

      if (storedHistory == null || storedHistory.isEmpty) {
        return false;
      }

      List<QuizHistory> historyList = QuizHistory.fromJsonList(storedHistory);
      historyList.removeWhere((item) => item.date == itemToDelete.date);

      return await prefs.setString(
          _storageKey, QuizHistory.toJsonList(historyList));
    } catch (e) {
      print('Error deleting quiz history item: $e');
      return false;
    }
  }
}
