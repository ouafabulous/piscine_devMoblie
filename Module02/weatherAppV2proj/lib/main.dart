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
        latitude: json['latitude'] ?? 0.0,
        longitude: json['longitude'] ?? 0.0,
        name: json['name'] ?? "Unknown",
        region: json['admin1'] ?? "",
        country: json['country'] ?? "");
  }
}

class CurrentWeatherData {
  double temperature;
  double windSpeed;

  CurrentWeatherData({required this.temperature, required this.windSpeed});

  factory CurrentWeatherData.fromJson(Map<String, dynamic> json) {
    return CurrentWeatherData(
        temperature: json['temperature_2m'], windSpeed: json['wind_speed_10m']);
  }

  @override
  String toString() {
    return 'CurrentWeatherData{temperature: $temperature, windSpeed: $windSpeed}';
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
    return [];
  }
}

Future<CurrentWeatherData> getWeatherData(LocData locData) async {
  try {
    var url = Uri.parse(
        "https://api.open-meteo.com/v1/forecast?latitude=${locData.latitude}&longitude=${locData.longitude}&current=temperature_2m,weather_code,wind_speed_10m");
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var data = response.body;
      var jsonData = json.decode(data);
      return CurrentWeatherData.fromJson(jsonData['current']);
    } else {
      throw Exception('Failed to load data');
    }
  } catch (e) {
    print("Error: $e");
    return CurrentWeatherData(temperature: 0.0, windSpeed: 0.0);
  }
}

class _HomePageState extends State<HomePage> {
  var location = LocData(
      latitude: 0.0, longitude: 0.0, name: "Unknown", region: "", country: "");
  var currentWeather = CurrentWeatherData(temperature: 0.0, windSpeed: 0.0);
  final TextEditingController _textEditingController = TextEditingController();

  void updateLocation(LocData value) {
    setState(() {
      location = LocData(
          latitude: value.latitude,
          longitude: value.longitude,
          name: value.name,
          region: value.region,
          country: value.country);
      _textEditingController.clear(); // Clear the text field
    });
  }

  void updateCurrentWeather(CurrentWeatherData val) {
    setState(() {
      currentWeather = CurrentWeatherData(
          temperature: val.temperature, windSpeed: val.windSpeed);
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
                    onSubmitted: (value) async {
                      try {
                        var address =
                            await GeoCode().forwardGeocoding(address: value);
                        if (address != null) {
                          var newAddress = await GeoCode().reverseGeocoding(
                              latitude: address.latitude ?? 0.0,
                              longitude: address.longitude ?? 0.0);

                          updateLocation(LocData(
                              latitude: address.latitude ?? 0.0,
                              longitude: address.longitude ?? 0.0,
                              name: newAddress.city ?? "Unknown",
                              region: newAddress.region ?? "",
                              country: newAddress.countryName ?? ""));

                          var weatherData = await getWeatherData(location);
                          updateCurrentWeather(weatherData);
                        }
                      } catch (e) {
                        print(
                            'Failed to process the address or get weather data: $e');
                      }
                    });
              },
              onSelected: (LocData selection) {
                updateLocation(selection);
                getWeatherData(location)
                    .then((value) => updateCurrentWeather(value));
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
                            var lat = locationData.latitude ??
                                0.0; // Default to 0.0 if null
                            var lon = locationData.longitude ??
                                0.0; // Default to 0.0 if null
                            try {
                              var address = await GeoCode().reverseGeocoding(
                                  latitude: lat, longitude: lon);
                              updateLocation(LocData(
                                  latitude: lat,
                                  longitude: lon,
                                  name: address.city ?? "Unknown",
                                  region: address.region ?? "",
                                  country: address.countryName ?? ""));
                              // updateLocation(address.city ?? "Unknown");
                              getWeatherData(location)
                                  .then((value) => updateCurrentWeather(value));
                            } catch (e) {
                              // Handle exceptions that could come from placemarkFromCoordinates
                              print('Failed to get placemarks: $e');
                            }
                            return;
                          })
                        }
                    });
                updateLocation(LocData(
                    latitude: 0.0,
                    longitude: 0.0,
                    name: "Unknow",
                    region: "",
                    country: ""));
              },
            ),
          ],
          leading: const Icon(Icons.search),
        ),
        bottomNavigationBar: const BottomBar(),
        body: Views(location: location, currentWeather: currentWeather),
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
  final LocData location;
  final CurrentWeatherData currentWeather;

  const Views(
      {super.key, required this.location, required this.currentWeather});

  Widget displayView() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(location.name,
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
        Text(location.region),
        Text(location.country),
        Text("${currentWeather.temperature.toString()}°C"),
        Text("${currentWeather.windSpeed.toString()} km/h"),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      children: <Widget>[
        displayView(),
        displayView(),
        displayView(),
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

const Map<int, String> weatherCodes = {
  0: 'Clear sky',
  1: 'Mainly clear',
  2: 'Partly cloudy',
  3: 'Overcast',
  45: 'Fog',
  48: 'Depositing rime fog',
  51: 'Drizzle: Light',
  53: 'Drizzle: Moderate',
  55: 'Drizzle: Dense intensity',
  56: 'Freezing Drizzle: Light',
  57: 'Freezing Drizzle: Dense intensity',
  61: 'Rain: Slight',
  63: 'Rain: Moderate',
  65: 'Rain: Heavy intensity',
  66: 'Freezing Rain: Light',
  67: 'Freezing Rain: Heavy intensity',
  71: 'Snow fall: Slight',
  73: 'Snow fall: Moderate',
  75: 'Snow fall: Heavy intensity',
  77: 'Snow grains',
  80: 'Rain showers: Slight',
  81: 'Rain showers: Moderate',
  82: 'Rain showers: Violent',
  85: 'Snow showers slight',
  86: 'Snow showers heavy',
  95: 'Thunderstorm: Slight or moderate',
  96: 'Thunderstorm with slight hail',
  99: 'Thunderstorm with heavy hail'
};
