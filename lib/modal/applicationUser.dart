import 'dart:io';

import 'package:ev_tracker/utilities/constants.dart';
import 'package:intl/intl.dart';

class ApplicationUser {
  int userId = 0;
  String firstName = Constants.Empty;
  String lastName = Constants.Empty;
  String password = Constants.Empty;
  String confirmPassword = Constants.Empty;
  DateTime dob = DateTime.now();
  String mobile = Constants.Empty;
  String email = Constants.Empty;
  String firstAddress = Constants.Empty;
  String secondAddress = Constants.Empty;
  String state = Constants.Empty;
  String city = Constants.Empty;
  String country = Constants.Empty;
  String imageURL = Constants.Empty;
  String accessToken = Constants.Empty;
  String? filePath;
  String fullName = Constants.Empty;
  ApplicationUser();

  ApplicationUser.fromUser(
      this.userId,
      this.firstName,
      this.lastName,
      this.dob,
      this.mobile,
      this.email,
      this.firstAddress,
      this.secondAddress,
      this.state,
      this.city,
      this.country,
      this.filePath);

  static Future<ApplicationUser> getUser() async {
    // Db db = Db();
    dynamic userData = null; //await db.getUser();
    return ApplicationUser.fromJson(userData);
  }

  factory ApplicationUser.fromJson(dynamic json) {
    ApplicationUser user;
    try {
      user = ApplicationUser.fromUser(
          json["userId"],
          json["firstName"],
          json["lastName"],
          DateTime.parse(json["dob"]),
          json["mobile"],
          json["email"],
          json["firstAddress"],
          json["secondAddress"],
          json["state"],
          json["city"],
          json["country"],
          json["filePath"]);
    } catch (_) {
      user = ApplicationUser();
    }

    return user;
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'mobile': mobile,
        'firstAddress': firstAddress,
        'dob': DateFormat('yyyy-MM-dd HH:mm:ss').format(dob),
        'secondAddress': secondAddress,
        'state': state,
        'city': city,
        'country': country,
        'imageURL': imageURL,
        'accessToken': accessToken,
        'filePath': filePath
      };
}
