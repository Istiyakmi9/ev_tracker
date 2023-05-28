import 'package:location/location.dart';

class LocationDetail {
  LocationData locationData;
  double? latitude;
  double? longitude;

  LocationDetail({
    required this.locationData,
    required this.latitude,
    required this.longitude
  });
}