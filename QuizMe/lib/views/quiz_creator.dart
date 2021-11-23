// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';

class QuizCreator extends StatefulWidget {
  const QuizCreator({Key? key}) : super(key: key);

  @override
  _QuizCreatorState createState() => _QuizCreatorState();
}

class _QuizCreatorState extends State<QuizCreator> {
  @override
  Widget build(BuildContext context) {
    return Column(
      // crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(child: Text("No quizzes made yet")),
        ElevatedButton(
          onPressed: null,
          child: Text("Create quiz"),
        )
      ],
    );
  }
}
