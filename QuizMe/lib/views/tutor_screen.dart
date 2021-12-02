import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class TutorScreen extends StatefulWidget {
  const TutorScreen({Key? key}) : super(key: key);

  @override
  _TutorScreenState createState() => _TutorScreenState();
}

class _TutorScreenState extends State<TutorScreen> {
  final tutorData = FirebaseFirestore.instance.collection('tutors');

  List<Marker> tutors = [];

  final center = LatLng(43.9455, -78.8968); //For testing map: Ontario Tech
  //final center = LatLng(37.4219873, -122.0839954); //For testing map: Amphitheatre Pkwy

  Geolocator geolocator = Geolocator();
  String _currentLocation = '';
  String _address = '';
  String _phoneNum = '';
  String _price = '';
  double lat = 0.0, long = 0.0;

  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final subjectController = TextEditingController();
  final priceController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final descriptionController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getTutors().whenComplete(() => null);
  }

  @override
  Widget build(BuildContext context) {
    _checkPermissions();
    return Scaffold(
      appBar:
          AppBar(title: const Text("Tutors"), automaticallyImplyLeading: false),
      body: FlutterMap(
              //TODO: Initalize map with phones geolocation
              options: MapOptions(
                  zoom: 15.0, center: center, minZoom: 5, maxZoom: 20),
              layers: [
                TileLayerOptions(
                    urlTemplate: dotenv.env['MAP_URL'],
                    additionalOptions: {
                      'accessToken': "${dotenv.env['MAP_TOKEN']}",
                      'id': 'mapbox.mapbox-streets-v8'
                    }),
                MarkerLayerOptions(markers: tutors),
              ],
            ),
      floatingActionButton:
          FloatingActionButton(
            onPressed: () async {
              //Retrieving location & address
              var position = await _checkPermissions();
                          setState(() {
                            _currentLocation =
                                "Position(${position.latitude}, ${position.longitude})";
                            lat = position.latitude;
                            long = position.longitude;
                          });
              getAddress(lat, long);

              showDialog(
                context: context, 
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Submit a Tutor Marker!'),
                    content: Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: nameController,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter a name';
                                      }
                                      return null;
                                    },
                                    decoration: const InputDecoration(
                                      icon: Icon(Icons.person),
                                      labelText: 'Name *',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: subjectController,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter a subject';
                                      }
                                      return null;
                                    },
                                    decoration: const InputDecoration(
                                      icon: Icon(Icons.subject),
                                      labelText: 'Subject *',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: priceController,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter pricing';
                                      }
                                      return null;
                                    },
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      icon: Icon(Icons.money),
                                      labelText: 'Price *',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: phoneController,
                                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter a phone number';
                                      }
                                      else if (value.length != 10) {
                                        return 'Number must be 10 digits long';
                                      }
                                      return null;
                                    },
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      icon: Icon(Icons.phone),
                                      labelText: 'Phone Number *',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: emailController,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter an email';
                                      }
                                      else if (!value.contains("@") || value.contains(" ")) {
                                        return "Invalid email";
                                      }
                                      return null;
                                    },
                                    decoration: const InputDecoration(
                                      icon: Icon(Icons.mail),
                                      labelText: 'Email *',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: descriptionController,
                                    decoration: const InputDecoration(
                                      icon: Icon(Icons.info_outline),
                                      labelText: 'Description',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    ),
                    actions: [
                      OutlinedButton(
                        //TODO: Refresh map to display new marker once submitted
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Submitting Marker...')),
                            );

                            _price = 
                              '\$' + priceController.text.replaceAll(' ', '').replaceAll('-', '') + '/hr';

                            _phoneNum = 
                              '(' + phoneController.text.substring(0,3) + ')' 
                              + ' ' + phoneController.text.substring(3,6) + ' - ' + phoneController.text.substring(6,10);

                            Map<String, dynamic> insertRow = {
                              "Name": nameController.text,
                              "Subject": subjectController.text,
                              "Price": _price,
                              "Contact": _phoneNum,
                              "Email": emailController.text,
                              "Address": _address,
                              "Description": descriptionController.text,
                              "Location": GeoPoint(lat, long)
                            };
                            await tutorData.add(insertRow);

                            setState(() {});
                          }
                        }, 
                        child: const Text(
                          'Submit',
                          style: TextStyle(color: Colors.white),
                          ),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                              if (states.contains(MaterialState.pressed)) {
                                return Theme.of(context).colorScheme.primary.withOpacity(0.5);
                              }
                              return Colors.blue;
                            },
                          )
                        ),
                      )
                    ],
                  );
                }
              );
            }, 
            child: const Icon(Icons.add)),
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

  Future<Position> _checkPermissions() async {
    LocationPermission permission;

    permission = await Geolocator.checkPermission();

    Geolocator.requestPermission();

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
	}

  getAddress(double latitude, double longitude) async {
    List<Placemark> places =
        await placemarkFromCoordinates(latitude, longitude);

    _address =
        "${places.first.street}, ${places.first.locality}, ${places.first.country}, ${places.first.postalCode}";
	}

}

Widget bottomSheet(String name, String email, String address, String subject,
    String contact, String description, String price) {
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
              title: FittedBox(child: Text('$contact')),
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
              style: TextStyle(fontWeight: FontWeight.bold),
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
