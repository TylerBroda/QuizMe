// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors
// @dart=2.9
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:quizme/utils/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key key}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

// db stuff
// validate
// adjust color hex code
// adjust underline color

//pass the username to to other pages and store info under username
//Todo: Encrypt Password
class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  var passwordController = TextEditingController();
  var retypedPasswordController = TextEditingController();

  String _Email = '';
  String _Password = '';
  String _Username = '';

  var userDB = FirebaseFirestore.instance.collection('users');

  RegExp validPassword = RegExp(r'^[A-Za-z0-9]'); //for password
  RegExp validUsername = RegExp(r'^[A-Za-z_]'); //for username

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
              Padding(
                padding: const EdgeInsets.only(top: 30, bottom: 10),
                child: Text("Sign Up",
                    style: TextStyle(fontSize: 24, color: Color(0xFF000000))),
              ),
              Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Email
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

                      // Username
                      TextFormField(
                        decoration: InputDecoration(
                          // change these colors if needed
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0x2F000000)),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          labelText: 'User Name',
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
                          if (value.contains(" ")) {
                            return "invalid username, can't contain spaces";
                          }

                          if (value.length < 6) {
                            return "Username must be longer than 6 characters";
                          }
                          if (validUsername.allMatches(value) == false) {
                            return "username can't contain special characters";
                          }
                          //Todo: validator check if the same username already exists
                          return null;
                        },
                        onSaved: (value) {
                          _Username = value;
                        },
                      ),

                      // Password
                      TextFormField(
                        controller: passwordController,
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
                          if (retypedPasswordController.text !=
                              passwordController.text) {
                            return "Passwords don't match";
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _Password = value;
                        },
                      ),

                      // Re-enter password
                      TextFormField(
                        controller: retypedPasswordController,
                        decoration: InputDecoration(
                          // change these colors if needed
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0x2F000000)),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          labelText: 'Re-enter Password',
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
                          if (retypedPasswordController.text !=
                              passwordController.text) {
                            return "Passwords don't match";
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
                        onPressed: () async {
                          if (_formKey.currentState.validate()) {
                            _formKey.currentState.save();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  duration: Duration(seconds: 1),
                                  content: Text('Valid'),
                                  backgroundColor: Colors.green),
                            );
                            addUser(_Email, _Username, _Password);
                            print(_Email);
                            print(_Password);
                            print(_Username);
                            Navigator.pop(context);
                            //goes back to login page
                          }
                        },
                        child: const Text('Continue'),
                      ),
                    ],
                  )),
              Center(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(color: Colors.grey),
                    children: [
                      TextSpan(text: 'Have an account? '),
                      TextSpan(
                          text: 'Sign In',
                          style: TextStyle(color: QuizAppColors.mainColor),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.pop(context);
                            }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> addUser(String email, String username, String password) {
    return userDB
        .add({'Email': email, 'Username': username, 'Password': password})
        .then((value) => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }
}
