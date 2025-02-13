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

  String _getDifficultyPrompt() {
    switch (selectedDifficulty) {
      case QuizDifficulty.easy:
        return AppStrings.easyPrompt;
      case QuizDifficulty.medium:
        return AppStrings.mediumPrompt;
      case QuizDifficulty.hard:
        return AppStrings.hardPrompt;
    }
  }

  String _getQuizTypePrompt() {
    if (selectedQuizType == QuizType.truefalse) {
      return """Generate exactly $selectedQuestionCount true/false questions without any headers or markdown formatting.
              The questions must be in the same language as the provided text.
              Return a valid JSON array in this exact format:
              [
                {
                  "question": "Question text here",
                  "answer": true/false,
                  "explanation": "Explanation why"
                }
              ]""";
    } else {
      return """Generate exactly $selectedQuestionCount multiple choice questions without any headers or markdown formatting.
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
    }
  }

  List<Map<String, dynamic>> _parseQuestions(String jsonText) {
    try {
      // Clean up any markdown or formatting
      String cleanedText = jsonText
          .replaceAll(RegExp(r'\*\*.*?\*\*'), '') // Remove **headers**
          .replaceAll(RegExp(r'#+\s.*'), '') // Remove markdown headers
          .replaceAll(RegExp(r'```(?:json)?'), '') // Remove code blocks
          .replaceAll('`', '') // Remove backticks
          .trim();
          
      // Find the first [ and last ] to extract just the JSON array
      int startIndex = cleanedText.indexOf('[');
      int endIndex = cleanedText.lastIndexOf(']') + 1;
      
      if (startIndex == -1 || endIndex == 0) {
        if (kDebugMode) {
          print('No valid JSON array found in response: $cleanedText');
        }
        return _parseQuestionsLineByLine(cleanedText);
      }
      
      cleanedText = cleanedText.substring(startIndex, endIndex);
      // Clean up any trailing commas in arrays and objects
      cleanedText = cleanedText
          .replaceAll(RegExp(r',(\s*[}\]])', multiLine: true), r'$1')
          .replaceAll(RegExp(r'\n\s*'), ' ');

      if (kDebugMode) {
        print('Cleaned JSON text: $cleanedText');
      }

      final List<dynamic> jsonArray = jsonDecode(cleanedText);
      return _validateAndTransformQuestions(jsonArray);
    } catch (e) {
      if (kDebugMode) {
        print('Failed to parse as array, trying line by line: $e');
      }
      return _parseQuestionsLineByLine(jsonText);
    }
  }

  List<Map<String, dynamic>> _parseQuestionsLineByLine(String text) {
    final List<Map<String, dynamic>> questions = [];
    final lines = text.split('\n')
        .where((line) => line.trim().isNotEmpty)
        .map((line) => line.trim())
        .toList();

    String currentJson = '';
    bool inJsonObject = false;
    int bracketCount = 0;

    for (final line in lines) {
      if (line.contains('{')) {
        if (!inJsonObject) {
          currentJson = '';
          inJsonObject = true;
        }
        bracketCount += line.split('{').length - 1;
      }
      
      if (inJsonObject) {
        currentJson += line;
      }
      
      if (line.contains('}')) {
        bracketCount -= line.split('}').length - 1;
        if (bracketCount == 0) {
          try {
            // Clean up any trailing commas and normalize JSON
            currentJson = currentJson
                .replaceAll(RegExp(r',\s*}'), '}')
                .replaceAll(RegExp(r',\s*]'), ']')
                .replaceAll(RegExp(r'\s+'), ' ');

            if (kDebugMode) {
              print('Processing JSON object: $currentJson');
            }

            final Map<String, dynamic> question = jsonDecode(currentJson);
            
            if (_isValidQuestionFormat(question)) {
              questions.add(_transformQuestion(question));
            } else if (kDebugMode) {
              print('Invalid question format detected: $currentJson');
            }
          } catch (e) {
            if (kDebugMode) {
              print('Failed to parse JSON object: $e');
              print('Line content: $currentJson');
            }
          }
          currentJson = '';
          inJsonObject = false;
        }
      }
    }

    if (questions.isEmpty) {
      throw const FormatException('No valid questions found in the response');
    }

    return questions;
  }

  bool _isValidQuestionFormat(Map<String, dynamic> question) {
    if (selectedQuizType == QuizType.truefalse) {
      return question.containsKey('question') &&
          question.containsKey('answer') &&
          question.containsKey('explanation') &&
          question['question'] is String &&
          question['answer'] is bool &&
          question['explanation'] is String;
    } else {
      if (!question.containsKey('question') ||
          !question.containsKey('options') ||
          !question.containsKey('correctAnswer') ||
          !question.containsKey('explanation')) {
        return false;
      }

      if (!(question['question'] is String) ||
          !(question['options'] is List) ||
          !(question['correctAnswer'] is String) ||
          !(question['explanation'] is String)) {
        return false;
      }

      final options = List<String>.from(question['options']);
      if (options.length != 4) {
        return false;
      }

      // Check if options start with A), B), C), D)
      final expectedPrefixes = ['A)', 'B)', 'C)', 'D)'];
      if (!options.every((opt) => 
          expectedPrefixes.any((prefix) => opt.trim().startsWith(prefix)))) {
        return false;
      }

      // Check if correctAnswer is a single letter A, B, C, or D
      final correctAnswer = question['correctAnswer'];
      if (!RegExp(r'^[A-D]$').hasMatch(correctAnswer)) {
        return false;
      }

      return true;
    }
  }

  Map<String, dynamic> _transformQuestion(Map<String, dynamic> rawQuestion) {
    if (selectedQuizType == QuizType.truefalse) {
      return {
        "questionText": rawQuestion['question'],
        "questionAnswer": rawQuestion['answer'],
        "explanation": rawQuestion['explanation'],
        "type": "truefalse"
      };
    } else {
      // Create a list of options with their original indices
      final List<String> originalOptions = List<String>.from(rawQuestion['options']);
      final String correctAnswer = rawQuestion['correctAnswer'];
      
      // Find the original option that starts with the correct answer letter
      final String correctOptionText = originalOptions
          .firstWhere((opt) => opt.startsWith('$correctAnswer)'));
      
      // Create shuffled options
      final List<String> shuffledOptions = List<String>.from(originalOptions);
      shuffledOptions.shuffle();
      
      // Find new position of correct answer after shuffle
      final int newIndex = shuffledOptions.indexOf(correctOptionText);
      final String newCorrectAnswer = String.fromCharCode(65 + newIndex); // Convert 0->A, 1->B, etc.
      
      return {
        "questionText": rawQuestion['question'],
        "options": shuffledOptions,
        "questionAnswer": newCorrectAnswer,
        "explanation": rawQuestion['explanation'],
        "type": "multichoice"
      };
    }
  }

  List<Map<String, dynamic>> _validateAndTransformQuestions(List<dynamic> jsonArray) {
    return jsonArray.map((item) {
      if (item is! Map<String, dynamic> || !_isValidQuestionFormat(item)) {
        throw const FormatException('Invalid question format');
      }
      return _transformQuestion(item);
    }).toList();
  }

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

  Future<void> generateQuestions(Map<String, dynamic> extractedData) async {
    setState(() => isLoading = true);
    try {
      final apiKey = dotenv.env['API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('API key not found. Please add your API key to the .env file.');
      }

      final String text = extractedData['text'];
      if (text.isEmpty) {
        throw Exception('No text content found in the PDF.');
      }

      final url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1/models/gemini-pro:generateContent?key=$apiKey');

      if (kDebugMode) {
        print('Sending request to Gemini API with text length: ${text.length}');
      }

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {
                  "text": """Return only a valid JSON array without any additional formatting or text.
                  ${_getDifficultyPrompt()}
                  ${_getQuizTypePrompt()}
                  Based on this text: $text"""
                }
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
      ).timeout(const Duration(seconds: 60));

      if (kDebugMode) {
        print('Response status: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (kDebugMode) {
          print('API Response: ${response.body}');
        }
        
        if (!data.containsKey('candidates') || 
            data['candidates'].isEmpty ||
            !data['candidates'][0].containsKey('content') ||
            !data['candidates'][0]['content'].containsKey('parts') ||
            data['candidates'][0]['content']['parts'].isEmpty) {
          throw Exception('Invalid response format from API');
        }
        
        String generatedText = data['candidates'][0]['content']['parts'][0]['text'] as String;
        generatedText = generatedText.replaceAll(RegExp(r'```json|```|\`'), '').trim();
            
        if (kDebugMode) {
          print('Generated text: $generatedText');
        }

        final questionList = _parseQuestions(generatedText);
        
        if (questionList.isEmpty) {
          throw Exception('No questions could be generated');
        }

        if (!mounted) return;
        
        final quizData = {
          'questions': questionList,
          'settings': QuizSettings(
            questionCount: selectedQuestionCount,
            difficulty: selectedDifficulty,
            timedMode: timedModeEnabled,
            timePerQuestion: timePerQuestion,
            quizType: selectedQuizType,
          ),
        };

        Navigator.pushNamed(context, QuizScreen.id, arguments: quizData);
      } else {
        final errorBody = jsonDecode(response.body);
        throw HttpException('API Error (${response.statusCode}): ${errorBody['error']['message']}');
      }
    } on SocketException {
      _showError('No Internet connection. Please check your network.');
    } on TimeoutException {
      _showError('Request timed out. Please try again.');
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
              ),
              const SizedBox(height: 16),
              Card(
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
                        segments: [
                          ButtonSegment<QuizType>(
                            value: QuizType.truefalse,
                            label: const Text('True/False'),
                            icon: const Icon(Icons.check_circle_outline),
                          ),
                          ButtonSegment<QuizType>(
                            value: QuizType.multichoice,
                            label: const Text('Multiple Choice'),
                            icon: const Icon(Icons.format_list_bulleted),
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
              ),
              const SizedBox(height: 16),
              Card(
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
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: isLoading ? null : () => generateQuestions(extractedData),
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
                    : const Icon(Icons.quiz, size: 24, color: Colors.white),
                label: Text(isLoading ? AppStrings.generating.tr() : AppStrings.generateQuiz.tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
