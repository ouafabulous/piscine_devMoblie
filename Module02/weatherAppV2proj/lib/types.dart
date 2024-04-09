class ErrorMessages {
  
  static String getGeolocationNotEnabledError() {
    return "Geolocation is not enabled, please enable it in your App settings";
  }
  
  static String getAddressNotFoundError() {
    return "Could not find any result for the supplied address or coordinates";
  }

  static String getServiceLostError() {
    return "The service connection is lost, please check your internet connection or try again";
  }
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
    var cd = CurrentWeatherData(
        temperature: json['temperature_2m'], windSpeed: json['wind_speed_10m']);
  return cd;
  }

  @override
  String toString() {
    return 'CurrentWeatherData{temperature: $temperature, windSpeed: $windSpeed}';
  }
}

class TodayWeatherData {
  List<String> timestamps;
  List<dynamic> temperatures;
  List<dynamic> windSpeeds;
  List<dynamic> weatherCodes;

  TodayWeatherData({
    required this.timestamps,
    required this.temperatures,
    required this.windSpeeds,
    required this.weatherCodes,
  });

  factory TodayWeatherData.fromJson(Map<String, dynamic> json) {
    // Convert the dynamic list to a List<String> for timestamps.
    var timestamps = List<String>.from(json['time'] ?? []);

    // Convert the dynamic list to a List<double> for temperatures.
    // Use .map to cast each element to a double, which works if the values are num, int, or double already.
    var temperatures = (json['temperature_2m'] as List<dynamic>)
        .map((e) => e.toDouble())
        .toList();

    // Convert the dynamic list to a List<double> for windSpeeds.
    var windSpeeds = (json['wind_speed_10m'] as List<dynamic>)
        .map((e) => e.toDouble())
        .toList();

    var weatherCodes = (json['weather_code'] as List<dynamic>);

    return TodayWeatherData(
      timestamps: timestamps,
      temperatures: temperatures,
      windSpeeds: windSpeeds,
      weatherCodes: weatherCodes,
    );
  }

  @override
  String toString() {
    return 'TodayWeatherData{timestamps: $timestamps, temperatures: $temperatures, windSpeeds: $windSpeeds}';
  }
}

class WeeklyWeatherData {
  List<String> timestamps;
  List<dynamic> minTemperatures;
  List<dynamic> maxTemperatures;
  List<dynamic> weatherCodes;

  WeeklyWeatherData({
    required this.timestamps,
    required this.minTemperatures,
    required this.maxTemperatures,
    required this.weatherCodes,
  });

  factory WeeklyWeatherData.fromJson(Map<String, dynamic> json) {
    // Convert the dynamic list to a List<String> for timestamps.
    var timestamps = List<String>.from(json['time'] ?? []);

    // Convert the dynamic list to a List<double> for minTemperatures.
    var minTemperatures = (json['temperature_2m_min'] as List<dynamic>)
        .map((e) => e.toDouble())
        .toList();

    // Convert the dynamic list to a List<double> for maxTemperatures.
    var maxTemperatures = (json['temperature_2m_max'] as List<dynamic>)
        .map((e) => e.toDouble())
        .toList();

    var weatherCodes = (json['weather_code'] as List<dynamic>)
        .map((e) => e.toInt())
        .toList();

    return WeeklyWeatherData(
      timestamps: timestamps,
      minTemperatures: minTemperatures,
      maxTemperatures: maxTemperatures,
      weatherCodes: weatherCodes,
    );
  }
}
