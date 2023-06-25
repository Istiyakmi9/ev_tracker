import 'dart:convert';
import 'dart:ui';

import 'package:ev_tracker/modal/Configuration.dart';
import 'package:ev_tracker/modal/locationDetail.dart';
import 'package:ev_tracker/service/ajax.dart';
import 'package:ev_tracker/utilities/NavigationPage.dart';
import 'package:ev_tracker/widgets/CustomAppBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import '../../../modal/SearchLocations.dart';

class NearestServicing extends StatefulWidget {
  NearestServicing({Key? key}) : super(key: key);

  @override
  State<NearestServicing> createState() => NearestServicingState();
}

class NearestServicingState extends State<NearestServicing> {
  Ajax ajax = Ajax.getInstance();
  List<Results> searchResults = [];
  Location currentLocation = Location();
  late LocationData locationData;
  final searchKeyController = TextEditingController();
  String searchKey = "car service center";
  bool resultStatus = false;

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
            "&radius=5000&type=all&"
            "keyword=$key"
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

    if (searchKey.isNotEmpty) {
      searchKey = searchKey;
    } else {
      searchKey = "petrol pump";
    }

    // var data = Provider.of<List<String>>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await _loadNearByStations(searchKey);
    });
  }

  void _openMapPage(int index) {
    var destination = searchResults[index];
    Navigator.of(context).pushNamed(
      NavigationPage.MapIndexPage,
      arguments: LocationDetail(
        locationData: locationData,
        latitude: destination.geometry!.location!.lat,
        longitude: destination.geometry!.location!.lng,
        address: null,
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

  Widget filterResult() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: ListView.builder(
              itemCount: searchResults.length,
              itemBuilder: (ctx, index) {
                return Card(
                  child: ListTile(
                    onTap: () {
                      _openMapPage(index);
                    },
                    leading: SizedBox(
                      width: 60,
                      height: 60,
                      child: Configuration.getImage(searchResults[index].icon!),
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
                    trailing: const IconButton(
                      onPressed: null,
                      icon: Icon(Icons.person_pin_circle),
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
      if (searchResults.isEmpty) {
        return const Center(
          child: Text("No result found"),
        );
      } else {
        return filterResult();
      }
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
    return Scaffold(
      appBar: const CustomAppBar(),
      body: renderPage(),
    );
  }
}
