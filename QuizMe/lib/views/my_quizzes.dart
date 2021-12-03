// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:quizme/utils/auth.dart';
import 'package:quizme/views/initialize_quiz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quizme/views/question_list.dart';
import '../model/quiz.dart';
import '../model/db_user.dart';

class QuizInfo {
  String quizID;
  String name;
  String topic;

  QuizInfo(this.quizID, this.name, this.topic);
}

class MyQuizzes extends StatefulWidget {
  const MyQuizzes({Key? key}) : super(key: key);

  @override
  _MyQuizzesState createState() => _MyQuizzesState();
}

// Will list your quizzes that you made

class _MyQuizzesState extends State<MyQuizzes> {
  late List<QuizInfo> _quizzes;
  bool loadedQuizzes = false;
  int _selectedIndex = -1;

  var userDB = FirebaseFirestore.instance.collection('users');
  var quizzesDB = FirebaseFirestore.instance.collection('quizzes');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("My Quizzes"),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
                onPressed: () {
                  showLogoutConfirmation(context);
                },
                icon: const Icon(Icons.directions_run)),
          ],
        ),
        body: getMyQuizzesBody(),
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => InitializeQuiz()),
              );
            },
            // label: const Text(''),
            child: const Icon(Icons.add)));

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

  void loadQuizzes() async {
    DBUser? user = await getAuthedUser();
    if (user != null) {
      var ownQuizzesSnapshot =
          await quizzesDB.where("User", isEqualTo: user.username).get();

      setState(() {
        _quizzes = ownQuizzesSnapshot.docs.map((doc) {
          var quizData = doc.data();
          return QuizInfo(doc.id, quizData['Name'], quizData['Category']);
        }).toList();
        loadedQuizzes = true;
      });
    }
  }

  Widget getMyQuizzesBody() {
    if (!loadedQuizzes) {
      loadQuizzes();
      return Center(child: CircularProgressIndicator());
    } else {
      if (_quizzes.isNotEmpty) {
        return ListView.builder(
            itemCount: _quizzes.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                  onTap: () async {
                    var chosenQuizSnapshot =
                        await quizzesDB.doc(_quizzes[index].quizID).get();

                    Quiz chosenQuiz = Quiz(
                        chosenQuizSnapshot['Name'],
                        chosenQuizSnapshot['Category'],
                        chosenQuizSnapshot['Questions']
                            .map<Question>((questionDoc) => Question(
                                questionDoc['Question'],
                                questionDoc['CorrectOptionIndex'],
                                questionDoc['Options'].cast<String>()))
                            .toList());

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => QuestionList(
                              chosenQuiz: chosenQuiz,
                              quizID: _quizzes[index].quizID,
                              quizzesDB: quizzesDB)),
                    );
                  },
                  child: Container(
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(color: Colors.grey.shade300))),
                      child: ListTile(
                        title: Text(_quizzes[index].name),
                        subtitle: Text(_quizzes[index].topic),
                      )));
            });
      } else {
        return Center(child: Text("No quizzes made yet."));
      }
    }
  }

  showLogoutConfirmation(BuildContext context) {
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget confirmButton = TextButton(
      child: Text("Log out"),
      onPressed: () async {
        await FirebaseAuth.instance.signOut();
        Navigator.pushReplacementNamed(context, '/login');
      },
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Log out?"),
          content: Text("Are you sure you want to log out?"),
          actions: [
            cancelButton,
            confirmButton,
          ],
        );
      },
    );
  }
}
