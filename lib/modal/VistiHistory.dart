import 'package:intl/intl.dart';

import '../utilities/constants.dart';

class VisitHistory {
  String placeName = Constants.Empty;
  String fullAddress = Constants.Empty;
  DateTime visitedOn = DateTime.now();
  int visitHostoryId = 0;
  int userId = 0;
  String latitude = Constants.Empty;
  String longitude = Constants.Empty;
  String time = Constants.Empty;

  VisitHistory.fromHistory(this.visitHostoryId,
      this.userId,
      this.latitude,
      this.longitude,
      this.placeName,
      this.fullAddress,
      this.visitedOn,
      this.time);

  VisitHistory.fromJson(dynamic json) {
    visitHostoryId = json["visitHistoryId"];
    userId = json["userId"];
    latitude = json["latitude"];
    longitude = json["longitude"];
    placeName = json["placeName"];
    fullAddress = json["fullAddress"];
    if(json["visitedOn"] != null) {
      var date = DateTime.parse(json["visitedOn"]);
      visitedOn = date;
      time = DateFormat("HH:mm").format(date);
    } else {
      visitedOn = DateTime.parse("1900-01-01 00:00:00");
      time = "00:00";
    }
  }
}