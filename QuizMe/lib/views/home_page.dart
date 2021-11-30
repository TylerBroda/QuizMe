// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:quizme/views/my_quizzes.dart';
import 'package:quizme/views/quiz_picker.dart';
import 'package:quizme/views/explore_screen.dart';
import 'package:quizme/widgets/app_drawer.dart';
import 'package:quizme/views/quiz_creator.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final views = [
    MyQuizzes(),
    ExploreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("temp appbar"),
      ),
      drawer: AppDrawer(),
      resizeToAvoidBottomInset: false,
      body: views[_currentIndex],
      // For Adding Quizzes
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => InitializeQuiz()),
                );
              },
              // label: const Text(''),
              child: const Icon(Icons.add))
          : Container(),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            label: "My Quizzes",
            icon: Icon(Icons.help_center),
          ),
          BottomNavigationBarItem(
            label: "Explore",
            icon: Icon(Icons.explore),
          ),
          // BottomNavigationBarItem(
          //   label: "Tutors",
          //   icon: Icon(Icons.school),
          // ),
        ],
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
