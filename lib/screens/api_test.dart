import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GeminiQuestionGenerator extends StatefulWidget {
  @override
  _GeminiQuestionGeneratorState createState() => _GeminiQuestionGeneratorState();
}

class _GeminiQuestionGeneratorState extends State<GeminiQuestionGenerator> {
  final String apiKey = 'AIzaSyBchYX4nCSNZ6cPoLFrXpJMWGpDatmfsN0'; // Replace with your Gemini API key
  List<String> questions = [];
  bool isLoading = false;

  Future<void> generateQuestions(int numberOfQuestions) async {
    setState(() {
      isLoading = true;
    });

    final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": "Generate $numberOfQuestions questions for a quiz"}
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // New structure based on Gemini API response
      if (data != null &&
          data['candidates'] != null &&
          data['candidates'].isNotEmpty &&
          data['candidates'][0]['content'] != null &&
          data['candidates'][0]['content']['parts'] != null &&
          data['candidates'][0]['content']['parts'].isNotEmpty &&
          data['candidates'][0]['content']['parts'][0]['text'] != null) {
        final generatedText = data['candidates'][0]['content']['parts'][0]['text'] as String;

        setState(() {
          // Split the generated text by line and remove empty entries
          questions = generatedText.split('\n').where((q) => q.isNotEmpty).toList();
          isLoading = false;
        });
      } else {
        print("Unexpected data structure: ${data.toString()}");
        setState(() {
          questions = ["Error: Failed to retrieve valid response from API."];
          isLoading = false;
        });
      }
    } else {
      print("Failed to generate questions: ${response.body}");
      setState(() {
        questions = ["Error: Unable to reach API"];
        isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gemini Question Generator')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Number of Questions',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onSubmitted: (value) {
                final numQuestions = int.tryParse(value) ?? 0;
                if (numQuestions > 0) {
                  generateQuestions(numQuestions);
                }
              },
            ),
            SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator()
                : Expanded(
              child: ListView.builder(
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Text('${index + 1}.'),
                    title: Text(questions[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
