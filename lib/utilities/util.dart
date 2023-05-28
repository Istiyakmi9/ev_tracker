import 'package:url_launcher/url_launcher.dart';

class Util {
  Util._();

  static Future<void> launchMap(double latitude, double longitude) async {
    Uri googleMapUrl = Uri.parse(
        "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude");

    if (!await launchUrl(googleMapUrl)) {
      throw Exception('Could not launch $googleMapUrl');
    }
  }
}
