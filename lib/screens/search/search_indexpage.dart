import 'package:ev_tracker/modal/SettingPreferences.dart';
import 'package:ev_tracker/screens/search/widgets/nearestStations.dart';
import 'package:flutter/material.dart';

class SearchIndexPage extends StatefulWidget {
  SearchIndexPage({super.key});

  @override
  State<SearchIndexPage> createState() => _SearchIndexPageState();
}

class _SearchIndexPageState extends State<SearchIndexPage> {
  final searchKeyController = TextEditingController();
  String? searchKey;
  late SettingPreferences _settings;

  @override
  void initState() {
    super.initState();
    loadNearestStations();
  }

  Future loadNearestStations() async {
    _settings = await SettingPreferences.getSettingDetail();
  }

  void _filterByKey() {
    debugPrint(_settings.defaultSearchKey);
    setState(() {
      searchKey = _settings.defaultSearchKey;
    });
  }

  void _reLoadDataWithRefreshKey() {
    if (searchKeyController.value.text.isNotEmpty) {
      setState(() {
        searchKey = searchKeyController.value.text;
      });
    } else {
      debugPrint("Please enter your search key.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return searchKey != null
        ? NearestStations(
            searchKey: searchKey!,
          )
        : SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  child: Container(
                    color: Colors.white,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            style: const TextStyle(),
                            decoration: const InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.cyan,
                                  width: 1.0,
                                ),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.cyan,
                                ),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 10,
                              ),
                              prefixIcon: Icon(Icons.location_searching),
                              hintText: "Enter search key",
                            ),
                            controller: searchKeyController,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            _reLoadDataWithRefreshKey();
                          },
                          icon: const Icon(Icons.search),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 100,
                ),
                Image.asset("assets/images/charging.png"),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 25,
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    "Click on below button to locate nearest Electric vehicle charging station.",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _filterByKey,
                  label: Text(
                    "Search electric vehicle station",
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSecondary),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.onBackground,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                  ),
                  icon: Icon(
                    Icons.location_searching_rounded,
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                ),
              ],
            ),
          );
  }
}
