import 'package:flutter/material.dart';
import 'const.dart';
import 'types.dart';


class Views extends StatelessWidget {
  final LocData location;
  final CurrentWeatherData currentWeather;
  final TodayWeatherData todayWeather;
  final WeeklyWeatherData weeklyWeather;
  final errorMessage;

  const Views(
      {super.key,
      required this.location,
      required this.currentWeather,
      required this.todayWeather, 
      required this.weeklyWeather,
      required this.errorMessage});

  String formatTimeStampToHour(String timestamp) {
    // Timestamp format: 2024-04-08T00:00
    // return only the hour and minute part
    return timestamp.substring(11, 16);
  }

  Widget displayCurrentView() {
    return Center(
      child: errorMessage.length > 0
        ? Text(errorMessage, style: const TextStyle(fontSize: 15, color: Colors.red))
        : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(location.name,
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
        Text(location.region),
        Text(location.country),
        Text("${currentWeather.temperature.toString()}°C"),
        Text("${currentWeather.windSpeed.toString()} km/h"),
      ]),
    );
  }

  Widget displayTodayView() {
    return errorMessage.length > 0
        ? Center(child: Text(errorMessage, style: const TextStyle(fontSize: 15, color: Colors.red)))
        : 
    SingleChildScrollView(
        scrollDirection: Axis.vertical,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(location.name,
                style:
                    const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
            Text(location.region),
            Text(location.country),
            // display the temperature and wind speed for every hour of the day
            for (int i = 0; i < todayWeather.temperatures.length; i++)
              Text(
                  "${formatTimeStampToHour(todayWeather.timestamps[i])}    ${todayWeather.temperatures[i].toString()}°C    ${weatherCodes[todayWeather.weatherCodes[i]]}    ${todayWeather.windSpeeds[i].toString()} km/h"),
          ]),
        ));
  }

  Widget displayWeeklyView() {
    return errorMessage.length > 0
        ? Center(child: Text(errorMessage, style: const TextStyle(fontSize: 15, color: Colors.red)))
        : 
    SingleChildScrollView(
        scrollDirection: Axis.vertical,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(location.name,
                style:
                    const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
            Text(location.region),
            Text(location.country),
            // display the temperature and wind speed for every hour of the day
            for (int i = 0; i < weeklyWeather.minTemperatures.length; i++)
              Text(
                  "${(weeklyWeather.timestamps[i])}    ${weeklyWeather.minTemperatures[i].toString()}°C    ${weeklyWeather.maxTemperatures[i].toString()}°C   ${weatherCodes[weeklyWeather.weatherCodes[i]]}"),
          ]),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      children: <Widget>[
        displayCurrentView(),
        displayTodayView(),
        displayWeeklyView()
      ],
    );
  }
}