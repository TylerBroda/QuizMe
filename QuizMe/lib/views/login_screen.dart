// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors
// @dart=2.9
import 'package:flutter/material.dart';
import 'package:quizme/utils/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key key}) : super(key: key);

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
  var userDB = FirebaseFirestore.instance.collection('users');
  String _Email;
  String _Password;
  var userexists = false;
  var retusername;

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
                          _Email = value;
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Missing password";
                          }
                          if (value.length < 7) {
                            return 'Password must contain 7 characters';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _Password = value;
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
                        onPressed: () async {
                          if (_formKey.currentState.validate()) {
                            _formKey.currentState.save();
                            checkUser(_Email, _Password);
                            if (userexists == true) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    duration: Duration(seconds: 1),
                                    content: Text(
                                      "Login successful",
                                      textAlign: TextAlign.center,
                                    ),
                                    backgroundColor: Colors.green),
                              );
                              //Todo: Pass the username of the person who logged in
                              print(retusername);
                              //for now just printing the username
                              var result =
                                  await Navigator.pushNamed(context, '/home');
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    duration: Duration(seconds: 5),
                                    content: Text(
                                      "The Email you entered does not exist. Please check that you have typed your Email and Password correctly.",
                                      textAlign: TextAlign.center,
                                    ),
                                    backgroundColor: Colors.red),
                              );
                            }
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

  Future<void> checkUser(String email, String password) async {
    var res = await userDB
        .where('Email', isEqualTo: _Email.toString())
        .get()
        .then((value) {
      value.docs.forEach((result) {
        if (result.get('Password') == _Password) {
          setState(() {
            userexists = true;
            retusername = result.get('Username');
          });
        }
      });
    });
  }
}
