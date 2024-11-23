// lib/screens/quiz_generation_screen.dart

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:pdf_uploader/screens/quiz_screen.dart';

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
  @override
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

    Future<void> generateQuestions(String text) async {
      setState(() => isLoading = true);

      try {
        final url = Uri.parse(
            'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=AIzaSyBi7_r9TcYhllPROAXVKNkh59szIpzz9ig');

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
                
                Format each question as a JSON object like this:
                {
                  "question": "Question text here",
                  "answer": true/false,
                  "explanation": "Explanation of why the answer is true/false"
                }
                
                Provide only the JSON objects, one per line, with no additional text or formatting."""
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
        // Clean generatedText by removing backticks and ```json markers
        generatedText = generatedText
            .replaceAll(RegExp(r'```json|```|\`'), '')  // Removes all backticks and ```json or ```
            .trim();

        List<Map<String, dynamic>> questionList = generatedText
            .split('\n')
            .where((line) => line.isNotEmpty)
            .map((line) {
          Map<String, dynamic> parsed = jsonDecode(line);
          return {
            "questionText": parsed['question'],
            "questionAnswer": parsed['answer'],
            // "explanation": parsed['explanation'], // Make sure to include explanation
          };
        }).toList();
        if (!mounted) return;

        // Include quiz settings with the questions
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

        setState(() => isLoading = false);
      } else {
        throw Exception('Failed to generate questions: ${response.body}');
      }
    } on SocketException catch (e) {
      print('No Internet connection: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No Internet connection. Please check your network.'),
          backgroundColor: Colors.red,
        ),
      );
    } on TimeoutException catch (e) {
      print('Request timed out: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Request timed out. Please try again later.'),
          backgroundColor: Colors.red,
        ),
      );
    } on FormatException catch (e) {
        print("");
      print('Data format error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to generate questions. Please try again later.'),
          backgroundColor: Colors.red,
        ),
      );
    } on HttpException catch (e) {
      print('HTTP error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Server error. Please try again later.'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      print('Error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Unexpected error. Please try again.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String extractedText =
        ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(title: Text('Quiz Settings')),
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
