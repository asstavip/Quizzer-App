import 'package:flutter/material.dart';
import 'package:pdf_uploader/utils/strings.dart';
import 'package:easy_localization/easy_localization.dart';
import 'answer_detail_screen.dart';

class QuizReviewScreen extends StatelessWidget {
  static const String id = 'quiz_review';

  const QuizReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final List<Map<String, dynamic>> questions = args['questions'];
    final List<bool?> userAnswers = args['userAnswers'];
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
          final bool isCorrect = userAnswer == question['questionAnswer'];

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
              subtitle: Text(question['questionText']),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    userAnswer == null ? AppStrings.timesUp.tr() : userAnswer.toString(),
                    style: TextStyle(
                      color: userAnswer == null ? Colors.orange : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
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