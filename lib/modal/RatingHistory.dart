import 'package:ev_tracker/utilities/constants.dart';
import 'package:intl/intl.dart';

class RatingHistoryModel {
  int ratingHistoryId = 0;
  int userId = 0;
  double rating = 0;
  String comment = Constants.Empty;
  int fileId = 0;
  String visitingAddress = Constants.Empty;
  DateTime feedbackOn = DateTime.now();
  String latitude = Constants.Empty;
  String longitude = Constants.Empty;
  String? filePath = Constants.Empty;

  RatingHistoryModel();

  RatingHistoryModel.fromHistory(
      this.ratingHistoryId,
      this.userId,
      this.latitude,
      this.longitude,
      this.rating,
      this.comment,
      this.fileId,
      this.visitingAddress,
      this.feedbackOn,
      this.filePath);

  RatingHistoryModel.fromJson(dynamic json) {
    ratingHistoryId = json["ratingHistoryId"];
    userId = json["userId"];
    latitude = json["latitude"];
    longitude = json["longitude"];
    rating = json["rating"];
    comment = json["comment"];
    if(json["feedbackOn"] != null) {
      var date = DateTime.parse(json["feedbackOn"]);
      feedbackOn = date;
    } else {
      feedbackOn = DateTime.parse("1900-01-01 00:00:00");
    }
    fileId = json["fileId"];
    visitingAddress = json["visitingAddress"];
    filePath = json["filePath"];
  }
}