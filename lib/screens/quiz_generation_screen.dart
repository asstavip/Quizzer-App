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
        difficultyPrompt = selectedQuizType == QuizType.truefalse ? AppStrings.easyPrompt : AppStrings.easyPromptMultiple;
      case QuizDifficulty.medium:
        difficultyPrompt = selectedQuizType == QuizType.truefalse ? AppStrings.mediumPrompt : AppStrings.mediumPromptMultiple;
      case QuizDifficulty.hard:
        difficultyPrompt = selectedQuizType == QuizType.truefalse ? AppStrings.hardPrompt : AppStrings.hardPromptMultiple;
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

      cleanedText = cleanedText.substring(startIndex, endIndex)
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
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [{
            "parts": [{
              "text": "${_getPrompt()} Based on this text: $text"
            }]
          }],
          "generationConfig": {
            "temperature": 0.3,
            "topK": 1,
            "topP": 1,
            "maxOutputTokens": 2048,
            "stopSequences": ["**", "#"]
          },
        }),
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (!data.containsKey('candidates') || data['candidates'].isEmpty) {
          throw Exception('Invalid API response format');
        }

        String generatedText = data['candidates'][0]['content']['parts'][0]['text'] as String;
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
      appBar: AppBar(title: Text(AppStrings.quizSettings.tr())),
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
              onPressed: isLoading ? null : () => generateQuestions(extractedData),
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

  Widget _buildQuizTypeCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quiz Type',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SegmentedButton<QuizType>(
              segments: const [
                ButtonSegment<QuizType>(
                  value: QuizType.truefalse,
                  label: Text('True/False'),
                  icon: Icon(Icons.check_circle_outline),
                ),
                ButtonSegment<QuizType>(
                  value: QuizType.multichoice,
                  label: Text('Multiple Choice'),
                  icon: Icon(Icons.format_list_bulleted),
                ),
              ],
              selected: {selectedQuizType},
              onSelectionChanged: (Set<QuizType> newSelection) {
                setState(() {
                  selectedQuizType = newSelection.first;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.difficultyLevel.tr(),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SegmentedButton<QuizDifficulty>(
              segments: [
                ButtonSegment<QuizDifficulty>(
                  value: QuizDifficulty.easy,
                  label: Text(AppStrings.easy.tr()),
                  icon: const Icon(Icons.sentiment_satisfied),
                ),
                ButtonSegment<QuizDifficulty>(
                  value: QuizDifficulty.medium,
                  label: Text(AppStrings.medium.tr()),
                  icon: const Icon(Icons.sentiment_neutral),
                ),
                ButtonSegment<QuizDifficulty>(
                  value: QuizDifficulty.hard,
                  label: Text(AppStrings.hard.tr()),
                  icon: const Icon(Icons.sentiment_very_dissatisfied),
                ),
              ],
              selected: {selectedDifficulty},
              onSelectionChanged: (Set<QuizDifficulty> newSelection) {
                setState(() {
                  selectedDifficulty = newSelection.first;
                });
              },
            ),
          ],
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