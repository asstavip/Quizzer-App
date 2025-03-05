import 'dart:convert';

class QuizHistory {
  final String date;
  final int score;
  final int totalQuestions;
  final String quizType;
  final String difficulty;
  final String pdfName;
  final List<Map<String, dynamic>>? questionsData;
  final dynamic userAnswers; // Add this field

  QuizHistory({
    required this.date,
    required this.score,
    required this.totalQuestions,
    required this.quizType,
    required this.difficulty,
    required this.pdfName,
    this.questionsData,
    this.userAnswers, // Add this parameter
  });

  Map<String, dynamic> toJson() => {
        'date': date,
        'score': score,
        'totalQuestions': totalQuestions,
        'quizType': quizType,
        'difficulty': difficulty,
        'pdfName': pdfName,
        'questionsData': questionsData,
        'userAnswers': userAnswers, // Add this field
      };

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
        userAnswers: json['userAnswers'], // Add this field
      );

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
