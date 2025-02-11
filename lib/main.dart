import 'package:flutter/material.dart';
import 'package:pdf_uploader/screens/answer_detail_screen.dart';
import 'package:pdf_uploader/screens/answer_review_screen.dart';
import 'screens/pdf_upload_screen.dart';
import 'screens/quiz_generation_screen.dart';
import 'screens/quiz_screen.dart';
import 'widgets/animated_wrapper.dart';
import 'theme/app_theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:easy_localization/easy_localization.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await dotenv.load(fileName: '.env');
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('fr'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      saveLocale: true, // Add this to persist the locale
      useOnlyLangCode: true, // Add this to use only language code
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDF Quiz App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      initialRoute: PdfUploadScreen.id,
      routes: {
        PdfUploadScreen.id: (context) =>
            const AnimatedWrapper(child: PdfUploadScreen()),
        QuizGenerationScreen.id: (context) =>
            const AnimatedWrapper(child: QuizGenerationScreen()),
        QuizScreen.id: (context) => const AnimatedWrapper(child: QuizScreen()),
        QuizReviewScreen.id: (context) =>
            const AnimatedWrapper(child: QuizReviewScreen()),
        AnswerDetailScreen.id: (context) =>
            const AnimatedWrapper(child: AnswerDetailScreen()),
      },
    );
  }
}
