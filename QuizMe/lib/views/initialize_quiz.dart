import 'package:flutter/material.dart';
import 'package:quizme/utils/categories.dart';
import './quiz_creator.dart';
import '../model/quiz.dart';

class InitializeQuiz extends StatefulWidget {
  const InitializeQuiz(
      {Key? key,
      required this.quizName,
      required this.prevTopic,
      required this.rename})
      : super(key: key);

  final String quizName;
  final String prevTopic;
  final bool rename;

  @override
  _InitializeQuizState createState() => _InitializeQuizState(
      quizName: this.quizName, prevTopic: this.prevTopic, rename: this.rename);
}

class _InitializeQuizState extends State<InitializeQuiz> {
  final _formKey = GlobalKey<FormState>();

  final String quizName;
  final String prevTopic;
  final bool rename;

  final List<String> _items = CATEGORIES;
  String topic = CATEGORIES[0];

  _InitializeQuizState(
      {required this.quizName, required this.prevTopic, required this.rename});

  TextEditingController quizNameController = TextEditingController();

  @override
  void initState() {
    super.initState();

    quizNameController.text = quizName;
    if (prevTopic != "") topic = prevTopic;
  }

  renameQuiz() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title:
                rename ? const Text("Rename Quiz") : const Text("Create Quiz")),
        resizeToAvoidBottomInset: false,
        body: Center(
            child: SafeArea(
                child: Container(
                    width: 350,
                    height: 300,
                    child: Form(
                        key: _formKey,
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
                                      controller: quizNameController,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Give your quiz a name.";
                                        }
                                        return null;
                                      })),
                              Container(
                                  width: 300,
                                  child: DropdownButtonFormField<String>(
                                    decoration: const InputDecoration(
                                        labelText: 'Topic',
                                        icon: Icon(Icons.school)),
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
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      rename
                                          ? renameQuiz()
                                          : Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      QuizCreator(
                                                        questionNumber: 1,
                                                        chosenQuiz: Quiz(
                                                            quizNameController
                                                                .text,
                                                            topic,
                                                            []),
                                                        quizID: "none",
                                                      )),
                                            );
                                    }
                                  },
                                  child: rename
                                      ? const Text("Rename")
                                      : const Text("Continue"))
                            ],
                          ),
                        ))))));
  }
}
