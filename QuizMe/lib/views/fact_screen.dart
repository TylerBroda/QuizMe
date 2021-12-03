import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FactScreen extends StatefulWidget {
  const FactScreen({Key? key}) : super(key: key);

  @override
  _FactScreenState createState() => _FactScreenState();
}

class _FactScreenState extends State<FactScreen> {
  
  String fact = '';
  String apiKey = dotenv.env['FACT_KEY'] as String;

  @override
  Widget build(BuildContext context) {
    var appBar = AppBar();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Interesting Facts!'),
        actions: [
          IconButton(
            onPressed: () {
              getData();
              setState(() {});
            }, 
            icon: const Icon(Icons.refresh)
          )
        ],
      ),
      body: FutureBuilder(
        future: getData(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
	          return const Center(child: CircularProgressIndicator());
	        }
          return Container(
                  padding: const EdgeInsets.all(30),
                  height: (MediaQuery.of(context).size.height - appBar.preferredSize.height) / 1.1,
                  width: MediaQuery.of(context).size.width,
                  child: Card(
                    child: Container(
                      padding: const EdgeInsets.all(30),
                      child: Center(
                        child: Text(
                          fact,
                          style: const TextStyle(
                            fontSize: 30
                          ),
                          ),
                      ),
                    ),
                  ),
                );
        }
      )
      );
  }

  Future<String> getData() async {
        
    Map<String, String> _headers = {
      "content-type": "application/json",
      "x-rapidapi-host": "facts-by-api-ninjas.p.rapidapi.com",
      "x-rapidapi-key": apiKey,
    };

    var url = Uri.https('facts-by-api-ninjas.p.rapidapi.com', '/v1/facts');
     
    //Await the http get response, then decode the json-formatted response
    var response = await http.get(url, headers: _headers);
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      fact = jsonResponse[0]['fact'];
      return fact;
    } 
    else {
      return 'Error: ${response.statusCode}';
    }
  }

}