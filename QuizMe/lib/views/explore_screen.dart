import 'package:flutter/material.dart';
import 'package:quizme/widgets/app_drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class ExploreScreen extends StatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final quizzes = FirebaseFirestore.instance.collection('quizzes');

  int _selectedIndex = -1;
  String _docID = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Explore")),
      drawer: const AppDrawer(),
      resizeToAvoidBottomInset: false,
      body: StreamBuilder(
        stream: quizzes.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const Text("No Data");
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (BuildContext context, int index) {
              final docData = snapshot.data!.docs[index].data() as Map;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedIndex = index;
                    _docID = snapshot.data!.docs[index].id;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  child: Card(
                    color: (_selectedIndex == index) ? Colors.blue : Colors.white,
                    child: ListTile(
                      title: Text(docData['Name'].toString()),
                      subtitle: Text(docData['User'].toString()),
                      trailing: const Icon(Icons.arrow_forward),
                    ),
                  )
                )
              );
            }
          );
        },
      ),
    );
  }
}