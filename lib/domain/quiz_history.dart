import 'dart:convert';
import 'package:hive/hive.dart';

part 'quiz_history.g.dart';

@HiveType(typeId: 0)
class QuizHistory {
  @HiveField(0)
  final String date;

  @HiveField(1)
  final int score;

  @HiveField(2)
  final int totalQuestions;

  @HiveField(3)
  final String quizType;

  @HiveField(4)
  final String difficulty;

  @HiveField(5)
  final String pdfName;

  @HiveField(6)
  final List<Map<String, dynamic>>? questionsData;

  @HiveField(7)
  final dynamic userAnswers;

  QuizHistory({
    required this.date,
    required this.score,
    required this.totalQuestions,
    required this.quizType,
    required this.difficulty,
    required this.pdfName,
    this.questionsData,
    this.userAnswers,
  });

  // Keep existing toJson method for compatibility
  Map<String, dynamic> toJson() => {
        'date': date,
        'score': score,
        'totalQuestions': totalQuestions,
        'quizType': quizType,
        'difficulty': difficulty,
        'pdfName': pdfName,
        'questionsData': questionsData,
        'userAnswers': userAnswers,
      };

  // Keep existing fromJson factory for compatibility
  factory QuizHistory.fromJson(Map<String, dynamic> json) => QuizHistory(
        date: json['date'],
        score: json['score'],
        totalQuestions: json['totalQuestions'],
        quizType: json['quizType'],
        difficulty: json['difficulty'],
        pdfName: json['pdfName'],
        questionsData: json['questionsData'] != null
            ? List<Map<String, dynamic>>.from(
                json['questionsData'].map((x) => Map<String, dynamic>.from(x)))
            : null,
        userAnswers: json['userAnswers'],
      );

  // These static methods can be moved to the service class
  static List<QuizHistory> fromJsonList(String jsonString) {
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => QuizHistory.fromJson(json)).toList();
  }

  static String toJsonList(List<QuizHistory> history) {
    final List<Map<String, dynamic>> jsonList =
        history.map((item) => item.toJson()).toList();
    return jsonEncode(jsonList);
  }
}