import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import './question_creator.dart';
import '../model/quiz.dart';

List<GlobalKey<QuestionCreatorState>> globalKeys = [GlobalKey()];

class QuizCreator extends StatefulWidget {
  const QuizCreator(
      {Key? key,
      required this.questionNumber,
      required this.topic,
      required this.quizName,
      required this.quizID})
      : super(key: key);

  final int questionNumber;
  final String topic;
  final String quizName;
  final String quizID;

  @override
  _QuizCreatorState createState() => _QuizCreatorState(
      questionNumber: this.questionNumber,
      topic: this.topic,
      quizName: this.quizName,
      quizID: this.quizID);
}

class _QuizCreatorState extends State<QuizCreator> {
  final CollectionReference _quizCollection =
      FirebaseFirestore.instance.collection("quizzes");

  int questionNumber;
  String topic;
  String quizName;
  String quizID;

  _QuizCreatorState(
      {required this.questionNumber,
      required this.topic,
      required this.quizName,
      required this.quizID});

  List<Widget> questionPages = [];
  Quiz quiz = Quiz("", "", []);

  @override
  void initState() {
    super.initState();
    questionPages = [
      QuestionCreator(
          questionNumber: 1, callback: _callback, key: globalKeys[0])
    ];
    quiz = Quiz(quizName, topic, []);
  }

  _callback(Question newQuestion) {
    quiz.questions = [...quiz.questions, newQuestion];
  }

  _saveQuiz() async {
    quiz.questions = [];
    for (int i = 0; i < questionPages.length; i++) {
      await globalKeys[i].currentState?.saveQuestion();
    }

    var quizData = {
      "Name": quizName,
      "Category": topic,
      // "Questions": quiz.questions,
      "User": "Admin"
    };

    // If this is a brand new quiz, make a new one in the database and then stick to its new ID
    // Otherwise update the chosen ID
    if (quizID == "none") {
      DocumentReference newQuiz = await _quizCollection.add(quizData);
      quizID = newQuiz.id;
    } else {
      await _quizCollection.doc(quizID).update(quizData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text('Edit $quizName'),
            leading: IconButton(
              icon: Icon(Icons.list),
              onPressed: () {},
            ),
            centerTitle: true,
            automaticallyImplyLeading: false,
            actions: <Widget>[
              TextButton.icon(
                  label: const Icon(
                    Icons.check,
                    color: Colors.white,
                  ),
                  icon: Text('Done', style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    _saveQuiz();
                  })
            ]),
        resizeToAvoidBottomInset: false,
        body: IndexedStack(
          index: questionNumber - 1,
          children: questionPages,
        ),
        bottomNavigationBar: BottomAppBar(
            child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
              questionNumber > 1
                  ? TextButton.icon(
                      icon: Icon(Icons.arrow_back),
                      label: Text('Question ${questionNumber - 1}'),
                      onPressed: () {
                        setState(() {
                          questionNumber = questionNumber - 1;
                        });
                      },
                    )
                  : Container(width: 115, height: 10),
              TextButton.icon(
                icon: Text('Question ${questionNumber + 1}'),
                label: questionNumber == questionPages.length
                    ? Icon(Icons.add)
                    : Icon(Icons.arrow_forward),
                onPressed: () {
                  setState(() {
                    if (questionNumber == questionPages.length) {
                      globalKeys = [...globalKeys, GlobalKey()];

                      questionPages = [
                        ...questionPages,
                        QuestionCreator(
                            questionNumber: questionNumber + 1,
                            callback: _callback,
                            key: globalKeys[globalKeys.length - 1])
                      ];
                    }
                    questionNumber = questionNumber + 1;
                  });
                },
              )
            ])),
        floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.save),
            onPressed: () {
              _saveQuiz();
            }));
  }
}
