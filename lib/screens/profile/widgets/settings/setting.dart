import 'dart:convert';
import 'dart:io';

import 'package:ev_tracker/modal/appData.dart';
import 'package:ev_tracker/modal/settings.dart';
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
  Settings settings = Settings();

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
    Settings settingDeStructuredData = Settings();
    String? data = pref.getString("settingDetail");
    if (data != null) {
      Map<String, dynamic> decodedSettings = jsonDecode(data);
      settingDeStructuredData = Settings.fromMap(decodedSettings);
      debugPrint("Zoom value: ${settingDeStructuredData.defaultMapZoomValue}");
    }

    setState(() {
      _user = user;
      isSaving = false;
      settings = settingDeStructuredData;
    });
  }

  void showAppInformation() {}

  void _changeDarkModeOption(bool flag) {
    settings.enableDarkTeam = flag;

    setState(() {
      settings = settings;
    });
  }

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
                child: ListView(
                  children: [
                    const Text(
                      "Map Setting",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.blueGrey,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      color: Colors.white,
                      margin: const EdgeInsets.only(
                        bottom: 2,
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.map_rounded,
                          color: Colors.lightBlue,
                        ),
                        title: const Text(
                          "Use default google map for tracing",
                          style: TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                        trailing: Switch(
                          // thumb color (round icon)
                          activeColor: Colors.amber,
                          activeTrackColor: Colors.cyan,
                          inactiveThumbColor: Colors.blueGrey.shade600,
                          inactiveTrackColor: Colors.grey.shade400,
                          splashRadius: 50.0,
                          // boolean variable value
                          value: settings.enableMapTracing,
                          // changes the state of the switch
                          onChanged: (value) {},
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      color: Colors.white,
                      margin: const EdgeInsets.only(
                        bottom: 2,
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.nights_stay_sharp,
                          color: Colors.indigo,
                        ),
                        title: const Text(
                          "Enable dark mode",
                          style: TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                        trailing: Switch(
                          // thumb color (round icon)
                          activeColor: Colors.amber,
                          activeTrackColor: Colors.cyan,
                          inactiveThumbColor: Colors.blueGrey.shade600,
                          inactiveTrackColor: Colors.grey.shade400,
                          splashRadius: 50.0,
                          // boolean variable value
                          value: settings.enableDarkTeam,
                          // changes the state of the switch
                          onChanged: (value) {
                            _changeDarkModeOption(value);
                          },
                        ),
                      ),
                    ),
                    Container(
                      color: Colors.white,
                      margin: const EdgeInsets.only(
                        bottom: 2,
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.numbers,
                          color: Colors.deepOrange,
                        ),
                        title: const Text(
                          "Map camera zoom value",
                          style: TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                        trailing: SizedBox(
                          width: 40,
                          child: InkWell(
                            onTap: () {
                              showPopup("Set up map zoom value, This value will be used as default for zooming the map.");
                            },
                            child: Row(
                              children: const [
                                Text(
                                  "5",
                                  style: TextStyle(
                                    color: Colors.grey,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                Icon(Icons.ads_click)
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    SearchSetting(settings: settings,),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      "Privacy & Policy",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.blueGrey,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      color: Colors.white,
                      margin: const EdgeInsets.only(
                        bottom: 2,
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.info_outline),
                        title: InkWell(
                          onTap: () {
                            showPopup("Show app information");
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 8.0,
                            ),
                            child: Text(
                              "About this application, application information will display all the necessary data to handle or manage the app.",
                              style: TextStyle(
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      color: Colors.white,
                      margin: const EdgeInsets.only(
                        bottom: 2,
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.numbers),
                        title: const Text(
                          "Map camera zoom value",
                          style: TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                        trailing: Switch(
                          // thumb color (round icon)
                          activeColor: Colors.amber,
                          activeTrackColor: Colors.cyan,
                          inactiveThumbColor: Colors.blueGrey.shade600,
                          inactiveTrackColor: Colors.grey.shade400,
                          splashRadius: 50.0,
                          // boolean variable value
                          value: true,
                          // changes the state of the switch
                          onChanged: (value) {},
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
