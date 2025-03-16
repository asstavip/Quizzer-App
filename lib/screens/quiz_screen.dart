import 'package:flutter/material.dart';
import 'package:pdf_uploader/domain/quiz_history.dart';
import 'package:pdf_uploader/screens/quiz_generation_screen.dart';
import 'package:pdf_uploader/screens/quiz_history_screen.dart';
import 'package:pdf_uploader/theme/app_theme.dart';
import 'dart:async';
// import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:pdf_uploader/utils/strings.dart';
import 'package:easy_localization/easy_localization.dart';

import 'answer_review_screen.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import '../services/history_service.dart';

class QuizScreen extends StatefulWidget {
  static const String id = 'quiz';

  const QuizScreen({super.key});
  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  AudioPlayer? audioPlayer;
  List<Map<String, dynamic>>? questions;
  int questionIndex = 0;
  int score = 0;
  bool isAnswered = false;
  bool isLoadingNextQuestion = false;
  bool isProcessingAnswer = false;
  Color answerColor = Colors.white;
  dynamic userAnswers;
  String? selectedAnswer;

  Timer? questionTimer;
  int remainingTime = 0;
  bool isTimeUp = false;

  bool _quizSaved = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (questions == null) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        questions = List<Map<String, dynamic>>.from(args['questions']);
        final settings = args['settings'];
        bool isMultiChoice = questions!.first['type'] == 'multichoice';
        userAnswers = isMultiChoice
            ? List<String?>.filled(questions!.length, null)
            : List<bool?>.filled(questions!.length, null);
        if (settings.timedMode) {
          startTimer(settings.timePerQuestion);
        }
      }
    }
  }

  void startTimer(int seconds) {
    remainingTime = seconds;
    questionTimer?.cancel();
    questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (remainingTime > 0) {
          remainingTime--;
        } else {
          timer.cancel();
          isTimeUp = true;
          handleTimeUp();
        }
      });
    });
  }

  void handleTimeUp() {
    checkAnswer(null);
  }

  void checkAnswer(dynamic userChoice) {
    if (isTimeUp && userChoice != null) return;
    if (isLoadingNextQuestion) return;
    if (isProcessingAnswer || isAnswered) return;

    final currentQuestion = questions![questionIndex];
    bool isCorrect;

    if (currentQuestion['type'] == 'truefalse') {
      isCorrect = userChoice == currentQuestion['questionAnswer'];
    } else {
      isCorrect = userChoice == currentQuestion['questionAnswer'];
    }

    // Add haptic feedback
    HapticFeedback.mediumImpact();

    setState(() {
      isAnswered = true;
      isProcessingAnswer = true;
      userAnswers[questionIndex] = userChoice;
      selectedAnswer = userChoice is String ? userChoice : null;

      if (isCorrect) {
        audioPlayer?.play(AssetSource('sounds/correct.mp3'));
        score++;
        answerColor = AppTheme.customColors['success']!;
      } else {
        audioPlayer?.play(AssetSource('sounds/incorrect.mp3'));
        answerColor = AppTheme.customColors['error']!;
      }
    });

    isLoadingNextQuestion = true;

    // Show correct answer for a moment
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (questionIndex >= questions!.length - 1) {
        showQuizComplete();
      } else {
        // Animate to next question
        setState(() {
          questionIndex++;
          isTimeUp = false;
          isAnswered = false;
          isLoadingNextQuestion = false;
          answerColor = Colors.white;
          selectedAnswer = null;
        });

        if (questionTimer != null) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          startTimer(args['settings'].timePerQuestion);
        }
      }
      isProcessingAnswer = false;
    });
  }

  void showQuizComplete() {
    questionTimer?.cancel();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      builder: (context) => TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        tween: Tween(begin: 1.0, end: 0.0),
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, value * 100),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color:
                            AppTheme.customColors['success']!.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_circle_outline,
                        size: 48,
                        color: AppTheme.customColors['success'],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      AppStrings.quizCompleteTitle.tr(),
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "${AppStrings.scoreText.tr()} $score/${questions!.length}",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppTheme.customColors['success'],
                          ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  AppTheme.customColors['secondary'],
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: () => Navigator.pushNamed(
                              context,
                              QuizReviewScreen.id,
                              arguments: {
                                'questions': questions,
                                'userAnswers': userAnswers,
                                'score': score,
                              },
                            ),
                            child: Text(AppStrings.reviewAnswers.tr()),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: () => Navigator.popUntil(
                              context,
                              ModalRoute.withName(QuizGenerationScreen.id),
                            ),
                            child: Text(AppStrings.newQuiz.tr()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // New save quiz history button
                    if (!_quizSaved)
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 24),
                        ),
                        onPressed: _isSaving
                            ? null
                            : () {
                                _saveQuizToHistory();
                                Navigator.pushNamed(
                                    context, (QuizHistoryScreen.id));
                              },
                        icon: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.history),
                        label: Text(AppStrings.saveQuiz.tr()),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.check_circle_outline,
                              color: Colors.teal,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              AppStrings.quizSaved.tr(),
                              style: const TextStyle(
                                color: Colors.teal,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnswerButtons() {
    final currentQuestion = questions![questionIndex];

    if (currentQuestion['type'] == 'truefalse') {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: isTimeUp ? null : () => checkAnswer(true),
                child: Text(AppStrings.trueLabel.tr(),
                    style: const TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: isTimeUp ? null : () => checkAnswer(false),
                child: Text(AppStrings.falseLabel.tr(),
                    style: const TextStyle(fontSize: 20)),
              ),
            ),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children:
              currentQuestion['options'].asMap().entries.map<Widget>((entry) {
            final option = entry.value;
            final letter = option.substring(0, 1); // Extract A, B, C, or D
            final isSelected = selectedAnswer == letter;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isSelected ? AppTheme.customColors['secondary'] : null,
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                ),
                onPressed:
                    isTimeUp || isAnswered ? null : () => checkAnswer(letter),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        option,
                        style: const TextStyle(fontSize: 16),
                        softWrap: true,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      );
    }
  }

  @override
  void dispose() {
    audioPlayer?.dispose();
    questionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (questions == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
            '${AppStrings.questionNumberText.tr()} ${questionIndex + 1}/${questions!.length}'),
        actions: [
          if (questionTimer != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  '$remainingTime s',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (questionTimer != null)
              LinearProgressIndicator(
                minHeight: 8,
                value: remainingTime /
                    (ModalRoute.of(context)!.settings.arguments
                            as Map<String, dynamic>)['settings']
                        .timePerQuestion,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  remainingTime > 5 ? Colors.green : Colors.red,
                ),
              ),
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 200),
                    tween: Tween(begin: 0.0, end: isAnswered ? 1.0 : 0.0),
                    curve: Curves.easeInOut,
                    builder: (context, value, _) {
                      return Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: Card(
                          color: answerColor,
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  questions![questionIndex]['questionText'],
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.titleLarge,
                                  softWrap: true,
                                ),
                                if (isTimeUp)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 16.0),
                                    child: Text(
                                      AppStrings.timesUp.tr(),
                                      style: TextStyle(
                                        color:
                                            Theme.of(context).colorScheme.error,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            _buildAnswerButtons(),
          ],
        ),
      ),
    );
  }

  Future<void> _saveQuizToHistory() async {
    if (_quizSaved) return; // Prevent multiple saves

    setState(() {
      _isSaving = true; // Show loading state
      _quizSaved = true; // Set quiz saved state
    });

    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final settings = args['settings'];
    final pdfName = args['fileName'] ?? 'Unknown PDF';

    final quizType = settings.quizType.toString().split('.').last;
    final difficulty = settings.difficulty.toString().split('.').last;

    final quizHistory = QuizHistory(
      date: DateTime.now().toString(),
      score: score,
      totalQuestions: questions!.length,
      quizType: quizType,
      difficulty: difficulty,
      pdfName: pdfName,
      questionsData: questions, // Store complete quiz data
      userAnswers: userAnswers, // Add user answers
    );

    final saved = await HistoryService.saveQuizHistory(quizHistory);

    if (mounted) {
      setState(() {
        _quizSaved = true;
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.quizSaved.tr()),
          backgroundColor: Colors.teal,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
