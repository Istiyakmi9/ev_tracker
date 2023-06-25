import 'package:ev_tracker/modal/appData.dart';
import 'package:ev_tracker/modal/applicationUser.dart';
import 'package:ev_tracker/widgets/CustomAppBar.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../../modal/SettingPreferences.dart';

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
  SettingPreferences? _settings;
  final _commonTextField = TextEditingController();

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
      isSaving = false;
      _settings = settingResult;
    });
  }

  void _saveChanges() {
    if (_settings!.defaultSearchKey.isEmpty) {
      Fluttertoast.showToast(msg: "Search key should not be empty");
      return;
    }

    if (_settings!.mapZoomValue <= 0) {
      Fluttertoast.showToast(msg: "Map zoom value should be greater then 0.");
      return;
    }

    if (_settings!.mapTiltValue <= 0) {
      Fluttertoast.showToast(msg: "Map tilt value should be greater then 0.");
      return;
    }

    if (_settings!.feedBackTextLimit <= 0) {
      Fluttertoast.showToast(
          msg: "Feedback text limit must be greater then 50 character.");
      return;
    }

    SettingPreferences.update(_settings!);
    Fluttertoast.showToast(msg: "Data stored successfully.");
  }

  void _changeDarkModeOption(bool flag) {
    _settings!.enableDarkTeam = flag;

    setState(() {
      _settings = _settings;
    });
  }

  void showPopup(String heading, String msg, ItemType itemType) {
    bool isNumericType = false;
    switch (itemType) {
      case ItemType.FeedbackTextLimit:
        isNumericType = true;
        break;
      case ItemType.FeedbackRatingDuration:
        isNumericType = true;
        break;
      case ItemType.MapZoomSetting:
        isNumericType = true;
        break;
      case ItemType.MapTiltSetting:
        isNumericType = true;
        break;
      case ItemType.SearchKey:
        isNumericType = false;
        break;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          scrollable: true,
          title: Text(heading),
          content: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(msg),
                const SizedBox(
                  height: 20,
                ),
                TextField(
                  onChanged: (text) {
                    try {
                      switch (itemType) {
                        case ItemType.FeedbackTextLimit:
                          _settings!.feedBackTextLimit = int.parse(text);
                          isNumericType = true;
                          break;
                        case ItemType.FeedbackRatingDuration:
                          _settings!.durationForRatingInDays = int.parse(text);
                          isNumericType = true;
                          break;
                        case ItemType.MapZoomSetting:
                          _settings!.mapZoomValue = double.parse(text);
                          isNumericType = true;
                          break;
                        case ItemType.MapTiltSetting:
                          _settings!.mapTiltValue = double.parse(text);
                          isNumericType = true;
                          break;
                        case ItemType.SearchKey:
                          _settings!.defaultSearchKey = text;
                          isNumericType = false;
                          break;
                      }
                    } on Exception {
                      debugPrint("Invalid input");
                    }

                    setState(() {
                      _settings = _settings;
                    });
                  },
                  controller: _commonTextField,
                  decoration: const InputDecoration(hintText: "Type here..."),
                  keyboardType:
                      isNumericType ? TextInputType.number : TextInputType.text,
                )
              ],
            ),
          ),
          actions: [
            ElevatedButton(
                onPressed: () {
                  // your code
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                ),
                child: const Text("Cancel")),
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
                          value: _settings!.enableRatingOption,
                          // changes the state of the switch
                          onChanged: (value) {
                            _settings!.enableRatingOption = value;
                            setState(() {});
                          },
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    InkWell(
                      onTap: () {
                        _commonTextField.text =
                            _settings!.feedBackTextLimit.toString();
                        showPopup(
                            "Feedback text limit.",
                            "Set feedback text limit after the completion of your trip. "
                                "Note: This option is only valid if rating & feedback option is enabled.",
                            ItemType.FeedbackTextLimit);
                      },
                      child: Container(
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
                            "Feedback text limit",
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
                          trailing: Column(
                            children: [
                              const Icon(
                                Icons.text_fields,
                                color: Colors.deepOrange,
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Text(
                                "${_settings!.feedBackTextLimit}",
                                style: const TextStyle(
                                  color: Colors.deepOrange,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    InkWell(
                      onTap: () {
                        _commonTextField.text =
                            _settings!.durationForRatingInDays.toString();
                        showPopup(
                            "Feedback & rating storage.",
                            "Set feedback & rating storage duration in days."
                                "Note: This option is only valid if rating & feedback option is enabled.",
                            ItemType.FeedbackRatingDuration);
                      },
                      child: Container(
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
                          trailing: Column(
                            children: [
                              const Icon(
                                Icons.store,
                                color: Colors.indigo,
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Text(
                                "${_settings!.durationForRatingInDays}",
                                style: const TextStyle(
                                  color: Colors.indigo,
                                ),
                              ),
                            ],
                          ),
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
                          _commonTextField.text = _settings!.defaultSearchKey;
                          showPopup(
                              "Default search key",
                              "Set default search key used for the application.",
                              ItemType.SearchKey);
                        },
                        child: ListTile(
                          leading: const Icon(
                            Icons.location_searching,
                            color: Colors.blueAccent,
                          ),
                          title: const Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 8.0,
                            ),
                            child: Text(
                              "Map search key",
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
                              "Tap to set search key used by default for your google map.",
                              style: TextStyle(
                                color: Colors.black54,
                              ),
                            ),
                          ),
                          trailing: Column(
                            children: [
                              const Icon(
                                Icons.key,
                                color: Colors.blueAccent,
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              SizedBox(
                                width: 60,
                                child: Text(
                                  _settings!.defaultSearchKey,
                                  style: const TextStyle(
                                    color: Colors.blueAccent,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
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
                      child: InkWell(
                        onTap: () {
                          _commonTextField.text =
                              _settings!.mapZoomValue.toString();
                          showPopup(
                              "Map zoom setting",
                              "Set default zoom value for the google map.",
                              ItemType.MapZoomSetting);
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
                          trailing: Column(
                            children: [
                              const Icon(
                                Icons.map,
                                color: Colors.redAccent,
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Text(
                                "${_settings!.mapZoomValue}",
                                style: const TextStyle(
                                  color: Colors.redAccent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    InkWell(
                      onTap: () {
                        _commonTextField.text =
                            _settings!.mapTiltValue.toString();
                        showPopup(
                            "Map tilt setting",
                            "Set default tilt value for the google map.",
                            ItemType.MapTiltSetting);
                      },
                      child: Container(
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
                          trailing: Column(
                            children: [
                              Icon(
                                Icons.location_searching_rounded,
                                color:
                                    Theme.of(context).colorScheme.onBackground,
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Text(
                                "${_settings!.mapTiltValue}",
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shadowColor: Colors.greenAccent,
                        elevation: 3,
                      ),
                      onPressed: _saveChanges,
                      child: const Text("Save changes"),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

enum ItemType {
  FeedbackTextLimit,
  FeedbackRatingDuration,
  MapZoomSetting,
  MapTiltSetting,
  SearchKey
}
