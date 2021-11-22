// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:quizme/utils/app_colors.dart';
import 'package:dbcrypt/dbcrypt.dart';
import 'package:quizme/utils/db_userhelper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

// circ avatar fix
// adjust text fonts and colors
// validator logic
// implement db calls
// adjust underline colors
// adjust signup spacing
class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = "1";
  String password = "1";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                  child: Container(
                      padding: EdgeInsets.only(top: 50, bottom: 25),
                      child: Image(
                        image: AssetImage('images/Logo.PNG'),
                      ))),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Text("Sign In",
                    style: TextStyle(
                      fontSize: 24,
                      color: Color(0xFF000000),
                    )),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Text("Hi there! Nice to see you again.",
                    style: TextStyle(color: Color(0x6F000000))),
              ),
              Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: InputDecoration(
                          // change these colors if needed
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0x2F000000)),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          labelText: 'Email',
                          labelStyle: TextStyle(
                              color: QuizAppColors.mainColor,
                              fontSize: 15,
                              fontFamily: 'AvenirLight'),
                        ),
                        style: TextStyle(
                            color: Colors.black87,
                            fontSize: 15,
                            fontFamily: 'AvenirLight'),
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return "Missing email";
                          }
                          // temp check - delete later
                          if (val != email) {
                            return "Invalid email or password";
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          // change these colors if needed
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0x2F000000)),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          labelText: 'Password',
                          labelStyle: TextStyle(
                              color: QuizAppColors.mainColor,
                              fontSize: 15,
                              fontFamily: 'AvenirLight'),
                        ),
                        style: TextStyle(
                            color: Colors.black87,
                            fontSize: 15,
                            fontFamily: 'AvenirLight'),
                        obscureText: true,
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return "Missing password";
                          }

                          //TODO: Verify email & password against email & hashed password in DB
                          print(val);
                          print(DBCrypt().checkpw('aaa',
                              DBCrypt().hashpw(val, new DBCrypt().gensalt())));

                          // temp check - delete later
                          if (val != password) {
                            return "Invalid email or password";
                          }
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                QuizAppColors.mainColor),
                            minimumSize: MaterialStateProperty.all(
                                Size(double.infinity, 35))),
                        onPressed: () {
                          if (!_formKey.currentState!.validate()) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                duration: Duration(seconds: 1),
                                content: Text('Invalid'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          } else {
                            // go to main screen if successfully logged in
                            Navigator.pushReplacementNamed(context, '/home');

                            // keep this for now to test db auth. delete it when that's working
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  duration: Duration(seconds: 1),
                                  content: Text('Valid'),
                                  backgroundColor: Colors.green),
                            );
                          }
                        },
                        child: const Text('Sign In'),
                      ),
                    ],
                  )),
              Row(
                children: [
                  Text(
                    "Forgot Password?",
                    style: TextStyle(color: Colors.grey),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, "/signup");
                    },
                    child: Text(
                      "Sign Up",
                      style: TextStyle(
                        color: QuizAppColors.mainColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
