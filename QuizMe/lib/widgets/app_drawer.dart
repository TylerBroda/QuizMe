// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:quizme/utils/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quizme/utils/app_colors.dart';
import 'package:quizme/model/db_user.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

// wrap this in a SizedBox with width: MediaQuery.of(context).size.width * 0.75 to change drawer width
// use the person's pfp
class _AppDrawerState extends State<AppDrawer> {
  String? username = 'Admin';
  String? email = 'Admin';
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
                    username![0].toUpperCase(),
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
                    username!,
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              Center(
                child: Text(
                  email!,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              Spacer(),
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
    DBUser? user = await getAuthedUser();

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
}
