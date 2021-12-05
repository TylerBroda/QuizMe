// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:quizme/utils/auth.dart';
import 'package:quizme/views/initialize_quiz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quizme/views/question_list.dart';
import 'package:quizme/widgets/app_drawer.dart';
import '../model/quiz.dart';
import '../model/db_user.dart';

class MyQuizzes extends StatefulWidget {
  const MyQuizzes({Key? key}) : super(key: key);

  @override
  _MyQuizzesState createState() => _MyQuizzesState();
}

// Will list your quizzes that you made
class _MyQuizzesState extends State<MyQuizzes> {
  bool loadedQuizzes = false;

  var quizzesDB;

  @override
  void initState() {
    super.initState();
    setQuizzesDB();
  }

  void setQuizzesDB() async {
    DBUser? user = await getAuthedUser();
    if (user != null) {
      setState(() {
        quizzesDB = FirebaseFirestore.instance
            .collection('quizzes')
            .where("User", isEqualTo: user.username);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("My Quizzes"),
        ),
        drawer: const AppDrawer(),
        body: getMyQuizzesBody(),
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => InitializeQuiz(
                        quizID: "none", quizName: "", prevTopic: "")),
              );
            },
            child: const Icon(Icons.add)));
  }

  Widget getMyQuizzesBody() {
    if (quizzesDB == null) return Center(child: CircularProgressIndicator());

    return StreamBuilder(
        stream: quizzesDB.snapshots(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          } else {
            var docs = snapshot.data.docs;

            if (docs.isEmpty) {
              return Center(child: Text("No quizzes made yet."));
            }

            return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  var chosenQuizSnapshot = docs[index];
                  var quizData = chosenQuizSnapshot.data();

                  return GestureDetector(
                      onTap: () async {
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
                                  quizID: chosenQuizSnapshot.id)),
                        );
                      },
                      child: Container(
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom:
                                      BorderSide(color: Colors.grey.shade300))),
                          child: ListTile(
                              title: Text(quizData['Name']),
                              subtitle: Text(quizData['Category']),
                              trailing: quizData['isComplete']
                                  ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Icon(
                                          Icons.check_circle_outline,
                                          color: Colors.green,
                                        ),
                                        Text("Live",
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey)),
                                        SizedBox(width: 90)
                                      ],
                                    )
                                  : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Icon(Icons.handyman),
                                        Text("Work in progress",
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey))
                                      ],
                                    ))));
                });
          }
        });
  }
}
