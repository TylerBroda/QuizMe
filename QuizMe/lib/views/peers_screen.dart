// @dart=2.9
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quizme/utils/auth.dart';
import 'package:quizme/model/db_user.dart';
import 'package:quizme/widgets/app_drawer.dart';
import 'dart:math';

class PeersScreen extends StatefulWidget {
  const PeersScreen({Key key}) : super(key: key);

  @override
  _PeersScreenState createState() => _PeersScreenState();
}

class _PeersScreenState extends State<PeersScreen> {
  var peersDB = FirebaseFirestore.instance.collection('peers');
  TextEditingController _controller = TextEditingController();
  String mainuser = "Admin";
  String _mainDocID;
  String _selectedID;
  int _selectedIndx = -1;

  @override
  void initState() {
    super.initState();
    getdocid();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Peers List"),
        actions: [
          IconButton(
            onPressed: () {
              deleteUser(_selectedID);
            },
            icon: Icon(Icons.delete),
          ),
        ],
        backgroundColor: const Color(0xFFf85f6a),
      ),
      drawer: const AppDrawer(),
      body: StreamBuilder(
        stream: getData(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          if (snapshot.data.docs.length == 0) {
            return Card(
                child: Column(children: [
              ListTile(
                title: Text("No Peers Added",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              )
            ]));
          }
          return ListView.builder(
              padding: EdgeInsets.only(top: 10),
              itemCount: snapshot.data.docs.length,
              itemBuilder: (BuildContext ctxt, int index) {
                final docData = snapshot.data.docs[index];
                return Card(
                    child: Card(
                        color: _selectedIndx == index
                            ? Colors.cyanAccent.shade100.withOpacity(0.9)
                            : Colors.white,
                        child: Column(
                          children: [
                            ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.primaries[Random()
                                      .nextInt(Colors.primaries.length)],
                                  child: Text(
                                    docData['name'][0].toString().toUpperCase(),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ),
                                title: Text(
                                  docData['name'],
                                ),
                                onTap: () async {
                                  setState(() {
                                    _selectedIndx = index;
                                    _selectedID = docData.id;
                                  });
                                }),
                          ],
                        )));
              });
        },
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFFf85f6a),
          child: Icon(Icons.person_add_alt_1),
          onPressed: () async {
            _showDialog(context);
          }),
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
                title: const Center(
                  child: Text("ADD FRIEND"),
                ),
                children: [
                  Container(
                    padding: EdgeInsets.only(left: 30, right: 30),
                    child: TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Missing username";
                        }
                        if (value.contains(" ")) {
                          return "invalid username, can't contain spaces";
                        }

                        if (value.length < 6) {
                          return "Username must be longer than 6 characters";
                        }
                      },
                      onSaved: (value) {
                        input = value;
                      },
                      decoration:
                          const InputDecoration(labelText: "Enter Username"),
                    ),
                  ),
                  Container(
                      padding: const EdgeInsets.only(left: 40, right: 40),
                      width: 200,
                      child: ElevatedButton.icon(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateColor.resolveWith(
                                (states) => const Color(0xFFf85f6a))),
                        onPressed: () {
                          setState(() {
                            if (_formKey.currentState.validate()) {
                              _formKey.currentState.save();
                              addpeer(input);
                              Navigator.pop(context);
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

  Future<void> getdocid() async {
    DBUser user = await getAuthedUser();

    if (user != null) {
      setState(() {
        mainuser = user.username;
      });
    }

    bool userdbexists = false;
    var res = await peersDB
        .where('mainuser', isEqualTo: mainuser.toString())
        .get()
        .then((value) {
      value.docs.forEach((result) {
        setState(() {
          userdbexists = true;
          _mainDocID = result.id;
        });
      });
    });

    print(userdbexists);
    if (userdbexists == false) {
      peersDB.add({
        'mainuser': mainuser,
      }).then((value) {
        setState(() {
          _mainDocID = value.id;
          userdbexists = true;
        });
      }).catchError((error) => print("Failed to add user: $error"));
    }
  }

  Future<void> deleteUser(String id) {
    return peersDB
        .doc(_mainDocID)
        .collection('peernames')
        .doc(id.toString())
        .delete()
        .then((value) => print("Peer Deleted"))
        .catchError((error) => print("Failed to Delete Peer: $error"));
  }

  Future<void> addpeer(String peer) async {
    var userDB = FirebaseFirestore.instance.collection('users');
    var usersSnapshot = await userDB.where('Username', isEqualTo: peer).get();

    var peers = peersDB.doc(_mainDocID).collection('peernames');
    var peersSnapshot = await peers.where('name', isEqualTo: peer).get();

    if (peersSnapshot.size > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            duration: Duration(seconds: 5),
            content: Text(
              "User already exists",
              textAlign: TextAlign.start,
            ),
            backgroundColor: Colors.red),
      );
      return;
    } else if (usersSnapshot.size == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            duration: Duration(seconds: 5),
            content: Text(
              "The user does not exist",
              textAlign: TextAlign.start,
            ),
            backgroundColor: Colors.red),
      );
      return;
    } else {
      return peersDB
          .doc(_mainDocID.toString())
          .collection('peernames')
          .add({
            'name': peer,
          })
          .then((value) => print("Peer added"))
          .catchError((error) => print("Failed to add Peer: $error"));
    }
  }

  Stream<QuerySnapshot> getData() {
    return peersDB.doc(_mainDocID).collection('peernames').snapshots();
  }
}
