import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TutorScreen extends StatefulWidget {
  const TutorScreen({Key? key}) : super(key: key);

  @override
  _TutorScreenState createState() => _TutorScreenState();
}

class _TutorScreenState extends State<TutorScreen> {
  final api = FirebaseFirestore.instance.collection('api');
  List<DocumentSnapshot> apiDocs = [];
  late Map<dynamic, dynamic> apiData;

  final tutorData = FirebaseFirestore.instance.collection('tutors');
  List<Marker> tutors = [];

  final center = LatLng(43.9455, -78.8968); //For testing map

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      getTutors().whenComplete(() => null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tutors")),
      body: StreamBuilder(
          stream: api.snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) return const Text("Loading Map...");
            apiDocs = snapshot.data!.docs;
            apiData = apiDocs[0].data() as Map;
            return FlutterMap(
              options: MapOptions(
                  zoom: 15.0, center: center, minZoom: 5, maxZoom: 20),
              layers: [
                TileLayerOptions(
                    urlTemplate: apiData['mapURL'].toString(),
                    additionalOptions: {
                      'accessToken': apiData['mapToken'].toString(),
                      'id': 'mapbox.mapbox-streets-v8'
                    }),
                MarkerLayerOptions(markers: tutors),
              ],
            );
          }),
      //TODO: Add geolocation for uploading tutor markers
      floatingActionButton:
          FloatingActionButton(onPressed: () {}, child: const Icon(Icons.add)),
    );
  }

  Future<void> getTutors() async {
    await FirebaseFirestore.instance.collection('tutors').get().then((result) {
      if (result.docs.isNotEmpty) {
        result.docs.forEach((e) {
          Marker marker = Marker(
              builder: (BuildContext context) {
                return IconButton(
                  onPressed: () {
                    showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return bottomSheet(
                              e.data()['Name'],
                              e.data()['Email'],
                              e.data()['Address'],
                              e.data()['Subject'],
                              e.data()['Contact'],
                              e.data()['Description'],
                              e.data()['Price']);
                        });
                  },
                  icon: const Icon(Icons.location_on),
                  iconSize: 30.0,
                  color: Colors.blueAccent,
                );
              },
              point: LatLng(e.data()['Location'].latitude,
                  e.data()['Location'].longitude));
          setState(() {
            tutors.add(marker);
          });
        });
      }
    });

    return;
  }
}

Widget bottomSheet(String name, String email, String address, String subject, String contact, String description, String price) {
  return Column(
          children: [
            Container(
              height: 80,
              color: Colors.blueAccent,
              child: ListTile(
                title: Text(
                  '$name',
                  style: const TextStyle(color: Colors.white, fontSize: 20.0),
                ),
                subtitle: Text(
                  '$subject',
                  style: const TextStyle(color: Colors.white70, fontSize: 14.0),
                ),
                trailing: Text(
                  '$price',
                  style: const TextStyle(color: Colors.white, fontSize: 20.0),
                ),
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: 250,
                  child: ListTile(
                    title: FittedBox(
                      child: Text('$contact')
                    ),
                    leading: const Icon(
                      Icons.call,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(
              thickness: 1.5,
            ),
            Row(
              children: [
                SizedBox(
                  width: 300,
                  child: ListTile(
                    title: FittedBox(child: Text('$email')),
                    leading: const Icon(
                      Icons.mail,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(
              thickness: 1.5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: ListTile(
                    title: FittedBox(child: Text('$address')),
                    leading: const Icon(
                      Icons.location_on,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(
              thickness: 1.5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'About:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 2, right: 8),
                  child: SizedBox(
                    width: 320,
                    child: Text(
                      '$description',
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
              ],
            )
          ],
        );
}
