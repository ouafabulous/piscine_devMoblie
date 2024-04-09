import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocode/geocode.dart';
import 'package:location/location.dart' as loc;
import 'package:http/http.dart' as http;

import 'types.dart';
import 'views.dart';

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

Future<CurrentWeatherData> getCurrentWeatherData(LocData locData) async {
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

Future<TodayWeatherData> getTodayWeatherData(LocData locData) async {
  try {
    var url = Uri.parse(
        "https://api.open-meteo.com/v1/forecast?latitude=${locData.latitude}&longitude=${locData.longitude}&hourly=weather_code,temperature_2m,wind_speed_10m&forecast_days=1");
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var data = response.body;
      var jsonData = json.decode(data);
      return TodayWeatherData.fromJson(jsonData['hourly']);
    } else {
      throw Exception('Failed to load data');
    }
  } catch (e) {
    print("Error: $e");
    return TodayWeatherData(timestamps: [], temperatures: [], windSpeeds: [], weatherCodes: []);
  }
}

Future<WeeklyWeatherData> getWeeklyWeatherData(LocData locData) async {
  try {
    var url = Uri.parse(
        "https://api.open-meteo.com/v1/forecast?latitude=${locData.latitude}&longitude=${locData.longitude}&daily=weather_code,temperature_2m_max,temperature_2m_min&timezone=auto");
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var data = response.body;
      var jsonData = json.decode(data);
      return WeeklyWeatherData.fromJson(jsonData['daily']);
    } else {
      throw Exception('Failed to load data');
    }
  } catch (e) {
    print("Error: $e");
    return WeeklyWeatherData(
        timestamps: [],
        minTemperatures: [],
        maxTemperatures: [],
        weatherCodes: []);
  }
}

class _HomePageState extends State<HomePage> {
  var location = LocData(
      latitude: 0.0, longitude: 0.0, name: "Unknown", region: "", country: "");
  var currentWeather = CurrentWeatherData(temperature: 0.0, windSpeed: 0.0);
  var todayWeather =
      TodayWeatherData(timestamps: [], temperatures: [], windSpeeds: [], weatherCodes: []);
  var weeklyWeather = WeeklyWeatherData(
      timestamps: [],
      minTemperatures: [],
      maxTemperatures: [],
      weatherCodes: []);
  final TextEditingController _textEditingController = TextEditingController();
  String errorMessage = "";

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

  void updateTodayWeather(TodayWeatherData val) {
    setState(() {
      todayWeather = TodayWeatherData(
          timestamps: val.timestamps,
          temperatures: val.temperatures,
          windSpeeds: val.windSpeeds,
          weatherCodes: val.weatherCodes);
    });
  }

  void updateWeeklyWeather(WeeklyWeatherData val) {
    setState(() {
      weeklyWeather = WeeklyWeatherData(
          timestamps: val.timestamps,
          minTemperatures: val.minTemperatures,
          maxTemperatures: val.maxTemperatures,
          weatherCodes: val.weatherCodes);
    });
  }

  void updateErrorMessage(String message) {
    setState(() {
      errorMessage = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
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
                          if (newAddress.timezone == "Throttled! See geocode.xyz/pricing"){
                            updateErrorMessage(ErrorMessages.getServiceLostError());
                            return;
                          }
                          updateLocation(LocData(
                              latitude: address.latitude ?? 0.0,
                              longitude: address.longitude ?? 0.0,
                              name: newAddress.city ?? "Unknown",
                              region: newAddress.region ?? "",
                              country: newAddress.countryName ?? ""));
                          if (errorMessage.isNotEmpty) {
                            updateErrorMessage("");
                          }
                          var currentWeatherData =
                              await getCurrentWeatherData(location);
                          var todayWeatherData =
                              await getTodayWeatherData(location);
                          var weeklyWeatherData =
                              await getWeeklyWeatherData(location);
                          updateCurrentWeather(currentWeatherData);
                          updateTodayWeather(todayWeatherData);
                          updateWeeklyWeather(weeklyWeatherData);
                        }
                      } catch (e) {
                        updateErrorMessage(
                            ErrorMessages.getAddressNotFoundError());
                      }
                    });
              },
              onSelected: (LocData selection) {
                updateLocation(selection);
                if (errorMessage.isNotEmpty) {
                  updateErrorMessage("");
                }
                getCurrentWeatherData(location)
                    .then((value) => updateCurrentWeather(value));
                getTodayWeatherData(location)
                    .then((value) => updateTodayWeather(value));
                getWeeklyWeatherData(location)
                    .then((value) => updateWeeklyWeather(value));
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
                              if (errorMessage.isNotEmpty) {
                                updateErrorMessage("");
                              }
                              getCurrentWeatherData(location)
                                  .then((value) => updateCurrentWeather(value));
                              getTodayWeatherData(location)
                                  .then((value) => updateTodayWeather(value));
                              getWeeklyWeatherData(location)
                                  .then((value) => updateWeeklyWeather(value));
                            } catch (e) {
                              print('Failed to get placemarks: $e');
                            }
                            return;
                          })
                        }
                      else
                        {
                          updateErrorMessage(
                              ErrorMessages.getGeolocationNotEnabledError())
                        }
                    });
                updateLocation(LocData(
                    latitude: 0.0,
                    longitude: 0.0,
                    name: "Unknown",
                    region: "",
                    country: ""));
              },
            ),
          ],
          leading: const Icon(Icons.search),
        ),
        bottomNavigationBar: const BottomBar(),
        body: Views(
          location: location,
          currentWeather: currentWeather,
          todayWeather: todayWeather,
          weeklyWeather: weeklyWeather,
          errorMessage: errorMessage,
        ),
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
