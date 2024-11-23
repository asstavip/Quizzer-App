import 'package:flutter/material.dart';
import 'package:pdf_uploader/screens/answer_detail_screen.dart';
import 'package:pdf_uploader/screens/answer_review_screen.dart';
import 'screens/pdf_upload_screen.dart';
import 'screens/quiz_generation_screen.dart';
import 'screens/quiz_screen.dart';
import 'widgets/animated_wrapper.dart';
import 'theme/app_theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDF Quiz App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: PdfUploadScreen.id,
      routes: {
        PdfUploadScreen.id: (context) =>
            const AnimatedWrapper(child: PdfUploadScreen()),
        QuizGenerationScreen.id: (context) =>
            const AnimatedWrapper(child: QuizGenerationScreen()),
        QuizScreen.id: (context) => AnimatedWrapper(child: QuizScreen()),
        QuizReviewScreen.id: (context) => const QuizReviewScreen(),
        AnswerDetailScreen.id: (context) => AnswerDetailScreen(),
      },
    );
  }
}
