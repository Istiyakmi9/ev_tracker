import 'package:ev_tracker/modal/SettingPreferences.dart';
import 'package:ev_tracker/modal/appData.dart';
import 'package:ev_tracker/modal/applicationUser.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class SearchSetting extends StatefulWidget {
  late SettingPreferences settings;

  SearchSetting({super.key, required settings});

  @override
  State<SearchSetting> createState() => _SearchSettingState();
}

class _SearchSettingState extends State<SearchSetting> {
  final _formKey = GlobalKey<FormState>();
  SettingPreferences? _settings;
  ApplicationUser? _user;
  bool _isReady = false;

  final autoSavePassword =
      "Once you login to the system and if your auto-save setting is "
      "enabled, then this application will save your user credential "
      "to the life time of this application. There only two "
      "possibilities are there under which this save detail will "
      "be erased.";

  void _onSubmitted() async {
    _formKey.currentState?.save();
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
    SettingPreferences settingResult =
        await SettingPreferences.getSettingDetail();

    setState(() {
      _user = user;
      _isReady = true;
      _settings = settingResult;
    });
  }

  void _saveChanges() {
    SettingPreferences.update(_settings!);
    Fluttertoast.showToast(msg: "Data stored successfully.");
  }

  Widget autSavePasswordInstruction() {
    return Column(
      children: [
        Text(
          autoSavePassword,
          style: const TextStyle(
            fontSize: 14,
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: const [
            Icon(
              Icons.double_arrow,
            ),
            SizedBox(
              width: 250,
              child: Text("If you logout from the current system by using logout button "
                  "from right top corner, then your entire detail will be removed."),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: const [
            Icon(
              Icons.double_arrow,
            ),
            SizedBox(
              width: 250,
              child: Text("If you logout from the current system by using logout button "
                  "from right top corner, then your entire detail will be removed.",
              ),
            ),
          ],
        ),
      ],
    );
  }

  void showPopup(String msg, String text, bool fieldFlag) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          scrollable: true,
          title: Text(msg),
          content: Padding(
            padding: const EdgeInsets.all(8.0),
            child: !fieldFlag
                ? autSavePasswordInstruction()
                : Column(
                    children: [
                      Text(
                        text,
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const TextField(
                        obscureText: true,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Search text',
                        ),
                      ),
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

  @override
  Widget build(BuildContext context) {
    return !_isReady
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "System settings",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.blueGrey,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              InkWell(
                onTap: () {
                  showPopup(
                      "Auto save password guide", autoSavePassword, false);
                },
                child: Container(
                  color: Colors.white,
                  margin: const EdgeInsets.only(
                    bottom: 2,
                  ),
                  child: ListTile(
                    leading: Icon(Icons.info_outline),
                    title: const Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 8.0,
                      ),
                      child: Text(
                        "Auto save password instruction.",
                        style: TextStyle(
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8.0,
                      ),
                      child: Text(
                        autoSavePassword,
                        style: const TextStyle(
                          overflow: TextOverflow.ellipsis,
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
                child: const ListTile(
                  leading: Icon(Icons.history),
                  title: Text(
                    "About application",
                    style: TextStyle(
                      color: Colors.black54,
                    ),
                  ),
                  subtitle: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 8.0,
                    ),
                    child: Text("about saving password"),
                  ),
                ),
              ),
              Container(
                color: Colors.white,
                padding: const EdgeInsets.only(
                  top: 4,
                  bottom: 8,
                ),
                margin: const EdgeInsets.only(
                  bottom: 2,
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.integration_instructions,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      title: const Text(
                        "User guide line to use the application.",
                        style: TextStyle(
                          color: Colors.black54,
                        ),
                      ),
                      trailing: IconButton(
                        onPressed: () {
                          showPopup(
                              "Default search text used for current application is",
                              "Electric vehicle charging station near me",
                              false);
                        },
                        icon:
                            const Icon(Icons.keyboard_double_arrow_right_sharp),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                color: Colors.white,
                padding: const EdgeInsets.only(
                  top: 4,
                  bottom: 8,
                ),
                margin: const EdgeInsets.only(
                  bottom: 2,
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.map_sharp),
                      title: const Text(
                        "Enable map tracing.",
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
                        value: _settings!.enableMapTracing,
                        // changes the state of the switch
                        onChanged: (value) {
                          _settings!.enableMapTracing = value;
                          setState(() {});
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.all(20),
                child: Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shadowColor: Colors.greenAccent,
                      elevation: 3,
                    ),
                    onPressed: _saveChanges,
                    child: const Text("Save changes"),
                  ),
                ),
              )
            ],
          );
  }
}
