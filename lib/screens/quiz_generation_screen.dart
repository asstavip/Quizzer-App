// lib/screens/quiz_generation_screen.dart

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:pdf_uploader/screens/quiz_screen.dart';
import 'package:pdf_uploader/theme/app_theme.dart';

enum QuizDifficulty { easy, medium, hard }

class QuizSettings {
  final int questionCount;
  final QuizDifficulty difficulty;
  final bool timedMode;
  final int timePerQuestion; // in seconds

  QuizSettings({
    required this.questionCount,
    required this.difficulty,
    required this.timedMode,
    required this.timePerQuestion,
  });
}

class QuizGenerationScreen extends StatefulWidget {
  static const String id = 'generateQuiz';

  const QuizGenerationScreen({super.key});
  @override
  // ignore: library_private_types_in_public_api
  _QuizGenerationScreenState createState() => _QuizGenerationScreenState();
}

class _QuizGenerationScreenState extends State<QuizGenerationScreen> {
  bool isLoading = false;
  int selectedQuestionCount = 5;
  QuizDifficulty selectedDifficulty = QuizDifficulty.easy;
  bool timedModeEnabled = false;
  int timePerQuestion = 30; // Default 30 seconds per question

  String _getDifficultyPrompt() {
    switch (selectedDifficulty) {
      case QuizDifficulty.easy:
        return """Generate basic, straightforward true/false questions focusing on main concepts and explicit information from the text.
      Include simple explanations that directly reference the text.""";
      case QuizDifficulty.medium:
        return """Generate moderately challenging true/false questions that require understanding relationships between concepts and implicit information from the text.
      Include explanations that show the logical connection between text elements.""";
      case QuizDifficulty.hard:
        return """Generate challenging true/false questions that require deep understanding, analysis, and connecting multiple concepts from the text.
      Include detailed explanations that demonstrate complex reasoning and multiple supporting points from the text.""";
    }
  }

  List<Map<String, dynamic>> _parseQuestions(String jsonText) {
    try {
      // First, try to parse the entire response as a JSON array
      try {
        final List<dynamic> jsonArray = jsonDecode(jsonText);
        return _validateAndTransformQuestions(jsonArray);
      } catch (e) {
        // If that fails, try parsing line by line
        return _parseQuestionsLineByLine(jsonText);
      }
    } catch (e) {
      throw FormatException('Failed to parse questions: $e');
    }
  }

  List<Map<String, dynamic>> _parseQuestionsLineByLine(String text) {
    final List<Map<String, dynamic>> questions = [];
    final lines = text
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .map((line) => line.trim())
        .toList();

    for (final line in lines) {
      try {
        if (line.startsWith('{') && line.endsWith('}')) {
          final Map<String, dynamic> question = jsonDecode(line);
          if (_isValidQuestionFormat(question)) {
            questions.add(_transformQuestion(question));
          }
        }
      } catch (e) {
        continue; // Skip invalid lines instead of failing completely
      }
    }

    if (questions.isEmpty) {
      throw const FormatException('No valid questions found in the response');
    }

    return questions;
  }

  bool _isValidQuestionFormat(Map<String, dynamic> question) {
    return question.containsKey('question') &&
        question.containsKey('answer') &&
        question.containsKey('explanation') &&
        question['question'] is String &&
        question['answer'] is bool &&
        question['explanation'] is String;
  }

  Map<String, dynamic> _transformQuestion(Map<String, dynamic> rawQuestion) {
    return {
      "questionText": rawQuestion['question'],
      "questionAnswer": rawQuestion['answer'],
      "explanation": rawQuestion['explanation'],
    };
  }

  List<Map<String, dynamic>> _validateAndTransformQuestions(
      List<dynamic> jsonArray) {
    return jsonArray.map((item) {
      if (item is! Map<String, dynamic> || !_isValidQuestionFormat(item)) {
        throw const FormatException('Invalid question format');
      }
      return _transformQuestion(item);
    }).toList();
  }

