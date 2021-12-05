// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors
// @dart=2.9
import 'package:flutter/material.dart';
import 'package:quizme/utils/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quizme/utils/app_colors.dart';
import 'package:quizme/model/db_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({Key key}) : super(key: key);

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

// wrap this in a SizedBox with width: MediaQuery.of(context).size.width * 0.75 to change drawer width
// use the person's pfp
class _AppDrawerState extends State<AppDrawer> {
  String username = 'Admin';
  String email = 'Admin';
  @override
  void initState() {
    super.initState();
    retUser();
  }

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
                  child: Text(
                    username[0].toUpperCase(),
                    style: TextStyle(fontSize: 40, color: Colors.white),
                  ),
                  backgroundColor: Colors.red,
                  radius: 50,
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 12, bottom: 2),
                child: Center(
                  child: Text(
                    username,
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              Center(
                child: Text(
                  email,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              Spacer(),
              ListTile(
                leading: Icon(Icons.settings),
                onTap: () {
                  _showDialog(context);
                },
                title: Text("Change Email"),
              ),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text("Settings"),
              ),
              ListTile(
                leading: Icon(Icons.logout),
                onTap: () {
                  showLogoutConfirmation(context);
                },
                title: Text("Logout"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> retUser() async {
    DBUser user = await getAuthedUser();

    if (user != null) {
      setState(() {
        username = user.username;
        email = user.email;
      });
    }
  }

  showLogoutConfirmation(BuildContext context) {
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget confirmButton = TextButton(
      child: Text("Log out"),
      onPressed: () async {
        await FirebaseAuth.instance.signOut();
        Navigator.pushReplacementNamed(context, '/login');
      },
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Log out?"),
          content: Text("Are you sure you want to log out?"),
          actions: [
            cancelButton,
            confirmButton,
          ],
        );
      },
    );
  }

  _showDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    String input;
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Form(
            key: _formKey,
            child: SimpleDialog(
                title: Center(
                  child: Text("Change Email"),
                ),
                children: [
                  Container(
                    padding: EdgeInsets.only(left: 30, right: 30),
                    child: TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Missing email";
                        }
                        if (!value.contains("@")) {
                          return "invalid email";
                        }
                        if (value.contains(" ")) {
                          return "invalid email, can't contain spaces";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        input = value;
                      },
                      decoration: InputDecoration(labelText: "Enter New Email"),
                    ),
                  ),
                  Container(
                      padding: EdgeInsets.only(left: 40, right: 40),
                      width: 200,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            if (_formKey.currentState.validate()) {
                              _formKey.currentState.save();
                              updateUser(input);
                            }
                          });
                        },
                        icon: Icon(Icons.login),
                        label: Text("Submit"),
                      )),
                ]));
      },
    );
  }

  Future<void> updateUser(String nEmail) async {
    String docid;
    var userDB = FirebaseFirestore.instance.collection('users');
    var usersSnapshot = await userDB.where('Email', isEqualTo: nEmail).get();
    if (usersSnapshot.size > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            duration: Duration(seconds: 5),
            content: Text(
              "Email already exists.",
              textAlign: TextAlign.start,
            ),
            backgroundColor: Colors.red),
      );
    } else {
      /*
      Todo: Update Email
      */
    }
  }
}
