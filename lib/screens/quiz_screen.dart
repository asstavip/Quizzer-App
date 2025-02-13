import 'package:flutter/material.dart';
import 'package:pdf_uploader/screens/quiz_generation_screen.dart';
import 'package:pdf_uploader/theme/app_theme.dart';
import 'dart:async';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:pdf_uploader/utils/strings.dart';
import 'package:easy_localization/easy_localization.dart';
import 'answer_review_screen.dart';

class QuizScreen extends StatefulWidget {
  static const String id = 'quiz';

  const QuizScreen({super.key});
  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (questions == null) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        questions = List<Map<String, dynamic>>.from(args['questions']);
        final settings = args['settings'];
        bool isMultiChoice = questions!.first['type'] == 'multichoice';
        userAnswers = isMultiChoice ? List<String?>.filled(questions!.length, null) : List<bool?>.filled(questions!.length, null);
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

    setState(() {
      isAnswered = true;
      isProcessingAnswer = true;
      userAnswers[questionIndex] = userChoice;
      selectedAnswer = userChoice is String ? userChoice : null;
      
      if (isCorrect) {
        score++;
        answerColor = AppTheme.customColors['success']!;
      } else {
        answerColor = AppTheme.customColors['error']!;
      }
    });

    isLoadingNextQuestion = true;

    setState(() {
      if (questionIndex >= questions!.length - 1) {
        showQuizComplete();
      } else {
        Duration duration = const Duration(seconds: 1);
        Future.delayed(duration, () {
          setState(() {
            questionIndex++;
            isTimeUp = false;
            isAnswered = false;
            isLoadingNextQuestion = false;
            answerColor = Colors.white;
            selectedAnswer = null;
          });
        });

        if (questionTimer != null) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          startTimer(args['settings'].timePerQuestion);
        }
      }
      isProcessingAnswer = false;
    });
  }

  void showQuizComplete() {
    questionTimer?.cancel();
    Alert(
      style: const AlertStyle(
        animationType: AnimationType.grow,
        isCloseButton: false,
        isOverlayTapDismiss: false,
      ),
      context: context,
      type: AlertType.success,
      title: AppStrings.quizCompleteTitle.tr(),
      desc: "${AppStrings.scoreText.tr()} $score/${questions!.length}",
      closeIcon: IconButton(onPressed: (){
        Navigator.popUntil(context, ModalRoute.withName(QuizGenerationScreen.id));
      }, icon: const Icon(Icons.close)),
      buttons: [
        DialogButton(
          child: Text(
            AppStrings.reviewAnswers.tr(),
            style: const TextStyle(color: Colors.white),
          ),
          onPressed: () {
            Navigator.pushNamed(
              context,
              QuizReviewScreen.id,
              arguments: {
                'questions': questions,
                'userAnswers': userAnswers,
                'score': score,
              },
            );
          },
        ),
        DialogButton(
          child: Text(
            AppStrings.newQuiz.tr(),
            style: const TextStyle(color: Colors.white),
          ),
          onPressed: () {
            Navigator.popUntil(
              context,
              ModalRoute.withName(QuizGenerationScreen.id),
            );
          },
        ),
      ],
    ).show();
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
                child: Text(AppStrings.trueLabel.tr(), style: const TextStyle(fontSize: 20)),
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
                child: Text(AppStrings.falseLabel.tr(), style: const TextStyle(fontSize: 20)),
              ),
            ),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: currentQuestion['options'].asMap().entries.map<Widget>((entry) {
            final option = entry.value;
            final letter = option.substring(0, 1); // Extract A, B, C, or D
            final isSelected = selectedAnswer == letter;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected ? AppTheme.customColors['secondary'] : null,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                ),
                onPressed: isTimeUp || isAnswered ? null : () => checkAnswer(letter),
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
        title: Text('${AppStrings.questionNumberText.tr()} ${questionIndex + 1}/${questions!.length}'),
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
                                        color: Theme.of(context).colorScheme.error,
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
}
