import 'package:flutter/material.dart';
import 'const.dart';
import 'types.dart';


class Views extends StatelessWidget {
  final LocData location;
  final CurrentWeatherData currentWeather;
  final TodayWeatherData todayWeather;
  final WeeklyWeatherData weeklyWeather;

  const Views(
      {super.key,
      required this.location,
      required this.currentWeather,
      required this.todayWeather, 
      required this.weeklyWeather});

  String formatTimeStampToHour(String timestamp) {
    // Timestamp format: 2024-04-08T00:00
    // return only the hour and minute part
    return timestamp.substring(11, 16);
  }

  Widget displayCurrentView() {
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

  Widget displayTodayView() {
    return SingleChildScrollView(
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
                  "${formatTimeStampToHour(todayWeather.timestamps[i])}    ${todayWeather.temperatures[i].toString()}°C    ${todayWeather.windSpeeds[i].toString()} km/h"),
          ]),
        ));
  }

  Widget displayWeeklyView() {
    return SingleChildScrollView(
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