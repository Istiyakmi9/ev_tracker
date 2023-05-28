import 'package:ev_tracker/modal/appData.dart';
import 'package:ev_tracker/modal/applicationUser.dart';
import 'package:ev_tracker/widgets/CustomAppBar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../modal/settings.dart';

class MapConfiguration extends StatefulWidget {
  const MapConfiguration({Key? key}) : super(key: key);

  @override
  State<MapConfiguration> createState() => _MapConfigurationState();
}

class _MapConfigurationState extends State<MapConfiguration> {
  final _formKey = GlobalKey<FormState>();

  // Ajax ajax = Ajax.getInstance();
  ApplicationUser? _user;
  bool isSaving = false;
  Settings settings = Settings();

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
    Settings settingResult = await Settings.getInstance();

    setState(() {
      _user = user;
      isSaving = false;
      settings = settingResult;
    });
  }

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
                      "Trip Configuration",
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
                          Icons.select_all_outlined,
                          color: Colors.lightBlue,
                        ),
                        title: const Text(
                          "Enable rating option",
                          style: TextStyle(
                            color: Colors.black87,
                          ),
                        ),
                        subtitle: const Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 6,
                          ),
                          child: Text(
                            "Use this option if you want to get a rating option after trip completion.",
                            style: TextStyle(
                              color: Colors.grey,
                            ),
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
                          Icons.feedback,
                          color: Colors.deepOrange,
                        ),
                        title: const Text(
                          "Feed back text limit",
                          style: TextStyle(
                            color: Colors.black87,
                          ),
                        ),
                        subtitle: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 6),
                          child: Text(
                            "Limit feed back text size provided by use after trip completion",
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        trailing: SizedBox(
                          width: 40,
                          child: InkWell(
                            onTap: () {},
                            child: Row(
                              children: const [Icon(Icons.ads_click_outlined)],
                            ),
                          ),
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
                          Icons.storage,
                          color: Colors.indigo,
                        ),
                        title: const Text(
                          "Store rating data",
                          style: TextStyle(
                            color: Colors.black87,
                          ),
                        ),
                        subtitle: const Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 6,
                          ),
                          child: Text(
                            "Keep feed back and rating data for defined number of days.",
                            style: TextStyle(
                              color: Colors.black54,
                            ),
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
                    const SizedBox(
                      height: 20,
                    ),
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
                      child: InkWell(
                        onTap: () {
                          debugPrint("Change default value of google map");
                        },
                        child: ListTile(
                          leading: const Icon(
                            Icons.zoom_in,
                            color: Colors.redAccent,
                          ),
                          title: const Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 8.0,
                            ),
                            child: Text(
                              "Map zoom setting",
                              style: TextStyle(
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          subtitle: const Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 6,
                            ),
                            child: Text(
                              "Tap here to change the default zoom value of google map",
                              style: TextStyle(
                                color: Colors.black54,
                              ),
                            ),
                          ),
                          trailing: SizedBox(
                            width: 40,
                            child: Text(
                              settings.defaultMapZoomValue.toString(),
                            ),
                          ),
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
                        leading: Icon(
                          Icons.filter_tilt_shift,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                        title: const Text(
                          "Map tilt setting",
                          style: TextStyle(
                            color: Colors.black87,
                          ),
                        ),
                        subtitle: const Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 6,
                          ),
                          child: Text(
                            "Provide map camera angle value. Leave this field untouched for default configuration.",
                            style: TextStyle(
                              color: Colors.black54,
                            ),
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
