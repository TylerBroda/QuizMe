// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:quizme/widgets/app_drawer.dart';

class QuizCreator extends StatefulWidget {
  const QuizCreator({Key? key}) : super(key: key);

  @override
  _QuizCreatorState createState() => _QuizCreatorState();
}

class _QuizCreatorState extends State<QuizCreator> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      resizeToAvoidBottomInset: false,
            appBar: AppBar(
        title: Text("temp appbar"),
      ),
      body: Column(
        // crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(child: Text("No quizzes made yet")),
          ElevatedButton(
            onPressed: null,
            child: Text("Create quiz"),
          )
        ],
      ),
    );
  }
}
