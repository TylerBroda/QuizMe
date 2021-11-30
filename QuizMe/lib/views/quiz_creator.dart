import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quizme/utils/sample_data.dart';
import './question_creator.dart';
import '../model/quiz.dart';

List<GlobalKey<QuestionCreatorState>> globalKeys = [GlobalKey()];

class QuizCreator extends StatefulWidget {
  const QuizCreator(
      {Key? key, required this.questionNumber, required this.quizName})
      : super(key: key);

  final int questionNumber;
  final String quizName;

  @override
  _QuizCreatorState createState() => _QuizCreatorState(
      questionNumber: this.questionNumber, quizName: this.quizName);
}

class _QuizCreatorState extends State<QuizCreator> {
  String quizName;
  int questionNumber;
  _QuizCreatorState({required this.questionNumber, required this.quizName});

  List<Widget> questionPages = [];

  @override
  void initState() {
    super.initState();
    questionPages = [
      QuestionCreator(
          questionNumber: 1, callback: _callback, key: globalKeys[0])
    ];
  }

  _callback(Question question) {
    // print(d);
  }

  _saveQuiz() async {
    for (Widget questionPage in questionPages) {
      globalKeys[0].currentState?.saveQuestion();
    }
    print(questionPages[0]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text('Edit $quizName'),
            leading: IconButton(
              icon: Icon(Icons.list),
              onPressed: () {},
            ),
            centerTitle: true,
            automaticallyImplyLeading: false,
            actions: <Widget>[
              TextButton.icon(
                  label: const Icon(
                    Icons.check,
                    color: Colors.white,
                  ),
                  icon: Text('Done', style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    _saveQuiz();
                  })
            ]),
        resizeToAvoidBottomInset: false,
        body: IndexedStack(
          index: questionNumber - 1,
          children: questionPages,
        ),
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
                  : Container(width: 115, height: 10),
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
                            questionNumber: questionNumber + 1,
                            callback: _callback,
                            key: globalKeys[globalKeys.length - 1])
                      ];
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
}

class InitializeQuiz extends StatefulWidget {
  const InitializeQuiz({Key? key}) : super(key: key);

  @override
  _InitializeQuizState createState() => _InitializeQuizState();
}

class _InitializeQuizState extends State<InitializeQuiz> {
  final List<String> _items = ["Math", "Literature", "Science"];
  String topic = "Science";

  TextEditingController quizNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Create Quiz")),
        resizeToAvoidBottomInset: false,
        body: Center(
            child: Container(
                width: 350,
                height: 300,
                child: Card(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                          width: 300,
                          child: TextFormField(
                              decoration: const InputDecoration(
                                  labelText: "Quiz Name",
                                  icon: Icon(Icons.help)),
                              controller: quizNameController)),
                      Container(
                          width: 300,
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                                labelText: 'Topic', icon: Icon(Icons.school)),
                            isExpanded: true,
                            value: topic,
                            items: _items.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? value) {
                              setState(() {
                                topic = value!;
                              });
                            },
                          )),
                      ElevatedButton(
                          onPressed: () {
                            if (quizNameController.text.isNotEmpty &&
                                topic.isNotEmpty) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => QuizCreator(
                                        questionNumber: 1,
                                        quizName: quizNameController.text)),
                              );
                            }
                          },
                          child: const Text("Continue"))
                    ],
                  ),
                ))));
  }
}
