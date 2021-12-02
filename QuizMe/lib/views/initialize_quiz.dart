import 'package:flutter/material.dart';
import 'package:quizme/utils/categories.dart';
import './quiz_creator.dart';

class InitializeQuiz extends StatefulWidget {
  const InitializeQuiz({Key? key}) : super(key: key);

  @override
  _InitializeQuizState createState() => _InitializeQuizState();
}

class _InitializeQuizState extends State<InitializeQuiz> {
  final List<String> _items = CATEGORIES;
  String topic = CATEGORIES[0];

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
                                          topic: topic,
                                          quizName: quizNameController.text,
                                          quizID: "none",
                                        )),
                              );
                            }
                          },
                          child: const Text("Continue"))
                    ],
                  ),
                ))));
  }
}
