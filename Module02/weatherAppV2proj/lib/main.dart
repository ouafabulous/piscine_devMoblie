import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocode/geocode.dart';
import 'package:location/location.dart' as loc;
import 'package:http/http.dart' as http;

void main() => runApp(const MainApp());

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class LocData {
  double latitude;
  double longitude;
  String name;
  String region;
  String country;

  LocData(
      {required this.latitude,
      required this.longitude,
      required this.name,
      required this.region,
      required this.country});

  factory LocData.fromJson(Map<String, dynamic> json) {
    return LocData(
        latitude: json['latitude'],
        longitude: json['longitude'],
        name: json['name'],
        region: json['admin1'],
        country: json['country']);
  }
}

Future<List<LocData>> getSearchResults(String query) async {
  if (query.length < 2) {
    return [];
  }

  try {
    var url =
        Uri.parse("https://geocoding-api.open-meteo.com/v1/search?name=$query");
    var response = await http.get(url);

    if (response.statusCode == 200) {
      List<LocData> locations = [];
      var data = response.body;
      var jsonData = json.decode(data);

      final Map map = Map.from(jsonData);

      for (var item in map['results']) {
        LocData location = LocData.fromJson(item);
        locations.add(location);
      }
      return locations;
    } else {
      throw Exception('Failed to load data');
    }
  } catch (e) {
    print("Error: $e");
    return [];
  }
}

class _HomePageState extends State<HomePage> {
  var location = "";
  final TextEditingController _textEditingController = TextEditingController();

  void updateLocation(String value) {
    setState(() {
      location = value;
      _textEditingController.clear(); // Clear the text field
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 1,
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          title: Container(
            alignment: Alignment.centerLeft,
            child: Autocomplete<LocData>(
              optionsBuilder: (TextEditingValue textEditingValue) async {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable.empty();
                }
                return await getSearchResults(textEditingValue.text);
              },
              displayStringForOption: (LocData option) =>
                  "${option.name}, ${option.region}, ${option.country}",
              fieldViewBuilder: (BuildContext context,
                  TextEditingController textEditingController,
                  FocusNode focusNode,
                  VoidCallback onFieldSubmitted) {
                return TextField(
                    controller: textEditingController,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      hintText: 'Search location',
                    ),
                    onSubmitted: (value) => updateLocation(value));
              },
              onSelected: (LocData selection) {
                updateLocation(selection.name);
              },
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.location_pin),
              onPressed: () {
                LocationService().requestPermission().then((value) => {
                      if (value)
                        {
                          LocationService()
                              .getCurrentLocation()
                              .then((locationData) async {
                            try {
                              var address = await GeoCode().reverseGeocoding(
                                  latitude: locationData.latitude ?? 0.0,
                                  longitude: locationData.longitude ?? 0.0);
                              updateLocation(address.city ?? "Unknown");
                            } catch (e) {
                              // Handle exceptions that could come from placemarkFromCoordinates
                              print('Failed to get placemarks: $e');
                            }
                            return;
                          })
                        }
                    });
                updateLocation("Geolocation");
              },
            ),
          ],
          leading: const Icon(Icons.search),
        ),
        bottomNavigationBar: const BottomBar(),
        body: Views(location: location),
      ),
    );
  }
}

class BottomBar extends StatelessWidget {
  const BottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const TabBar(
      tabs: <Widget>[
        Tab(
          icon: Icon(Icons.sunny),
          text: "Currently",
        ),
        Tab(
          icon: Icon(Icons.today),
          text: "Today",
        ),
        Tab(
          icon: Icon(Icons.calendar_month),
          text: "Weekly",
        ),
      ],
    );
  }
}

class Views extends StatelessWidget {
  final String location;

  const Views({super.key, required this.location});

  Widget displayView(String label) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(label),
        Text(location,
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold))
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      children: <Widget>[
        displayView("Currently"),
        displayView("Today"),
        displayView("Weekly"),
      ],
    );
  }
}

class LocationService {
  loc.Location location = loc.Location();

  Future<bool> requestPermission() async {
    final permission = await location.requestPermission();
    return permission == loc.PermissionStatus.granted;
  }

  Future<loc.LocationData> getCurrentLocation() async {
    final serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      final result = await location.requestService;
      if (result == true) {
        print('Service has been enabled');
      } else {
        print('Service has not been enabled');
      }
    }
    final locationData = await location.getLocation();
    return locationData;
  }
}
