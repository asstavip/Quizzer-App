import 'package:flutter/material.dart';
import 'package:pdf_uploader/screens/pdf_upload_screen.dart';
import 'package:pdf_uploader/screens/api_test.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDF Quiz App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/pdfUpload': (context) => PdfUploadScreen(),
        '/quiz': (context) => QuizScreen(),
        '/questions': (context) => GeminiQuestionGenerator(),
      },
    );
  }
}

// Home Screen with Navigation to PDF Upload Screen
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/questions');
          },
          child: Text('Go to PDF Upload'),
        ),
      ),
    );
  }
}

// Quiz Screen (Placeholder for Quiz Questions)
class QuizScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quiz')),
      body: Center(
        child: Text(
          'Quiz Screen\n(Questions will be displayed here)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
