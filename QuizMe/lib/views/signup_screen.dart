// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:quizme/utils/app_colors.dart';
import 'package:dbcrypt/dbcrypt.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

// db stuff
// validate
// adjust color hex code
// adjust underline color
class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(child:  Container(
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
                        // if (val != email) {
                        //   return "Invalid email or password";
                        // }
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
                        // TODO: Pass email & hashed password to DB
                        print('Password: ' + val);
                        print(DBCrypt().hashpw(val, new DBCrypt().gensalt()));

                        // temp check - delete later
                        // if (val != password) {
                        //   return "Invalid email or password";
                        // }
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
                          // go to main screen
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                duration: Duration(seconds: 1),
                                content: Text('Valid'),
                                backgroundColor: Colors.green),
                          );
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
    ),);
  }
}
