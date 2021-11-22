import 'package:flutter/material.dart';

import 'package:quizme/views/home_page.dart';
import 'package:quizme/views/login_screen.dart';
import 'package:quizme/views/signup_screen.dart';
import 'package:quizme/views/quiz_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // change intialRoute while working on views
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => const HomePage(),
        '/quizpicker': (context) => const QuizPicker(),
      },
    );
  }
}
