import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import './initialize_quiz.dart';
import 'quiz_creator.dart';
import './quiz_game.dart';
import '../model/quiz.dart';

class QuestionList extends StatefulWidget {
  const QuestionList(
      {Key? key,
      required this.chosenQuiz,
      required this.quizID,
      required this.quizzesDB})
      : super(key: key);

  final Quiz chosenQuiz;
  final String quizID;
  final CollectionReference quizzesDB;

  @override
  _QuestionListState createState() => _QuestionListState(
      chosenQuiz: this.chosenQuiz,
      quizID: this.quizID,
      quizzesDB: this.quizzesDB);
}

class _QuestionListState extends State<QuestionList> {
  Quiz chosenQuiz;
  final String quizID;
  CollectionReference quizzesDB;

  _QuestionListState(
      {required this.chosenQuiz,
      required this.quizID,
      required this.quizzesDB});

  _deleteQuiz() async {
    await quizzesDB.doc(quizID).delete();
  }

  _goToQuizCreator(int index, {bool add = false}) {
    if (add) chosenQuiz.questions.add(Question("", 0, []));

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => QuizCreator(
                questionNumber: index + 1,
                chosenQuiz: chosenQuiz,
                quizID: quizID,
              )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(chosenQuiz.name), actions: <Widget>[
          IconButton(
              onPressed: () {
                areYouSure(context);
              },
              icon: const Icon(Icons.delete)),
          IconButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => InitializeQuiz()),
                );
              },
              icon: const Icon(Icons.edit)),
        ]),
        body: ListView.builder(
            itemCount: chosenQuiz.questions.length + 1,
            itemBuilder: (context, index) {
              return GestureDetector(
                  onTap: () {
                    if (index < chosenQuiz.questions.length) {
                      _goToQuizCreator(index);
                    }
                  },
                  child: index < chosenQuiz.questions.length
                      ? Container(
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom:
                                      BorderSide(color: Colors.grey.shade300))),
                          child: ListTile(
                              title: Text(chosenQuiz.questions[index].question),
                              subtitle: Text("Question ${index + 1}")))
                      : Container(
                          padding: const EdgeInsets.all(5),
                          child: ListTile(
                              title: IconButton(
                                  onPressed: () {
                                    _goToQuizCreator(index, add: true);
                                  },
                                  icon: const Icon(Icons.add_circle_outline,
                                      color: Colors.blue, size: 40)),
                              subtitle:
                                  const Center(child: Text("New Question")))));
            }),
        floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/quizgame',
                arguments: QuizScreenArguments(quizID),
              );
            },
            label: const Text("Start Quiz"),
            icon: const Icon(Icons.quiz)));
  }

  areYouSure(BuildContext context) {
    AlertDialog alert = AlertDialog(
      title: Text("Delete ${chosenQuiz.name}"),
      content: Text("Are you sure you want to delete ${chosenQuiz.name}?"),
      actions: [
        TextButton(
          child: const Text("NO"),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        TextButton(
          child: const Text("YES"),
          onPressed: () async {
            await _deleteQuiz();
            Navigator.pop(context);
            Navigator.pop(context);
          },
        ),
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
