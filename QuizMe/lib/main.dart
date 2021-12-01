// @dart=2.9
import 'package:flutter/material.dart';
import 'package:quizme/views/home_page.dart';
import 'package:quizme/views/login_screen.dart';
import 'package:quizme/views/signup_screen.dart';
import 'package:quizme/views/quiz_picker.dart';
import 'package:quizme/views/explore_screen.dart';
import 'package:quizme/views/tutor_screen.dart';
import 'package:quizme/views/quiz_game.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // change intialRoute while working on views
      initialRoute: '/home',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => const HomePage(),
        '/explorescreen': (context) => const ExploreScreen(),
        '/quizpicker': (context) => const QuizPicker(),
        '/tutors': (context) => const TutorScreen(),
        '/quizgame': (context) => const QuizGame("F5imscFWxNedolS7W5QS"),
      },
    );
  }
}
