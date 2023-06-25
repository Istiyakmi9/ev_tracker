import 'dart:convert';

import 'package:ev_tracker/utilities/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingPreferences {
  bool enableMapTracing = false;
  bool enableDarkTeam = false;
  int historyExpiredInDays = 0;
  bool isFeedbackIsMandatory = false;

  bool enableRatingOption = false;
  int feedBackTextLimit = 0;
  int durationForRatingInDays = 0;

  double mapZoomValue = 0;
  double mapTiltValue = 0;

  String defaultSearchKey = Constants.Empty;

  SettingPreferences() {
    feedBackTextLimit = 100;
    mapZoomValue = 22.0;
    mapTiltValue = 75.0;
    enableMapTracing = false;
    enableDarkTeam = false;
    historyExpiredInDays = 10;
    isFeedbackIsMandatory = false;
    enableRatingOption = false;
    defaultSearchKey = "petrol pump stations";
  }

  static Future<SettingPreferences> getSettingDetail() async {
    var pref = await SharedPreferences.getInstance();
    late SettingPreferences settings;
    String? data = pref.getString("settingDetail");
    if (data != null) {
      Map<String, dynamic> decodedSettings = jsonDecode(data);
      settings = SettingPreferences.fromMap(decodedSettings);
      // debugPrint("Zoom value: ${settingDeStructuredData.defaultMapZoomValue}");
    } else {
      settings = SettingPreferences();
    }

    return settings;
  }

  static void cleanSetting() async {
    var pref = await SharedPreferences.getInstance();
    pref.remove("settingDetail");
  }

  static Future<bool> update(SettingPreferences settings) async {
    bool flag = false;
    var pref = await SharedPreferences.getInstance();
    Map<String, dynamic> mapSettingData = settings.toMap();
    String result = jsonEncode(mapSettingData);
    if(result.isNotEmpty) {
      pref.setString("settingDetail", result);
      flag = true;
    }

    return flag;
  }

  SettingPreferences.fromMap(Map<String, dynamic> map) {
    enableMapTracing = map["enableMapTracing"];
    enableDarkTeam = map["enableDarkTeam"];
    mapZoomValue = map["mapZoomValue"];
    historyExpiredInDays = map["historyExpiredInDays"];
    defaultSearchKey = map["defaultSearchKey"];

    enableRatingOption = map["enableRatingOption"];
    feedBackTextLimit = map["feedBackTextLimit"];
    durationForRatingInDays = map["durationForRatingInDays"];
    mapTiltValue = map["mapTiltValue"];
  }

  Map<String, dynamic> toMap() {
    return {
      "enableMapTracing": enableMapTracing,
      "enableDarkTeam": enableDarkTeam,
      "mapZoomValue": mapZoomValue,
      "historyExpiredInDays": historyExpiredInDays,
      "defaultSearchKey": defaultSearchKey,
      "enableRatingOption": enableRatingOption,
      "feedBackTextLimit": feedBackTextLimit,
      "durationForRatingInDays": durationForRatingInDays,
      "mapTiltValue": mapTiltValue
    };
  }
}
