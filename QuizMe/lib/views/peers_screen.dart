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
  String _mainDocID;
  String _selectedID;
  int _selectedIndx = -1;

  @override
  void initState() {
    super.initState();
    getdocid(widget.userloggedin);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
              deleteUser(_selectedID);
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
                                    docData['name'][0],
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
          child: Icon(Icons.add),
          onPressed: () async {
            //Todo: Adding a validator for checking if the person exists in the db
            addpeer("Liam_Neeson");
          }),
    );
  }

  Future<void> getdocid(String mainuser) async {
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
    return peersDB
        .doc(_mainDocID.toString())
        .collection('peernames')
        .add({
          'name': peer,
        })
        .then((value) => print("Peer added"))
        .catchError((error) => print("Failed to add Peer: $error"));
  }

  Stream<QuerySnapshot> getData() {
    return peersDB.doc(_mainDocID).collection('peernames').snapshots();
  }
}
