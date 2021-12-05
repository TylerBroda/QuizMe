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

class QuizInfo {
  String quizID;
  String name;
  String topic;
  bool isFilled;

  QuizInfo(this.quizID, this.name, this.topic, this.isFilled);
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

  var quizzesDB = FirebaseFirestore.instance.collection('quizzes');

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
                        quizName: "", prevTopic: "", rename: false)),
              );
            },
            child: const Icon(Icons.add)));
  }

  void loadQuizzes() async {
    DBUser? user = await getAuthedUser();
    if (user != null) {
      var ownQuizzesSnapshot =
          await quizzesDB.where("User", isEqualTo: user.username).get();

      setState(() {
        _quizzes = ownQuizzesSnapshot.docs.map((doc) {
          var quizData = doc.data();

          for (int i = 0; i < quizData['Questions'].length; i++) {
            if (quizData['Questions'][i]['Question'] == "" ||
                quizData['Questions'][i]['Options'].contains("")) {
              quizzesDB
                  .doc(doc.id)
                  .update({'isComplete': false})
                  .then((value) => print('isComplete updated'))
                  .catchError((error) => print('Failed to update'));
              return QuizInfo(
                  doc.id, quizData['Name'], quizData['Category'], false);
            }
          }

          quizzesDB
              .doc(doc.id)
              .update({'isComplete': true})
              .then((value) => print('isComplete updated'))
              .catchError((error) => print('Failed to update'));
          return QuizInfo(doc.id, quizData['Name'], quizData['Category'], true);
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
                          trailing: _quizzes[index].isFilled == true
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
                                            fontSize: 12, color: Colors.grey)),
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
                                            fontSize: 12, color: Colors.grey))
                                  ],
                                ))));
            });
      } else {
        return Center(child: Text("No quizzes made yet."));
      }
    }
  }
}
