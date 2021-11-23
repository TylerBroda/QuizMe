// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';

import 'package:quizme/utils/app_colors.dart';

class QuizDrawer extends StatefulWidget {
  const QuizDrawer({Key? key}) : super(key: key);

  @override
  _QuizDrawerState createState() => _QuizDrawerState();
}

// wrap this in a SizedBox with width: MediaQuery.of(context).size.width * 0.75 to change drawer width
// use the person's pfp
class _QuizDrawerState extends State<QuizDrawer> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Drawer(
        child: Container(
          margin: EdgeInsets.only(top: 5, bottom: 40, right: 15, left: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.close),
                color: QuizAppColors.mainColor,
              ),
              Center(
                child: CircleAvatar(
                  child: Text("pfp"),
                  radius: 30,
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 12, bottom: 2),
                child: Center(
                  child: Text(
                    "User Name",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              Center(
                child: Text(
                  "User Email",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              SizedBox(height: 50,),
              ListTile(
                leading: Icon(Icons.home),
                title: Text("Home"),
              ),
              ListTile(
                leading: Icon(Icons.explore),
                title: Text("Explore"),
              ),
              ListTile(
                leading: Icon(Icons.person_search),
                title: Text("Tutors"),
              ),
              ListTile(
                leading: Icon(Icons.people),
                title: Text("Peers"),
              ),
              Spacer(),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text("Settings"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
