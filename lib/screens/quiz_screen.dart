import 'package:flutter/material.dart';
import 'dart:async';
import 'package:rflutter_alert/rflutter_alert.dart';

class QuizScreen extends StatefulWidget {
  static const String id = 'quiz';
  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Map<String, dynamic>>? questions;
  int questionIndex = 0;
  List<Icon> scoreKeeper = [];
  int score = 0;

  Timer? questionTimer;
  int remainingTime = 0;
  bool isTimeUp = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize data if not already done
    if (questions == null) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        questions = List<Map<String, dynamic>>.from(args['questions']);
        final settings = args['settings'];
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

  void checkAnswer(bool? userPickedAnswer) {
    if (isTimeUp && userPickedAnswer != null) return;

    bool correctAnswer = questions![questionIndex]['questionAnswer'];
    bool isCorrect = userPickedAnswer == correctAnswer;

    setState(() {
      if (isCorrect) {
        score++;
        scoreKeeper.add(Icon(Icons.check, color: Colors.green));
      } else {
        scoreKeeper.add(Icon(Icons.close, color: Colors.red));
      }

      if (questionIndex >= questions!.length - 1) {
        showQuizComplete();
      } else {
        questionIndex++;
        isTimeUp = false;
        if (questionTimer != null) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          startTimer(args['settings'].timePerQuestion);
        }
      }
    });
  }

  void showQuizComplete() {
    questionTimer?.cancel();
    Alert(
      context: context,
      type: AlertType.success,
      title: "Quiz Complete!",
      desc: "Your score: $score/${questions!.length}",
      buttons: [
        DialogButton(
          child: Text("Restart"),
          onPressed: () {
            Navigator.popUntil(context, ModalRoute.withName('/'));
          },
        )
      ],
    ).show();
  }

  @override
  void dispose() {
    questionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If questions is null, it means we haven't received the data yet
    if (questions == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Question ${questionIndex + 1}/${questions!.length}'),
        actions: [
          if (questionTimer != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  '${remainingTime}s',
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
                value: remainingTime / (ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>)['settings'].timePerQuestion,
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
                  child: Card(
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
                          ),
                          if (isTimeUp)
                            Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: Text(
                                'Time\'s up!',
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
                ),
              ),
            ),
            Padding(
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
                      child: const Text('True', style: TextStyle(fontSize: 20)),
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
                      child: const Text('False', style: TextStyle(fontSize: 20)),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: scoreKeeper,
            ),
          ],
        ),
      ),
    );
  }
}