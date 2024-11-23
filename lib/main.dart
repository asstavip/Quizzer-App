// lib/main.dart

import 'package:flutter/material.dart';
import 'package:pdf_uploader/screens/answer_detail_screen.dart';
import 'package:pdf_uploader/screens/answer_review_screen.dart';
import 'screens/pdf_upload_screen.dart';
import 'screens/quiz_generation_screen.dart';
import 'screens/quiz_screen.dart';
import 'widgets/animated_wrapper.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDF Quiz App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: PdfUploadScreen.id,
      routes: {
        PdfUploadScreen.id: (context) => AnimatedWrapper(child: PdfUploadScreen()),
        QuizGenerationScreen.id: (context) =>  AnimatedWrapper(child: QuizGenerationScreen()),
        QuizScreen.id: (context) =>  AnimatedWrapper(child: QuizScreen()),
        QuizReviewScreen.id: (context) => QuizReviewScreen(),
        AnswerDetailScreen.id: (context) => AnswerDetailScreen(),
      },
    );
  }
}