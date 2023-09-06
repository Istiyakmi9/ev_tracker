import 'dart:convert';
import 'dart:ui';

import 'package:ev_tracker/modal/Configuration.dart';
import 'package:ev_tracker/modal/locationDetail.dart';
import 'package:ev_tracker/service/ajax.dart';
import 'package:ev_tracker/utilities/NavigationPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../../modal/SearchLocations.dart';

class NearestStations extends StatefulWidget {
  String searchKey;

  NearestStations({Key? key, required this.searchKey}) : super(key: key);

  @override
  State<NearestStations> createState() => _NearestStationsState();
}

class _NearestStationsState extends State<NearestStations> {
  Ajax ajax = Ajax.getInstance();
  List<Results> searchResults = [];
  Location currentLocation = Location();
  late LocationData locationData;
  final searchKeyController = TextEditingController();
  String? searchKey;
  bool resultStatus = false;
  Results? selectedSearch;

  Future _loadNearByStations(String key) async {
    locationData = await currentLocation.getLocation();
    PermissionStatus permissionGranted;
    bool serviceEnabled;

    serviceEnabled = await currentLocation.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await currentLocation.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await currentLocation.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await currentLocation.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    try {
      debugPrint("Inside function");
      await currentLocation.getLocation().then((value) {
        debugPrint(value.latitude.toString());
      });
      debugPrint("Done");
    } on PlatformException catch (e) {
      debugPrint(e.code);
    }

    debugPrint(
        "Latitude: ${locationData.latitude}, Longitude: ${locationData.longitude}");

    // locations = SearchLocations(results: <Results>[], status: "ok");

    debugPrint("Key: $key");
    await ajax
        .nativeGet(
            "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location="
            "${locationData.latitude},${locationData.longitude}"
            "&radius=5000"
            "&type=all"
            "&keyword=$key"
            "&key=${Configuration.googleKey}")
        .then((result) {
      if (result != null) {
        SearchLocations locations =
            SearchLocations.fromJson(jsonDecode(result));
        debugPrint("${locations.status}");
        if (locations.status?.toLowerCase() != "ok") {
          locations = SearchLocations();
          locations.results = [];
        }

        setState(() {
          searchResults = locations.results!;
          resultStatus = true;
          searchKey = key;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();

    if (widget.searchKey.isNotEmpty) {
      searchKey = widget.searchKey;
    } else {
      searchKey = "petrol pump";
    }

    // var data = Provider.of<List<String>>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await _loadNearByStations(searchKey!);
    });
  }

  void _openMapPage(int index) async {
    var destination = searchResults[index];
    // String googleMapslocationUrl = "https://www.google.com/maps/search/?api=1&query=${destination.geometry!.location!.lat},${destination.geometry!.location!.lng}";
    // if (!await launchUrlString(googleMapslocationUrl)) {
    //   throw Exception('Could not launch $googleMapslocationUrl');
    // }

    Navigator.of(context).pushNamed(
      // NavigationPage.MapIndexPage,
      NavigationPage.MapIndexPage,
      arguments: LocationDetail(
        locationData: locationData,
        latitude: destination.geometry!.location!.lat,
        longitude: destination.geometry!.location!.lng,
        address: selectedSearch!.vicinity,
      ),
    );
  }

  void _reLoadDataWithRefreshKey() async {
    setState(() {
      searchResults = [];
      resultStatus = false;
    });

    await _loadNearByStations(searchKeyController.value.text);
  }

  Widget getFilterWidget() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
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
    );
  }

  Widget filterResult() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        getFilterWidget(),
        searchResults.isEmpty
            ? Container(
                margin: const EdgeInsets.only(
                  top: 100,
                ),
                child: const Text("No result found"),
              )
            : Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: ListView.builder(
                    itemCount: searchResults!.length,
                    itemBuilder: (ctx, index) {
                      return Card(
                        child: ListTile(
                          onTap: () {
                            selectedSearch = searchResults[index];
                            _openMapPage(index);
                          },
                          leading: Container(
                            margin: const EdgeInsets.symmetric(
                              vertical: 4,
                            ),
                            child: SizedBox(
                              width: 60,
                              height: 60,
                              child: Configuration.getImage(
                                  searchResults[index].icon!),
                            ),
                          ),
                          title: Text(
                            searchResults[index].name!,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          subtitle: Text(searchResults[index].vicinity!),
                          trailing: IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.person_pin_circle,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
      ],
    );
  }

  Widget renderPage() {
    if (resultStatus) {
      return filterResult();
    } else {
      return Container(
        margin: const EdgeInsets.only(
          top: 100,
        ),
        alignment: Alignment.center,
        child: const RefreshProgressIndicator(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return renderPage();
  }
}