  /// Generates a list of true/false questions based on the given text and
  /// displays a quiz screen with the questions.
  ///
  /// The questions are generated by the Gemini AI model using the
  /// [GenerateContent](https://generativelanguage.googleapis.com/v1beta/docs/reference/rest/v1beta/projects/models/generateContent)
  /// endpoint. The endpoint is called with the following JSON payload:
  ///
  ///
  Future<void> generateQuestions(String text) async {
    setState(() => isLoading = true);

    try {
      final apiKey = dotenv.env['API_KEY']!;
      final url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=$apiKey');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {
                  "text": """${_getDifficultyPrompt()}
                Based on this text: $text
                Generate exactly $selectedQuestionCount true/false questions.
                For each question, provide:
                1. The question statement
                2. Whether it is true or false
                3. A brief explanation of why the answer is correct
                Return the response as a JSON array of objects with this exact format:
                [
                  {
                    "question": "Question text here",
                    "answer": true/false,
                    "explanation": "Explanation of why the answer is true/false"
                  }
                ]"""
                }
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String generatedText =
            data['candidates'][0]['content']['parts'][0]['text'] as String;

        // Clean the generated text
        generatedText =
            generatedText.replaceAll(RegExp(r'```json|```|\`'), '').trim();

        final questionList = _parseQuestions(generatedText);

        if (!mounted) return;

        final quizData = {
          'questions': questionList,
          'settings': QuizSettings(
            questionCount: selectedQuestionCount,
            difficulty: selectedDifficulty,
            timedMode: timedModeEnabled,
            timePerQuestion: timePerQuestion,
          ),
        };

        Navigator.pushNamed(context, QuizScreen.id, arguments: quizData);
      } else {
        throw HttpException('Failed to generate questions: ${response.body}');
      }
    } on SocketException {
      _showError('No Internet connection. Please check your network.');
    } on TimeoutException {
      _showError('Request timed out. Please try again later.');
    } on FormatException {
      _showError('Failed to generate valid questions. Please try again.');
    } on HttpException {
      _showError('Server error. Please try again later.');
    } catch (e) {
      _showError('Unexpected error. Please try again.');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  /// Displays an error message as a snack bar at the bottom of the screen.
  ///
  /// Uses [ScaffoldMessenger] to show a [SnackBar] with the provided [message].
  /// The snack bar is styled with the error color from the current theme's
  /// color scheme.
  ///
  /// If the widget is not currently mounted, the function exits early without
  /// showing the snack bar.
  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String extractedText =
        ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Settings')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Number of Questions',
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
                        '$selectedQuestionCount questions',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Difficulty Level',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      SegmentedButton<QuizDifficulty>(
                        style: ButtonStyle(
                          padding:
                              WidgetStateProperty.all(const EdgeInsets.all(12)),
                          backgroundColor:
                              WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.selected)) {
                              return AppTheme.customColors[
                                  'primary']; // Highlight for selected button
                            }
                            return Colors
                                .grey.shade200; // Default button background
                          }),
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        segments: const [
                          ButtonSegment(
                            value: QuizDifficulty.easy,
                            label: Text('Easy'),
                            icon: Icon(Icons.sentiment_satisfied),
                          ),
                          ButtonSegment(
                            value: QuizDifficulty.medium,
                            label: Text('Medium'),
                            icon: Icon(Icons.sentiment_neutral),
                          ),
                          ButtonSegment(
                            value: QuizDifficulty.hard,
                            label: Text('Hard'),
                            icon: Icon(Icons.sentiment_very_dissatisfied),
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
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Timed Mode',
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
                          'Time per Question',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Slider(
                          value: timePerQuestion.toDouble(),
                          min: 10,
                          max: 60,
                          divisions: 10,
                          label: '$timePerQuestion seconds',
                          onChanged: (value) {
                            setState(() {
                              timePerQuestion = value.round();
                            });
                          },
                        ),
                        Text(
                          '$timePerQuestion seconds per question',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed:
                    isLoading ? null : () => generateQuestions(extractedText),
                icon: isLoading
                    ? Container(
                        width: 24,
                        height: 24,
                        padding: const EdgeInsets.all(2.0),
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : const Icon(Icons.quiz),
                label: Text(isLoading ? 'Generating...' : 'Generate Quiz'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
