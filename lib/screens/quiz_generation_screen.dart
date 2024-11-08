import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class QuizGenerationScreen extends StatefulWidget {
  static const id = '/generateQuiz';
  @override
  _QuizGenerationScreenState createState() => _QuizGenerationScreenState();
}

class _QuizGenerationScreenState extends State<QuizGenerationScreen> {
  bool isLoading = false;
  List<Map<String, dynamic>> questions = []; // Store question text and answer

  Future<void> generateQuestions(String text) async {
    setState(() => isLoading = true);

    final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=AIzaSyBchYX4nCSNZ6cPoLFrXpJMWGpDatmfsN0');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {
                "text": "Generate up to 10 true or false questions based on this text: $text. Provide each question as a JSON object in the format {\"question\": \"question text\", \"answer\": true/false}. Do not use any additional formatting, styling, or extra text."
              }
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final generatedText = data['candidates'][0]['content']['parts'][0]['text'] as String;
      List<Map<String, dynamic>> questionList = generatedText
          .split('\n') // Split by newlines
          .where((line) => line.isNotEmpty) // Remove empty lines
          .map((line) {
        // Parse each line as a JSON object
        Map<String, dynamic> parsed = jsonDecode(line);

        // Extract question and answer
        String questionText = parsed['question'];
        bool questionAnswer = parsed['answer'];

        // Return the formatted result
        return {
          "questionText": questionText,
          "questionAnswer": questionAnswer,
        };
      })
          .toList();

      setState(() {
        questions = questionList;
        isLoading = false;
      });

      Navigator.pushNamed(context, '/quiz', arguments: questions);
    } else {
      print("Error: ${response.body}");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String extractedText = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(title: Text('Generate Quiz Questions')),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator()
            : ElevatedButton(
          onPressed: () => generateQuestions(extractedText),
          child: Text('Generate Quiz'),
        ),
      ),
    );
  }
}
