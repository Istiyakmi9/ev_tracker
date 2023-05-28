import 'dart:io';
import 'dart:typed_data';

import 'package:http_parser/http_parser.dart';
import 'package:ev_tracker/utilities/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Ajax {
  static final Ajax ajax = Ajax._internal();
  Ajax._internal();

  String _baseUrl = "";
  String? _token;

  String get token => _token!;

  set setToken(String value) {
    _token = value;
  }

  static Ajax getInstance() {
    // ajax.setBaseUrl("http://192.168.0.101");
    ajax.setBaseUrl("http://www.wisdomreadinghall.com");
    return ajax;
  }

  void setBaseUrl(String baseUrl) {
    _baseUrl = baseUrl;
  }

  String get getBaseUrl {
    return _baseUrl;
  }

  String get getImageBaseUrl {
    return "$_baseUrl/files/documents";
  }

  Map<String, String> postHeader() {
    return {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      //'Authorization': '<Your token>'
    };
  }

  Map<String, String> imageHeader() {
    return {
      'Content-type': 'multipart/form-data',
      'Accept': 'application/json',
      //'Authorization': '<Your token>'
    };
  }

  dynamic validateResponse(String jsonData) {
    dynamic json = jsonDecode(jsonData);
    try {
      if (json["statusCode"] != 200) {
        json["data"] = Constants.Empty;
      }
      // ignore: empty_catches
    } on Exception catch (e) {
      debugPrint('Exception: + $e');
    }

    return json["data"];
  }

  dynamic validateLoginResponse(String jsonData) {
    dynamic json = jsonDecode(jsonData);
    try {
      if (json["statusCode"] == 200 && json["token"] != "") {
        setToken = json["token"];
        if (_token == null || _token!.isEmpty) {
          throw Exception("Invalid token received.");
        }
      } else {
        throw Exception("User authentication is invalid");
      }
      // ignore: empty_catches
    } on Exception catch (e) {
      rethrow;
    }

    return json["data"];
  }

  dynamic handleResponse(String jsonData) {
    Map<String, dynamic> json = jsonDecode(jsonData);
    try {
      if (json["statusCode"] != 200) {
        throw Exception("Invalid response from server.");
      }
    } on Exception catch (e) {
      rethrow;
    }

    return json["data"];
  }

  Future<dynamic> post(String url, dynamic data) async {
    debugPrint('Url: $getBaseUrl$url, Request: ${json.encode(data)}');
    try {
      var apiUrl = Uri.parse(getBaseUrl + url);
      http.Response response = await http.post(
        apiUrl,
        body: json.encode(data),
        headers: postHeader(),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('Response: ${response.body}');
        return handleResponse(response.body);
      } else {
        debugPrint('Post request failed. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Post request failed. $e');
      return null;
    }
  }

  Future<dynamic> nativeGet(String url) async {
    debugPrint(url);
    var apiUrl = Uri.parse(url);
    http.Response response = await http.get(apiUrl);
    if (response.statusCode == 200 || response.statusCode == 201) {
      // debugPrint('Response: ${response.body}');
      return response.body;
    } else {
      debugPrint('Get request failed: $response');
      return null;
    }
  }

  Future<dynamic> get(String url) async {
    String serverUrl = "$_baseUrl/$url";
    debugPrint(serverUrl);
    var apiUrl = Uri.parse(serverUrl);
    http.Response response = await http.get(apiUrl);
    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint('Get Response: ${response.body}');
      return handleResponse(response.body);
    } else {
      debugPrint('Get request failed: $response');
      return null;
    }
  }

  Future<bool> upload(String url, File? imageFile, dynamic data) async {
    bool flag = false;
    var uri = Uri.parse("$_baseUrl/$url");
    var request = http.MultipartRequest('PUT', uri);
    request.headers.addAll(imageHeader());

    request.fields['user-model'] = jsonEncode(data);
    if (imageFile != null) {
      request.files.add(http.MultipartFile.fromBytes(
          'file', imageFile.readAsBytesSync(),
          filename: imageFile.path));
    } else {
      request.files.add(http.MultipartFile.fromBytes('file', Uint8List(0),
          filename: "nofile"));
    }

    var response = await request.send();
    if (response.statusCode == 200) {
      flag = true;
    }

    return flag;
  }

  Future<bool> uploadVehicle(String url, File? imageFile, dynamic data) async {
    bool flag = false;
    var uri = Uri.parse("$_baseUrl/$url");
    var request = http.MultipartRequest('PUT', uri);
    request.headers.addAll(imageHeader());

    request.fields['vehicleDetail'] = jsonEncode(data);
    if (imageFile != null) {
      request.files.add(http.MultipartFile.fromBytes(
          'file', imageFile.readAsBytesSync(),
          filename: imageFile.path));
    } else {
      request.files.add(http.MultipartFile.fromBytes('file', Uint8List(0),
          filename: "nofile"));
    }

    var response = await request.send();
    if (response.statusCode == 200) {
      flag = true;
    }

    return flag;
  }
}
