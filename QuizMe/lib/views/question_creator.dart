import 'package:flutter/material.dart';
import '../model/quiz.dart';

class EditOption {
  TextEditingController controller;
  bool isAnswer;

  EditOption(this.controller, this.isAnswer);
}

class QuestionCreator extends StatefulWidget {
  const QuestionCreator(
      {Key? key, required this.questionNumber, required this.callback})
      : super(key: key);

  final int questionNumber;
  final Function callback;

  @override
  QuestionCreatorState createState() => QuestionCreatorState(
      questionNumber: this.questionNumber, callback: this.callback);
}

class QuestionCreatorState extends State<QuestionCreator> {
  int questionNumber;
  final Function callback;

  QuestionCreatorState({required this.questionNumber, required this.callback});

  TextEditingController questionController = TextEditingController();

  List<EditOption> _editOptions = [
    EditOption(TextEditingController(), true),
    EditOption(TextEditingController(), false),
  ];

  saveQuestion() {
    print(questionNumber);
    // List<Option> options = [];

    // for (EditOption option in _editOptions) {
    //   options = [...options, Option(option.controller.text, option.isAnswer)];
    // }

    // callback(Question(questionController.text, options));
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
          padding: const EdgeInsets.all(15.0),
          child: Text(
            "Question $questionNumber",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          )),
      Expanded(
          child: ListView.builder(
              padding: const EdgeInsets.all(20.0),
              itemCount: _editOptions.length + 2,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return TextFormField(
                      decoration: const InputDecoration(
                          labelText: "Question", icon: Icon(Icons.help)),
                      maxLines: 6,
                      controller: questionController);
                } else if (index <= _editOptions.length) {
                  return Row(
                    children: [
                      Expanded(
                        flex: 8,
                        child: TextFormField(
                            decoration: InputDecoration(
                                labelText: "Option ${index.toString()}",
                                icon: Text("${index.toString()}.")),
                            maxLines: 2,
                            controller: _editOptions[index - 1].controller),
                      ),
                      Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              Radio(
                                fillColor: MaterialStateColor.resolveWith(
                                    (states) => _editOptions[index - 1].isAnswer
                                        ? Colors.green
                                        : Colors.red),
                                value: index - 1,
                                groupValue: _editOptions[index - 1].isAnswer
                                    ? index - 1
                                    : -1,
                                onChanged: (value) {
                                  setState(() {
                                    for (EditOption option in _editOptions) {
                                      option.isAnswer = false;
                                    }
                                    _editOptions[index - 1].isAnswer = true;
                                  });
                                },
                              ),
                              Text(
                                  _editOptions[index - 1].isAnswer
                                      ? "Correct"
                                      : "Incorrect",
                                  style: TextStyle(
                                      color: _editOptions[index - 1].isAnswer
                                          ? Colors.green
                                          : Colors.red,
                                      fontSize: 12))
                            ],
                          )),
                    ],
                  );
                } else {
                  return Center(
                      child: Container(
                          margin: const EdgeInsets.all(20.0),
                          child: ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _editOptions = [
                                    ..._editOptions,
                                    EditOption(TextEditingController(), false)
                                  ];
                                });
                              },
                              icon: const Icon(Icons.add),
                              label: const Text("Option"))));
                }
              })),
    ]);
  }
}
