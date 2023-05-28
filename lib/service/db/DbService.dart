import 'dart:convert';
import 'dart:io';

import 'package:ev_tracker/modal/applicationUser.dart';
import 'package:get_storage/get_storage.dart';

class DbService {
  final boxName = "currentUser";

  bool addUser(ApplicationUser user) {
    bool flag = false;
    try {
      final box = GetStorage();
      var mapResult = user.toJson();
      box.write(boxName, jsonEncode(mapResult));
      flag = true;
    } on Exception catch (ex) {
      flag = false;
    }

    return flag;
  }

  ApplicationUser? getUser() {
    ApplicationUser? user;
    final box = GetStorage();
    dynamic result = box.read<dynamic>(boxName);
    if (result != null) {
      var mappedData = jsonDecode(result);
      try {
        user = ApplicationUser.fromJson(mappedData);
      } catch (_) {
        deleteUser();
      }
    }

    return user;
  }

  void deleteUser() {
    final box = GetStorage();
    box.remove(boxName);
  }
}
