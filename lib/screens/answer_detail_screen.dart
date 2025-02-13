import 'package:flutter/material.dart';
import 'package:pdf_uploader/utils/strings.dart';
import 'package:easy_localization/easy_localization.dart';

class AnswerDetailScreen extends StatelessWidget {
  static const String id = 'answer_detail';

  const AnswerDetailScreen({super.key});

  String _formatAnswer(dynamic answer, Map<String, dynamic> question) {
    if (answer == null) return AppStrings.noAnswer.tr();
    
    if (question['type'] == 'truefalse') {
      return answer.toString().tr();
    } else {
      final options = question['options'] as List;
      final answerText = options.firstWhere(
        (option) => option.startsWith('$answer)'),
        orElse: () => '$answer)',
      );
      return answerText;
    }
  }

  Widget _buildOptionItem(String option, String correctAnswer, String? userAnswer) {
    final isCorrectAnswer = option.startsWith('$correctAnswer)');
    final isUserAnswer = userAnswer != null && option.startsWith('$userAnswer)');
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              option,
              softWrap: true,
              style: TextStyle(
                height: 1.5,
                color: isCorrectAnswer 
                    ? Colors.green 
                    : (isUserAnswer && !isCorrectAnswer ? Colors.red : null),
                fontWeight: isCorrectAnswer || isUserAnswer ? FontWeight.bold : null,
              ),
            ),
          ),
          if (isCorrectAnswer)
            const Icon(Icons.check_circle, color: Colors.green, size: 20)
          else if (isUserAnswer)
            const Icon(Icons.cancel, color: Colors.red, size: 20),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final question = args['question'];
    final dynamic userAnswer = args['userAnswer'];
    final int questionNumber = args['questionNumber'];
    final dynamic correctAnswer = question['questionAnswer'];
    final bool isCorrect = userAnswer == correctAnswer;
    final String explanation = question['explanation'] ?? 'No explanation available';
    final bool isMultiChoice = question['type'] == 'multichoice';

    return Scaffold(
      appBar: AppBar(
        title: Text('${AppStrings.questionDetailsTitlePrefix.tr()} $questionNumber'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Question Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.questionLabel.tr(),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        question['questionText'],
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      if (isMultiChoice) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Options:',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        ...List<Widget>.from(
                          (question['options'] as List).map(
                            (option) => _buildOptionItem(
                              option, 
                              correctAnswer, 
                              userAnswer
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Your Answer Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isCorrect ? Icons.check_circle : Icons.cancel,
                            color: isCorrect ? Colors.green : Colors.red,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            AppStrings.yourAnswerLabel.tr(),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatAnswer(userAnswer, question),
                        style: TextStyle(
                          fontSize: 18,
                          color: userAnswer == null ? Colors.orange : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        softWrap: true,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Correct Answer Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            AppStrings.correctAnswerLabel.tr(),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatAnswer(correctAnswer, question),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        softWrap: true,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Explanation Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.lightbulb_outline,
                            color: Colors.amber,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            AppStrings.explanationLabel.tr(),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        explanation,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.5,
                        ),
                        softWrap: true,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
