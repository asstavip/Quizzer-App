import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:pdf_uploader/screens/quiz_screen.dart';
import 'package:pdf_uploader/utils/strings.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:pdf_uploader/widgets/history_icon.dart';

enum QuizDifficulty { easy, medium, hard }

enum QuizType { truefalse, multichoice }

class QuizSettings {
  final int questionCount;
  final QuizDifficulty difficulty;
  final bool timedMode;
  final int timePerQuestion;
  final QuizType quizType;

  QuizSettings({
    required this.questionCount,
    required this.difficulty,
    required this.timedMode,
    required this.timePerQuestion,
    required this.quizType,
  });
}

class QuizGenerationScreen extends StatefulWidget {
  static const String id = 'generateQuiz';
  const QuizGenerationScreen({super.key});

  @override
  State<QuizGenerationScreen> createState() => _QuizGenerationScreenState();
}

class _QuizGenerationScreenState extends State<QuizGenerationScreen> {
  bool isLoading = false;
  int selectedQuestionCount = 5;
  QuizDifficulty selectedDifficulty = QuizDifficulty.easy;
  QuizType selectedQuizType = QuizType.truefalse;
  bool timedModeEnabled = false;
  int timePerQuestion = 30;

  // Get prompt text based on difficulty and quiz type
  String _getPrompt() {
    // Difficulty part
    String difficultyPrompt;
    switch (selectedDifficulty) {
      case QuizDifficulty.easy:
        difficultyPrompt = selectedQuizType == QuizType.truefalse
            ? AppStrings.easyPrompt
            : AppStrings.easyPromptMultiple;
      case QuizDifficulty.medium:
        difficultyPrompt = selectedQuizType == QuizType.truefalse
            ? AppStrings.mediumPrompt
            : AppStrings.mediumPromptMultiple;
      case QuizDifficulty.hard:
        difficultyPrompt = selectedQuizType == QuizType.truefalse
            ? AppStrings.hardPrompt
            : AppStrings.hardPromptMultiple;
    }

    // Quiz type part
    String formatPrompt = selectedQuizType == QuizType.truefalse
        ? """Generate exactly $selectedQuestionCount true/false questions without any headers or markdown formatting.
          The questions must be in the same language as the provided text.
          Return a valid JSON array in this exact format:
          [
            {
              "question": "Question text here",
              "answer": true/false,
              "explanation": "Explanation why"
            }
          ]"""
        : """Generate exactly $selectedQuestionCount multiple choice questions without any headers or markdown formatting.
          The questions must be in the same language as the provided text.
          Return a valid JSON array in this exact format:
          [
            {
              "question": "Question text here",
              "options": ["A) First option", "B) Second option", "C) Third option", "D) Fourth option"],
              "correctAnswer": "A",
              "explanation": "Explanation why"
            }
          ]""";

    return """Return only a valid JSON array without any additional formatting or text.
          $difficultyPrompt
          $formatPrompt""";
  }

  // Process AI response and extract questions
  List<Map<String, dynamic>> _processResponse(String response) {
    try {
      // Clean up response text
      String cleanedText = response
          .replaceAll(RegExp(r'\*\*.*?\*\*'), '')
          .replaceAll(RegExp(r'#+\s.*'), '')
          .replaceAll(RegExp(r'```(?:json)?'), '')
          .replaceAll('`', '')
          .trim();

      // Find JSON array boundaries
      int startIndex = cleanedText.indexOf('[');
      int endIndex = cleanedText.lastIndexOf(']') + 1;

      if (startIndex == -1 || endIndex == 0) {
        throw const FormatException('No valid JSON array found');
      }

      cleanedText = cleanedText
          .substring(startIndex, endIndex)
          .replaceAll(RegExp(r',(\s*[}\]])', multiLine: true), r' ')
          .replaceAll(RegExp(r'\n\s*'), ' ');
      if (kDebugMode) {
        print(cleanedText);
      }

      final List<dynamic> jsonArray = jsonDecode(cleanedText);
      return jsonArray.map((item) => _transformQuestion(item)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error processing response: $e');
      }
      throw FormatException('Failed to parse questions: ${e.toString()}');
    }
  }

  // Transform question to standardized format
  Map<String, dynamic> _transformQuestion(Map<String, dynamic> raw) {
    if (selectedQuizType == QuizType.truefalse) {
      return {
        "questionText": raw['question'],
        "questionAnswer": raw['answer'],
        "explanation": raw['explanation'],
        "type": "truefalse"
      };
    } else {
      // Process multiple choice questions
      final List<String> options = List<String>.from(raw['options']);
      final String correctAnswer = raw['correctAnswer'];

      // Don't shuffle the options
      return {
        "questionText": raw['question'],
        "options": options,
        "questionAnswer": correctAnswer,
        "explanation": raw['explanation'],
        "type": "multichoice"
      };
    }
  }

  // Display error in UI
  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Generate quiz questions using AI
  Future<void> generateQuestions(Map<String, dynamic> extractedData) async {
    setState(() => isLoading = true);
    try {
      final apiKey = dotenv.env['API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('API key not found');
      }

      final String text = extractedData['text'];
      if (text.isEmpty) {
        throw Exception('No text content found');
      }

      final url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1/models/gemini-2.0-flash:generateContent?key=$apiKey');
      print(_getPrompt());
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              "contents": [
                {
                  "parts": [
                    {"text": "${_getPrompt()} Based on this text: $text"}
                  ]
                }
              ],
              "generationConfig": {
                "temperature": 0.3,
                "topK": 1,
                "topP": 1,
                "maxOutputTokens": 2048,
                "stopSequences": ["**", "#"]
              },
            }),
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (!data.containsKey('candidates') || data['candidates'].isEmpty) {
          throw Exception('Invalid API response format');
        }

