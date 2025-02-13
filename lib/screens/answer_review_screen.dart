import 'package:flutter/material.dart';
import 'package:pdf_uploader/utils/strings.dart';
import 'package:easy_localization/easy_localization.dart';
import 'answer_detail_screen.dart';

class QuizReviewScreen extends StatelessWidget {
  static const String id = 'quiz_review';

  const QuizReviewScreen({super.key});

  String _formatAnswer(dynamic answer, Map<String, dynamic> question) {
    if (answer == null) return AppStrings.timesUp.tr();
    
    if (question['type'] == 'truefalse') {
      return answer.toString().tr();
    } else {
      // For multiple choice, show the full option text for the selected answer
      final options = question['options'] as List;
      final answerText = options.firstWhere(
        (option) => option.startsWith('$answer)'),
        orElse: () => '$answer)',
      );
      return answerText;
    }
  }

  bool _isAnswerCorrect(dynamic userAnswer, Map<String, dynamic> question) {
    if (userAnswer == null) return false;
    if (question['type'] == 'truefalse') {
      return userAnswer == question['questionAnswer'];
    } else {
      return userAnswer == question['questionAnswer'];
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final List<Map<String, dynamic>> questions = args['questions'];
    final List<dynamic> userAnswers = args['userAnswers'];
    final int score = args['score'];

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.quizReview.tr()),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                '${AppStrings.scoreText.tr()} $score/${questions.length}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: questions.length,
        itemBuilder: (context, index) {
          final question = questions[index];
          final userAnswer = userAnswers[index];
          final bool isCorrect = _isAnswerCorrect(userAnswer, question);
          final String formattedAnswer = _formatAnswer(userAnswer, question);

          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: isCorrect ? Colors.green : Colors.red,
                size: 32,
              ),
              title: Text(
                '${AppStrings.questionNumberText.tr()} ${index + 1}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question['questionText'],
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formattedAnswer,
                    style: TextStyle(
                      color: userAnswer == null ? Colors.orange : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    softWrap: true,
                  ),
                ],
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AnswerDetailScreen.id,
                  arguments: {
                    'question': question,
                    'userAnswer': userAnswer,
                    'questionNumber': index + 1,
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}