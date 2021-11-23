import 'package:flutter/material.dart';
import 'package:quizme/widgets/quiz_drawer.dart';


class ExploreScreen extends StatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Explore")),
      drawer: const QuizDrawer(),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Text('TODO: Uploaded Quiz sets & filter here'),
      ),
    );
  }
}