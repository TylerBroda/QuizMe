// @dart=2.9
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:quizme/utils/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class PeersScreen extends StatefulWidget {
  PeersScreen({Key key, this.userloggedin = 'Admin_User'}) : super(key: key);
  //change the userloggedin
  String userloggedin;

  @override
  _PeersScreenState createState() => _PeersScreenState();
}

class _PeersScreenState extends State<PeersScreen> {
  var peersDB = FirebaseFirestore.instance.collection('peers');
  String _selectedid = '';
  int _selectedIndx = -1;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: Colors.brown,
              child: Text(
                widget.userloggedin[0],
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            SizedBox(
              width: 20,
            ),
            Text(
              "Peers List",
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              addpeer("Liam_Neeson");
            },
            icon: Icon(Icons.delete),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: getData(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return Text("No Data");
          return ListView.separated(
              padding: EdgeInsets.only(top: 10),
              separatorBuilder: (context, index) => Divider(
                    color: Colors.black,
                    thickness: 1,
                  ),
              itemCount: snapshot.data.docs.length,
              itemBuilder: (BuildContext ctxt, int index) {
                final docData = snapshot.data.docs[index];
                return Card(
                    child: Card(
                        color: _selectedIndx == index
                            ? Colors.amber
                            : Colors.transparent,
                        child: Column(
                          children: [
                            ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.brown,
                                  child: Text(
                                    docData['peername'][0],
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ),
                                title: Text(
                                  docData['peername'],
                                ),
                                onTap: () async {
                                  setState(() {
                                    _selectedIndx = index;
                                  });
                                }),
                          ],
                        )));
              });
        },
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () async {
            print("Pressed");
          }),
    );
  }

  Future<void> getdocid(String mainuser) async {
    var res = await peersDB
        .where('mainuser', isEqualTo: mainuser.toString())
        .get()
        .then((value) {
      value.docs.forEach((result) {
        setState(() {
          _selectedid = result.id;
        });
      });
    });
  }

  Future<void> addpeer(String peer) async {
    return peersDB
        .doc(_selectedid.toString())
        .collection('peernames')
        .add({
          'name': peer,
        })
        .then((value) => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }

  Stream<QuerySnapshot> getData() {
    return peersDB.snapshots();
  }
}
