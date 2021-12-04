import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quizme/model/db_user.dart';
import 'package:quizme/utils/auth.dart';
import './question_creator.dart';
import './question_list.dart';
import '../model/quiz.dart';

class QuizCreator extends StatefulWidget {
  const QuizCreator(
      {Key? key,
      required this.questionNumber,
      required this.chosenQuiz,
      required this.quizID})
      : super(key: key);

  final int questionNumber;
  final Quiz chosenQuiz;
  final String quizID;

  @override
  _QuizCreatorState createState() => _QuizCreatorState(
      questionNumber: this.questionNumber,
      chosenQuiz: this.chosenQuiz,
      quizID: this.quizID);
}

class _QuizCreatorState extends State<QuizCreator> {
  final CollectionReference quizzesDB =
      FirebaseFirestore.instance.collection("quizzes");

  int questionNumber;
  Quiz chosenQuiz;
  String quizID;
  bool deleteMode = false;

  _QuizCreatorState(
      {required this.questionNumber,
      required this.chosenQuiz,
      required this.quizID});

  List<GlobalKey<QuestionCreatorState>> globalKeys = [];
  List<Widget> questionPages = [];
  Quiz quiz = Quiz("", "", []);

  @override
  void initState() {
    super.initState();

    quiz = Quiz(chosenQuiz.name, chosenQuiz.topic, chosenQuiz.questions);

    if (quizID == "none") {
      globalKeys = [GlobalKey()];
      questionPages = [
        QuestionCreator(
            question: Question("", 0, []),
            appendQuestionCB: _appendQuestionCB,
            key: globalKeys[0])
      ];
    } else {
      for (int i = 0; i < chosenQuiz.questions.length; i++) {
        globalKeys = [...globalKeys, GlobalKey()];
        questionPages = [
          ...questionPages,
          QuestionCreator(
              question: chosenQuiz.questions[i],
              appendQuestionCB: _appendQuestionCB,
              key: globalKeys[i])
        ];
      }
    }
  }

  _deleteQuestion(int index) async {
    setState(() {
      questionNumber = questionNumber - 1; // Go back a page
      globalKeys.removeAt(index);
      questionPages.removeAt(index); // Delete widget
    });

    // if (quiz.questions.isNotEmpty) {
    //   _saveQuiz();
    // }
  }

  // Callback function
  _appendQuestionCB(Question newQuestion) {
    quiz.questions = [...quiz.questions, newQuestion];
  }

  // Access child functions
  _switchDeleteModes({bool sync = false}) async {
    for (int i = 0; i < questionPages.length; i++) {
      // print("${globalKeys[i].currentState} $i");
      await globalKeys[i].currentState?.switchDeleteMode(sync);
    }
    setState(() {
      deleteMode = sync ? false : !deleteMode;
    });
  }

  _saveQuiz() async {
    quiz.questions = [];
    for (int i = 0; i < questionPages.length; i++) {
      await globalKeys[i].currentState?.saveQuestion();
    }

    DBUser? user = await getAuthedUser();

    var quizData = {
      "Name": quiz.name,
      "Category": quiz.topic,
      "Questions": quiz.questions
          .map((question) => {
                "Question": question.question,
                "CorrectOptionIndex": question.correctOptionIndex,
                "Options": question.options
              })
          .toList(),
      "User": user?.username
    };

    // If this is a brand new quiz, make a new one in the database and then stick to its new ID
    // Otherwise update the chosen ID
    if (quizID == "none") {
      DocumentReference newQuiz = await quizzesDB.add(quizData);
      quizID = newQuiz.id;
    } else {
      await quizzesDB.doc(quizID).update(quizData);
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Saved ${quiz.name}.")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text('Edit ${quiz.name}'),
            automaticallyImplyLeading: false,
            actions: <Widget>[
              IconButton(
                  onPressed: () {
                    _switchDeleteModes();
                  },
                  icon: !deleteMode ? Icon(Icons.delete) : Icon(Icons.edit)),
              TextButton.icon(
                  label: const Icon(
                    Icons.check,
                    color: Colors.white,
                  ),
                  icon:
                      const Text('Done', style: TextStyle(color: Colors.white)),
                  onPressed: () async {
                    await _saveQuiz();
                    Navigator.pushNamed(context, '/home');
                  })
            ]),
        resizeToAvoidBottomInset: false,
        body: Column(children: [
          Container(
              padding: const EdgeInsets.all(20),
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(
                  "Question $questionNumber",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 20),
                ),
                const SizedBox(width: 10),
                deleteMode
                    ? IconButton(
                        onPressed: () {
                          areYouSure(context);
                        },
                        icon: Icon(Icons.delete),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      )
                    : Container()
              ])),
          Expanded(
            child: IndexedStack(
                index: questionNumber - 1, children: questionPages),
          )
        ]),
        bottomNavigationBar: BottomAppBar(
            child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
              questionNumber > 1
                  ? TextButton.icon(
                      icon: Icon(Icons.arrow_back),
                      label: Text('Question ${questionNumber - 1}'),
                      onPressed: () {
                        setState(() {
                          questionNumber = questionNumber - 1;
                        });
                      },
                    )
                  : Container(width: 116, height: 10),
              IconButton(
                  onPressed: () async {
                    await _saveQuiz();

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => QuestionList(
                              chosenQuiz: quiz,
                              quizID: quizID,
                              quizzesDB: quizzesDB)),
                    );
                  },
                  icon: const Icon(
                    Icons.list,
                    color: Colors.blue,
                  )),
              TextButton.icon(
                icon: Text('Question ${questionNumber + 1}'),
                label: questionNumber == questionPages.length
                    ? Icon(Icons.add)
                    : Icon(Icons.arrow_forward),
                onPressed: () {
                  setState(() {
                    if (questionNumber == questionPages.length) {
                      globalKeys = [...globalKeys, GlobalKey()];

                      questionPages = [
                        ...questionPages,
                        QuestionCreator(
                            question: Question("", 0, []),
                            appendQuestionCB: _appendQuestionCB,
                            key: globalKeys[globalKeys.length - 1])
                      ];

                      _switchDeleteModes(sync: true);
                    }
                    questionNumber = questionNumber + 1;
                  });
                },
              )
            ])),
        floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.save),
            onPressed: () {
              _saveQuiz();
            }));
  }

  areYouSure(BuildContext context) {
    AlertDialog alert = AlertDialog(
      title: Text("Delete Question $questionNumber"),
      content:
          Text("Are you sure you want to delete Question $questionNumber?"),
      actions: [
        TextButton(
          child: const Text("NO"),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        TextButton(
          child: const Text("YES"),
          onPressed: () async {
            await _deleteQuestion(questionNumber - 1);
            Navigator.pop(context);
          },
        ),
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
