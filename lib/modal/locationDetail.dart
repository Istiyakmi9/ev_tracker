import 'package:location/location.dart';

class LocationDetail {
  LocationData locationData;
  double? latitude;
  double? longitude;
  String? address;

  LocationDetail({
    required this.locationData,
    required this.latitude,
    required this.longitude,
    required this.address
  });
}