        String generatedText =
            data['candidates'][0]['content']['parts'][0]['text'] as String;
        final questionList = _processResponse(generatedText);

        if (questionList.isEmpty) {
          throw Exception('No questions generated');
        }

        if (!mounted) return;

        Navigator.pushNamed(context, QuizScreen.id, arguments: {
          'questions': questionList,
          'settings': QuizSettings(
            questionCount: selectedQuestionCount,
            difficulty: selectedDifficulty,
            timedMode: timedModeEnabled,
            timePerQuestion: timePerQuestion,
            quizType: selectedQuizType,
          ),
          'fileName': extractedData['fileName'],
        });
      } else {
        final errorBody = jsonDecode(response.body);
        throw HttpException('API Error: ${errorBody['error']['message']}');
      }
    } on SocketException {
      _showError('No Internet connection');
    } on TimeoutException {
      _showError('Request timed out');
    } on FormatException catch (e) {
      _showError('Error parsing response: ${e.message}');
    } on HttpException catch (e) {
      _showError(e.message);
    } on Exception catch (e) {
      _showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> extractedData =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.quizSettings.tr()),
        actions: const [
          HistoryIcon(), // Add this line
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildQuestionCountCard(),
            const SizedBox(height: 16),
            _buildQuizTypeCard(),
            const SizedBox(height: 16),
            _buildDifficultyCard(),
            const SizedBox(height: 16),
            _buildTimedModeCard(),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed:
                  isLoading ? null : () => generateQuestions(extractedData),
              icon: isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                  : const Icon(Icons.quiz, size: 24, color: Colors.white),
              label: Text(isLoading
                  ? AppStrings.generating.tr()
                  : AppStrings.generateQuiz.tr()),
            ),
          ],
        ),
      ),
    );
  }

  // UI Components
  Widget _buildQuestionCountCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.numberOfQuestions.tr(),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Slider(
              value: selectedQuestionCount.toDouble(),
              min: 5,
              max: 20,
              divisions: 15,
              label: selectedQuestionCount.toString(),
              onChanged: (value) {
                setState(() {
                  selectedQuestionCount = value.round();
                });
              },
            ),
            Text(
              '$selectedQuestionCount ${AppStrings.questionsLabel.tr()}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  // Custom slider thumb shape with question count display

  Widget _buildQuizTypeCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quiz Type',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(4),
              child: Stack(
                children: [
                  // Animated selection indicator
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    left: selectedQuizType == QuizType.truefalse
                        ? 0
                        : MediaQuery.of(context).size.width / 2 - 48,
                    top: 0,
                    bottom: 0,
                    width: MediaQuery.of(context).size.width / 2 - 32,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  // Buttons
                  Row(
                    children: [
                      _buildTabOption(
                        label: 'True/False',
                        icon: Icons.check_circle_outline,
                        isSelected: selectedQuizType == QuizType.truefalse,
                        onTap: () => setState(
                            () => selectedQuizType = QuizType.truefalse),
                      ),
                      _buildTabOption(
                        label: 'Multiple Choice',
                        icon: Icons.format_list_bulleted,
                        isSelected: selectedQuizType == QuizType.multichoice,
                        onTap: () => setState(
                            () => selectedQuizType = QuizType.multichoice),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabOption({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey.shade700,
                size: 20,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.difficultyLevel.tr(),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildDifficultyOption(
                  label: AppStrings.easy.tr(),
                  icon: Icons.sentiment_satisfied,
                  color: Colors.green,
                  isSelected: selectedDifficulty == QuizDifficulty.easy,
                  onTap: () =>
                      setState(() => selectedDifficulty = QuizDifficulty.easy),
                ),
                _buildDifficultyOption(
                  label: AppStrings.medium.tr(),
                  icon: Icons.sentiment_neutral,
                  color: Colors.orange,
                  isSelected: selectedDifficulty == QuizDifficulty.medium,
                  onTap: () => setState(
                      () => selectedDifficulty = QuizDifficulty.medium),
                ),
                _buildDifficultyOption(
                  label: AppStrings.hard.tr(),
                  icon: Icons.sentiment_very_dissatisfied,
                  color: Colors.red,
                  isSelected: selectedDifficulty == QuizDifficulty.hard,
                  onTap: () =>
                      setState(() => selectedDifficulty = QuizDifficulty.hard),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyOption({
    required String label,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? color : Colors.grey.shade600,
                size: 24,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color:
                      isSelected ? Colors.grey.shade700 : Colors.grey.shade700,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimedModeCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.timedMode.tr(),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Switch(
                  value: timedModeEnabled,
                  onChanged: (value) {
                    setState(() {
                      timedModeEnabled = value;
                    });
                  },
                ),
              ],
            ),
            if (timedModeEnabled) ...[
              const SizedBox(height: 8),
              Text(
                AppStrings.timePerQuestion.tr(),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Slider(
                value: timePerQuestion.toDouble(),
                min: 10,
                max: 60,
                divisions: 10,
                label: '$timePerQuestion ${AppStrings.secondsLabel.tr()}',
                onChanged: (value) {
                  setState(() {
                    timePerQuestion = value.round();
                  });
                },
              ),
              Text(
                '$timePerQuestion ${AppStrings.secondsPerQuestion.tr()}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
