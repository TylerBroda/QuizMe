import 'package:flutter/material.dart';
import '../model/quiz.dart';

class EditOption {
  TextEditingController controller;

  EditOption(this.controller);
}

class QuestionCreator extends StatefulWidget {
  const QuestionCreator({Key? key, required this.appendQuestionCB})
      : super(key: key);

  final Function appendQuestionCB;

  @override
  QuestionCreatorState createState() =>
      QuestionCreatorState(appendQuestionCB: this.appendQuestionCB);
}

class QuestionCreatorState extends State<QuestionCreator> {
  int correctOptionIndex = 0;
  final Function appendQuestionCB;

  QuestionCreatorState({required this.appendQuestionCB});

  TextEditingController questionController = TextEditingController();
  bool deleteMode = false;

  List<EditOption> _editOptions = [
    EditOption(TextEditingController()),
    EditOption(TextEditingController()),
  ];

  switchDeleteMode(bool sync) {
    setState(() {
      deleteMode = sync ? false : !deleteMode;
    });
  }

  saveQuestion() {
    List<String> options = [];

    for (EditOption editOption in _editOptions) {
      options = [...options, editOption.controller.text];
    }

    appendQuestionCB(
        Question(questionController.text, correctOptionIndex, options));
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
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
                    child: !deleteMode
                        ? Column(
                            children: [
                              Radio(
                                fillColor: MaterialStateColor.resolveWith(
                                    (states) =>
                                        (index - 1 == correctOptionIndex)
                                            ? Colors.green
                                            : Colors.red),
                                value: index - 1,
                                groupValue: (index - 1 == correctOptionIndex)
                                    ? index - 1
                                    : -1,
                                onChanged: (value) {
                                  setState(() {
                                    correctOptionIndex = index - 1;
                                    // for (EditOption option in _editOptions) {
                                    //   option.isAnswer = false;
                                    // }
                                    // _editOptions[index - 1].isAnswer = true;
                                  });
                                },
                              ),
                              Text(
                                  (index - 1 == correctOptionIndex)
                                      ? "Correct"
                                      : "Incorrect",
                                  style: TextStyle(
                                      color: (index - 1 == correctOptionIndex)
                                          ? Colors.green
                                          : Colors.red,
                                      fontSize: 12))
                            ],
                          )
                        : IconButton(
                            onPressed: () {
                              if (_editOptions.length > 2) {
                                setState(() {
                                  _editOptions.removeAt(index - 1);
                                });
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            "You need at least 2 options.")));
                              }
                            },
                            icon: Icon(Icons.delete),
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
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
                              EditOption(TextEditingController())
                            ];
                          });
                        },
                        icon: const Icon(Icons.add),
                        label: const Text("Option"))));
          }
        });
  }
}
