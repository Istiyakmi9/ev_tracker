import 'package:ev_tracker/modal/applicationUser.dart';
import 'package:flutter/material.dart';

class AppData extends ChangeNotifier {
  ApplicationUser user = ApplicationUser();

  void updateUser(ApplicationUser user) {
    this.user = user;
    notifyListeners();
  }
}