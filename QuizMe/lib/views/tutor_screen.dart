import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TutorScreen extends StatefulWidget {
  const TutorScreen({Key? key}) : super(key: key);

  @override
  _TutorScreenState createState() => _TutorScreenState();
}

class _TutorScreenState extends State<TutorScreen> {
  final tutorData = FirebaseFirestore.instance.collection('tutors');

  List<Marker> tutors = [];

  final center = LatLng(43.9455, -78.8968); //For testing map

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
    return Scaffold(
      appBar:
          AppBar(title: const Text("Tutors"), automaticallyImplyLeading: false),
      body: FlutterMap(
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
      //TODO: Add geolocation for uploading tutor markers
      floatingActionButton:
          FloatingActionButton(
            onPressed: () {
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
                                      //TODO: Pricing info validation
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter pricing information';
                                      }
                                      return null;
                                    },
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
                                    validator: (value) {
                                      //TODO: Phone number format validation
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter a phone number';
                                      }
                                      return null;
                                    },
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
                                    controller: addressController,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter an address';
                                      }
                                      return null;
                                    },
                                    decoration: const InputDecoration(
                                      icon: Icon(Icons.home),
                                      labelText: 'Address *',
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
                        onPressed: () async {
                          //TODO: Submit geolocation info to firebase,

                          if (_formKey.currentState!.validate()) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Submitting Marker...')),
                            );

                            Map<String, dynamic> insertRow = {
                              "Name": nameController.text,
                              "Subject": subjectController.text,
                              "Price": priceController.text,
                              "Contact": phoneController.text,
                              "Email": emailController.text,
                              "Address": addressController.text,
                              "Description": descriptionController.text
                            };
                            await tutorData.add(insertRow);
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
