import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'quiz_creator.dart';
import './quiz_game.dart';
import '../model/quiz.dart';

class QuestionList extends StatefulWidget {
  const QuestionList({Key? key, required this.chosenQuiz, required this.quizID})
      : super(key: key);

  final Quiz chosenQuiz;
  final String quizID;

  @override
  _QuestionListState createState() =>
      _QuestionListState(chosenQuiz: this.chosenQuiz, quizID: this.quizID);
}

class _QuestionListState extends State<QuestionList> {
  final Quiz chosenQuiz;
  final String quizID;

  _QuestionListState({required this.chosenQuiz, required this.quizID});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(chosenQuiz.name)),
        body: ListView.builder(
            itemCount: chosenQuiz.questions.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => QuizCreator(
                                questionNumber: index + 1,
                                chosenQuiz: chosenQuiz,
                                quizID: quizID,
                              )),
                    );
                  },
                  child: Container(
                      decoration: new BoxDecoration(
                          border: Border(
                              bottom:
                                  new BorderSide(color: Colors.grey.shade300))),
                      child: ListTile(
                          title: Text(chosenQuiz.questions[index].question),
                          subtitle: Text("Question ${index + 1}"))));
            }),
        floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/quizgame',
                arguments: QuizScreenArguments(quizID),
              );
            },
            label: Text("Start Quiz"),
            icon: Icon(Icons.quiz)));
  }
}
