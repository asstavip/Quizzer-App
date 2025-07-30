import 'package:flutter/material.dart';
import 'package:pdf_uploader/screens/answer_detail_screen.dart';
import 'package:pdf_uploader/screens/answer_review_screen.dart';
import 'package:pdf_uploader/services/history_service.dart';
import 'screens/pdf_upload_screen.dart';
import 'screens/quiz_generation_screen.dart';
import 'screens/quiz_screen.dart';
import 'widgets/animated_wrapper.dart';
import 'theme/app_theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:easy_localization/easy_localization.dart';
import 'screens/quiz_history_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await dotenv.load(fileName: '.env');

  // Initialize Hive before using it
  await HistoryService.initHive();
 // language
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('fr'), Locale('ar')],
      path: 'assets/translations', // path to your translation files
      fallbackLocale: const Locale('en'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDF Quiz App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      // routes :
      initialRoute: PdfUploadScreen.id,
      onGenerateRoute: (settings) {
        if (settings.name == PdfUploadScreen.id) {
          return MaterialPageRoute(
            builder: (context) =>
                const AnimatedWrapper(child: PdfUploadScreen()),
          );
        }
        else if (settings.name == QuizGenerationScreen.id) {
          return MaterialPageRoute(
            builder: (context) =>
                const AnimatedWrapper(child: QuizGenerationScreen()),
            settings: settings,
          );
        }
        else if (settings.name == QuizScreen.id) {
          return MaterialPageRoute(
            builder: (context) => const AnimatedWrapper(child: QuizScreen()),
            settings: settings,
          );
        }
        else if (settings.name == QuizReviewScreen.id) {
          return MaterialPageRoute(
            builder: (context) =>
                const AnimatedWrapper(child: QuizReviewScreen()),
            settings: settings,
          );
        }
        else if (settings.name == AnswerDetailScreen.id) {
          return MaterialPageRoute(
            builder: (context) =>
                const AnimatedWrapper(child: AnswerDetailScreen()),
            settings: settings,
          );
        }
        else if (settings.name == QuizHistoryScreen.id) {
          return MaterialPageRoute(
            builder: (context) =>
                const AnimatedWrapper(child: QuizHistoryScreen()),
            settings: settings,
          );
        }
        return null;
      },
    );
  }
}
