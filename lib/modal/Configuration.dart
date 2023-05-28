import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class Configuration {
  static double height = 0;
  static double width = 0;
  static bool isAndroid = true;
  static double _pagePadding = 18;
  static double fieldGap = 12;

  static String mapBoxAccessToken = "";
  static String mapBoxStyleId = "https://api.mapbox.com/styles/v1/mdistiyak/clh4fek6e00ns01qu7qnq87af/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoibWRpc3RpeWFrIiwiYSI6ImNsaDNmcHA2ajFtOG4zZ3BqYjNxdjdyb2cifQ.GNeqcfmdG-6RnxKuL6PvCg";

  // Account used: bottomhalf.mi9@gmail.com
  // Project name in GCP: My Map Project
  static String googleKey = "AIzaSyAp4VUzqYprG9bUq__hpOzFgIWyH6L5Ulo";
  static const String defaultImgUrl = "assets/images/profile.png";

  static void setPagePadding(double value) {
    _pagePadding = value;
  }

  static double get pagePadding => _pagePadding;

  static Color colorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    if (hexColor.length == 8) {
      return Color(int.parse("0x$hexColor"));
    } else {
      return Colors.black;
    }
  }

  static bool isValidEmail(String email) {
    bool emailValid = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
    return emailValid;
  }

  static String replaceToNotNull(dynamic value) {
    String returnValue = "NA";
    if (value != null && value != "") {
      returnValue = value.toString().trim();
    }
    return returnValue;
  }

  static Widget getImage(String imageUrl) {
    CachedNetworkImage image;
    try {
      if (imageUrl != "") {
        image = CachedNetworkImage(
          imageUrl: imageUrl,
          imageBuilder: (context, imageProvider) => Container(
            width: 150.0,
            height: 150.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                  image: imageProvider, fit: BoxFit.cover),
            ),
          ),
          progressIndicatorBuilder: (context, url, downloadProgress) =>
              CircularProgressIndicator(
            value: downloadProgress.progress,
          ),
          errorWidget: (context, url, error) {
            return const Icon(
              Icons.error_sharp,
              color: Colors.redAccent,
            );
          },
        );
        return image;
      } else {
        return Image.network(
          "https://static.thenounproject.com/png/4381137-200.png",
          fit: BoxFit.fill,
        );
      }
    } catch (e) {
      return Image.network(
        "https://static.thenounproject.com/png/4381137-200.png",
        fit: BoxFit.fill,
      );
    }
  }
}
