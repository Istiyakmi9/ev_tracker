import 'package:ev_tracker/utilities/constants.dart';

class WeatherResult {
  double latitude = 0;
  double longitude = 0;
  double generationTimeMS = 0;
  int utcOffsetSeconds = 0;
  String timezone = Constants.Empty;
  String timezoneAbbreviation = Constants.Empty;
  double elevation = 0;
  CurrentWeather? current_weather;
  HourlyUnits? hourly_units;

  WeatherResult();
  WeatherResult._(
      this.latitude,
      this.longitude,
      this.generationTimeMS,
      this.utcOffsetSeconds,
      this.timezone,
      this.timezoneAbbreviation,
      this.elevation,
      this.current_weather,
      this.hourly_units
      );

  WeatherResult.fromJson(Map<String, dynamic> json) {
    if (json.isNotEmpty) {
      latitude = json["latitude"];
      longitude = json["longitude"];
      generationTimeMS = json["generationtime_ms"];
      utcOffsetSeconds = json["utc_offset_seconds"];
      timezoneAbbreviation = json["timezone_abbreviation"];
      elevation = json["elevation"];
      timezone = json["timezone"];
      current_weather = CurrentWeather.fromJson(json["current_weather"]);
      hourly_units = HourlyUnits.fromJson(json["hourly_units"]);
    }
  }
}


class HourlyUnits {
  String time = Constants.Empty;
  String temperature_2m = Constants.Empty;
  String relativehumidity_2m = Constants.Empty;
  String windspeed_10m = Constants.Empty;

  HourlyUnits();
  HourlyUnits._(
      this.time,
      this.temperature_2m,
      this.relativehumidity_2m,
      this.windspeed_10m
      );
  HourlyUnits.fromJson(Map<String, dynamic> json) {
    if (json.isNotEmpty) {
      time = json["time"];
      temperature_2m = json["temperature_2m"];
      relativehumidity_2m = json["relativehumidity_2m"];
      windspeed_10m = json["windspeed_10m"];
    }
  }
}

class CurrentWeather {
  double temperature = 0;
  double windspeed = 0;
  int winddirection = 0;
  int weathercode = 0;
  int is_day = 0;

  CurrentWeather();
  CurrentWeather._(
      this.temperature,
      this.windspeed,
      this.winddirection,
      this.weathercode,
      this.is_day
      );

  CurrentWeather.fromJson(Map<String, dynamic> json) {
    temperature = json["temperature"];
    windspeed = json["windspeed"];
    winddirection = json["winddirection"];
    weathercode = json["weathercode"];
    is_day = json["is_day"];
  }
}