import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:pdf_uploader/utils/flat_button.dart';
class QuizScreen extends StatefulWidget {
  static const String id = 'quiz';
  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Map<String, dynamic>> questions = [];
  int questionIndex = 0;
  List<Icon> scoreKeeper = [];

  void checkAnswer(bool userPickedAnswer) {
    bool correctAnswer = questions[questionIndex]['questionAnswer'];

    setState(() {
      if (questionIndex >= questions.length - 1) {
        Alert(
          context: context,
          title: 'Finished!',
          desc: 'You\'ve completed the quiz!',
        ).show();
        questionIndex = 0;
        scoreKeeper.clear();
      } else {
        if (userPickedAnswer == correctAnswer) {
          scoreKeeper.add(const Icon(Icons.check, color: Colors.green));
        } else {
          scoreKeeper.add(const Icon(Icons.close, color: Colors.red));
        }
        questionIndex++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    questions = ModalRoute.of(context)!.settings.arguments as List<Map<String, dynamic>>;

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.blue, Colors.purple], // Set the desired colors
                  ),
                ),
                child: Center(
                  child: Text(
                    questions[questionIndex]['questionText'],
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 25.0, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: FlatButton(
                color: Colors.green,
                child: const Text('True', style: TextStyle(fontSize: 20.0, color: Colors.white)),
                onPressed: () => checkAnswer(true),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: FlatButton(
                color: Colors.red,
                child: const Text('False', style: TextStyle(fontSize: 20.0, color: Colors.white)),
                onPressed: () => checkAnswer(false),
              ),
            ),
          ),
          Row(children: scoreKeeper),
        ],
      ),
    );
  }
}

