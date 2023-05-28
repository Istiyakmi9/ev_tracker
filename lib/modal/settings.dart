import 'dart:convert';

import 'package:ev_tracker/utilities/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  bool enableMapTracing = false;
  bool enableDarkTeam = false;
  int defaultMapZoomValue = 0;
  int historyExpiredInDays = 0;
  String defaultSearchValue = Constants.Empty;

  Settings();

  static Future<Settings> getInstance() async {
    var pref = await SharedPreferences.getInstance();
    Settings settings = Settings();
    String? data = pref.getString("settingDetail");
    if (data != null) {
      Map<String, dynamic> decodedSettings = jsonDecode(data);
      settings = Settings.fromMap(decodedSettings);
      // debugPrint("Zoom value: ${settingDeStructuredData.defaultMapZoomValue}");
    }

    return settings;
  }

  static Future<bool> update(Settings settings) async {
    bool flag = false;
    var pref = await SharedPreferences.getInstance();
    if (settings.defaultMapZoomValue > 0) {
      Map<String, dynamic> mapSettingData = settings.toMap();
      String result = jsonEncode(mapSettingData);
      if(result.isNotEmpty) {
        pref.setString("settingDetail", result);
        flag = true;
      }
    }

    return flag;
  }

  Settings.fromMap(Map<String, dynamic> map) {
    enableMapTracing = map["enableMapTracing"];
    enableDarkTeam = map["enableDarkTeam"];
    defaultMapZoomValue = map["defaultMapZoomValue"];
    historyExpiredInDays = map["historyExpiredInDays"];
    defaultSearchValue = map["defaultSearchValue"];
  }

  Map<String, dynamic> toMap() {
    return {
      "enableMapTracing": enableMapTracing,
      "enableDarkTeam": enableDarkTeam,
      "defaultMapZoomValue": defaultMapZoomValue,
      "historyExpiredInDays": historyExpiredInDays,
      "defaultSearchValue": defaultSearchValue,
    };
  }
}
