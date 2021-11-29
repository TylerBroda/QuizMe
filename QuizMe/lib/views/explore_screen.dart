import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:quizme/widgets/app_drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class ExploreScreen extends StatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final quizzes = FirebaseFirestore.instance.collection('quizzes');
  List<DocumentSnapshot> filterDocs = [];

  int _selectedIndex = -1;
  String _docID = '';

  List<String> options = ['All', 'English', 'History', 'Math', 'Science'];
  String dropdownValue = 'All';

  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          height: 35,
          child: TextField(
              controller: _searchController,
              onChanged: (String? newValue) {
                setState(() {
                });
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Search',
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                fillColor: Colors.white,
                filled: true,
                contentPadding: EdgeInsets.only(
                  bottom: 35 / 2,  
                )
              ),
            ),
        ),
        actions: <Widget>[
          Container(
            margin: const EdgeInsets.only(top: 20, right: 5),
            child: const Text(
              'Category:', 
              style: TextStyle(
                fontWeight: FontWeight.bold
              ),
            )
          ),
          ButtonTheme(
            alignedDropdown: true,
            child: DropdownButton<String>(
              value: dropdownValue,
              icon: const Icon(Icons.arrow_downward),
              iconEnabledColor: Colors.white,
              iconSize: 20,
              style: const TextStyle(color: Colors.black),
              //For seperating colours between selected item & dropdown list items
              //Had trouble with item positioning and dropdown size, commented out for now
              /*
              selectedItemBuilder: (BuildContext context) {
                return options.map((String value) {
                  return Text(
                    dropdownValue,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  );
                }).toList();
              },
              */
              underline: Container(
                height: 2,
                color: Colors.white,
              ),
              onChanged: (String? newValue) {
                setState(() {
                  dropdownValue = newValue!;
                });
              },
              items: options.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Container(
                    width: 50,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(
            width: 20
          )
        ],
      ),
      drawer: const AppDrawer(),
      resizeToAvoidBottomInset: false,
      body: StreamBuilder(
        stream: quizzes.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const Text("No Data");

          //Filter quizzes by dropdown selection
          filterDocs = snapshot.data!.docs;
          if (dropdownValue != 'All') {
            filterDocs = filterDocs.where((element) {
              return element
                  .get('Category')
                  .toString()
                  .toLowerCase()
                  .contains(dropdownValue.toLowerCase());
            }).toList();
          }

          //Filter quizzes by search value
          if (_searchController.text != '') {
            filterDocs = filterDocs.where((element) {
              return element
                  .get('Name')
                  .toString()
                  .toLowerCase()
                  .startsWith(_searchController.text.toLowerCase());
            }).toList();
          }

          return ListView.builder(
            itemCount: filterDocs.length,
            itemBuilder: (BuildContext context, int index) {
              final docData = filterDocs[index].data() as Map;
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