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

  final center = LatLng(43.9455, -78.8968); //For testing map

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tutors")
      ),
      body: StreamBuilder(
        stream: api.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const Text("Loading Map...");
          apiDocs = snapshot.data!.docs;
          apiData = apiDocs[0].data() as Map;

          return FlutterMap(
            options: MapOptions(zoom: 15.0, center: center, minZoom: 5, maxZoom: 20),
            layers: [
              TileLayerOptions(
                urlTemplate: apiData['mapURL'].toString(),
                additionalOptions: {
                  'accessToken': apiData['mapToken'].toString(),
                  'id': 'mapbox.mapbox-streets-v8'
                }
              ),
              //TODO: Add tutor markers from firebase
              /*
              MarkerLayerOptions(
                markers: 
              ),
              */
            ],
          );
        }
      ),
      //TODO: Add geolocation for uploading tutor markers
      floatingActionButton: FloatingActionButton(
        onPressed: () {

        },
        child: const Icon(Icons.add)
      ),
    );
  }
}