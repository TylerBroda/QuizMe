// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:quizme/views/quiz_creator.dart';
import '../model/quiz.dart';

class MyQuizzes extends StatefulWidget {
  const MyQuizzes({Key? key}) : super(key: key);

  @override
  _MyQuizzesState createState() => _MyQuizzesState();
}

// Will list your quizzes that you made

class _MyQuizzesState extends State<MyQuizzes> {
  final List<Quiz> _quizzes = Quiz.generateData();
  int _selectedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return _quizzes.isNotEmpty
        ? ListView.builder(
            itemCount: _quizzes.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  child: Container(
                      decoration: new BoxDecoration(
                          color: index == _selectedIndex
                              ? Colors.blue.shade100
                              : Colors.white10,
                          border: Border(
                              bottom:
                                  new BorderSide(color: Colors.grey.shade300))),
                      child: ListTile(
                        title: Text(_quizzes[index].name),
                        subtitle: Text(_quizzes[index].topic),
                      )));
            })
        : Center(child: Text("No quizzes made yet."));

    //       Column(
    //   // crossAxisAlignment: CrossAxisAlignment.center,
    //   mainAxisAlignment: MainAxisAlignment.center,
    //   children: [
    //     Center(child: Text("No quizzes made yet")),
    //     ElevatedButton(
    //
    //       child: Text("Create quiz"),
    //     )
    //   ],
    // );
  }
}
