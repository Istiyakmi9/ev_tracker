import 'package:ev_tracker/utilities/constants.dart';

class Vehicle {
  int vehicleId = 0;
  String vehicleNo = Constants.Empty;
  String brandName = Constants.Empty;
  String make = Constants.Empty;
  String model = Constants.Empty;
  String varient = Constants.Empty;
  String vehicleType = Constants.Empty;
  String series = Constants.Empty;
  int userId = 0;
  String? filePath = Constants.Empty;

  Vehicle();

  Vehicle.fromUser(
      this.vehicleId,
      this.vehicleNo,
      this.brandName,
      this.make,
      this.model,
      this.varient,
      this.vehicleType,
      this.series,
      this.userId,
      this.filePath);

  factory Vehicle.fromJson(dynamic json) {
    Vehicle user;
    try {
      user = Vehicle.fromUser(
          json["vehicleId"],
          json["vehicleNo"],
          json["brandName"],
          json["make"],
          json["model"],
          json["varient"],
          json["vehicleType"],
          json["series"],
          json["userId"],
          json["filePath"]);
    } catch (_) {
      user = Vehicle();
    }

    return user;
  }

  Map<String, dynamic> toJson() => {
        'vehicleId': vehicleId,
        'vehicleNo': vehicleNo,
        'brandName': brandName,
        'make': make,
        'model': model,
        'varient': varient,
        'vehicleType': vehicleType,
        'series': series,
        'userId': userId,
        'filePath': filePath
      };
}
