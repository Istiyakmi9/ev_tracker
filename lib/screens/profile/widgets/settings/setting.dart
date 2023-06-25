import 'dart:convert';
import 'dart:io';

import 'package:ev_tracker/modal/appData.dart';
import 'package:ev_tracker/modal/SettingPreferences.dart';
import 'package:ev_tracker/screens/profile/widgets/settings/search_setting.dart';
import 'package:ev_tracker/widgets/CustomAppBar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../modal/applicationUser.dart';
import '../../../../service/ajax.dart';

class Setting extends StatefulWidget {
  const Setting({Key? key}) : super(key: key);

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  final _formKey = GlobalKey<FormState>();
  Ajax ajax = Ajax.getInstance();
  ApplicationUser? _user;
  bool isSaving = false;
  SettingPreferences settings = SettingPreferences();

  void showPopup(String msg) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          scrollable: true,
          title: const Text('Map zoom setting'),
          content: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(msg),
                const SizedBox(
                  height: 20,
                ),
                const SizedBox(
                  height: 20,
                ),
                const TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Map zoom value',
                  ),
                )
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              child: const Text("Ok"),
              onPressed: () {
                // your code
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  void _onSubmitted() async {
    _formKey.currentState?.save();
  }

  Future<dynamic> getUserByEmail(String email) async {
    return ajax.get("user/getUserByEmail/$email").then((dynamic value) {
      return value;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      var user = Provider.of<AppData>(context, listen: false).user;
      getStoredConfigurationDetail(user);
    });
  }

  Future<void> getStoredConfigurationDetail(ApplicationUser user) async {
    var pref = await SharedPreferences.getInstance();
    SettingPreferences settingDeStructuredData = SettingPreferences();
    String? data = pref.getString("settingDetail");
    if (data != null) {
      Map<String, dynamic> decodedSettings = jsonDecode(data);
      settingDeStructuredData = SettingPreferences.fromMap(decodedSettings);
      debugPrint("Zoom value: ${settingDeStructuredData.mapZoomValue}");
    }

    setState(() {
      _user = user;
      isSaving = false;
      settings = settingDeStructuredData;
    });
  }

  void showAppInformation() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: _user == null
          ? const Center(child: RefreshProgressIndicator())
          : Container(
              margin: const EdgeInsets.only(
                top: 20,
              ),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Form(
                key: _formKey,
                child: SearchSetting(
                  settings: settings,
                ),
              ),
            ),
    );
  }
}
