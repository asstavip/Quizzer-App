import 'package:flutter/material.dart';
import 'package:pdf_uploader/utils/strings.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:pdf_uploader/widgets/history_icon.dart';
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
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final List<Map<String, dynamic>> questions = args['questions'];
    final dynamic userAnswers = args['userAnswers']; // This could be null
    final int score = args['score'];
    final bool isHistoryView = args['isHistoryView'] ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.quizReview.tr()),
        actions: [
          const HistoryIcon(), // Add this line
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                '${AppStrings.scoreText.tr()} $score/${questions.length}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: questions.length,
        itemBuilder: (context, index) {
          final question = questions[index];
          final userAnswer = userAnswers != null ? userAnswers[index] : null;
          final bool isAnswered = userAnswer != null;
          final bool isCorrect = isHistoryView
              ? (userAnswer != null && _isAnswerCorrect(userAnswer, question))
              : _isAnswerCorrect(userAnswer, question);

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
                    _formatAnswer(userAnswer, question),
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
