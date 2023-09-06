import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:ev_tracker/modal/Configuration.dart';
import 'package:ev_tracker/modal/RatingHistory.dart';
import 'package:ev_tracker/modal/SettingPreferences.dart';
import 'package:ev_tracker/modal/appData.dart';
import 'package:ev_tracker/modal/applicationUser.dart';
import 'package:ev_tracker/modal/locationDetail.dart';
import 'package:ev_tracker/service/ajax.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import 'dart:ui' as ui;

import 'package:provider/provider.dart';

class MapIndexPage extends StatefulWidget {
  const MapIndexPage();

  @override
  State<MapIndexPage> createState() => _MapIndexPageState();
}

class _MapIndexPageState extends State<MapIndexPage> {
  Ajax ajax = Ajax.getInstance();
  CameraUpdate? cameraUpdate;
  final Completer<GoogleMapController> _mapController = Completer();
  LocationData? currentLocation;
  BitmapDescriptor? _markerbitmap;
  bool _searchingRoute = false;
  final sourceMarkerId = const MarkerId("Source_marker");
  final destinationMarkerId = const MarkerId("Destination_marker");
  bool _navigationStarted = false;
  bool _isReadyToTrack = false;
  double _distance = 0;
  StreamSubscription<LocationData>? listener;
  bool _gettingLatLng = false;
  Marker? _headerMarker;
  double _tilt = 0;
  double _zoom = 0;
  RatingHistoryModel ratingHistoryModel = RatingHistoryModel();
  late SettingPreferences _settings;
  LocationDetail? locationDetail;
  ApplicationUser? _user;
  bool _isFeedbackSaving = false;

  final _markers = <MarkerId, Marker>{};

  final feedBackController = TextEditingController();

  List<LatLng> polyLineCoordinates = [];

  LatLng Destination = const LatLng(0.0, 0.0);
  LatLng Source = const LatLng(0.0, 0.0);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      var user = Provider.of<AppData>(context, listen: false).user;
      locationDetail =
          ModalRoute.of(context)!.settings.arguments as LocationDetail;
      var sourceLat = locationDetail!.locationData.latitude!;
      var sourceLng = locationDetail!.locationData.longitude!;

      Source = LatLng(sourceLat, sourceLng);
      Destination =
          LatLng(locationDetail!.latitude!, locationDetail!.longitude!);
      buildMapComponents(user);
    });
  }

  @override
  void dispose() {
    super.dispose();

    debugPrint("Dispose method called.");
    if (listener != null) {
      debugPrint("Subscription canceled.");
      listener!.cancel();
    }
  }

  void _submitFeedback() async {
    ratingHistoryModel.latitude = currentLocation!.latitude!.toString();
    ratingHistoryModel.longitude = currentLocation!.longitude!.toString();
    ratingHistoryModel.visitingAddress = locationDetail!.address!;

    if (_settings.isFeedbackIsMandatory &&
        ratingHistoryModel!.comment.isEmpty) {
      Fluttertoast.showToast(msg: "Feedback is mandatory.");
      setState(() {
        _isFeedbackSaving = false;
      });

      return;
    }

    if (ratingHistoryModel!.comment.length > _settings.feedBackTextLimit) {
      Fluttertoast.showToast(
          msg:
              "Feedback message should be less then ${_settings.feedBackTextLimit} character.");
      setState(() {
        _isFeedbackSaving = false;
      });

      return;
    }

    var ratingHistory = {
      "ratingHistoryId": ratingHistoryModel.ratingHistoryId,
      "userId": _user!.userId,
      "rating": ratingHistoryModel.rating,
      "comment": ratingHistoryModel!.comment,
      "fileId": ratingHistoryModel.fileId,
      "visitingAddress": ratingHistoryModel!.visitingAddress,
      "latitude": ratingHistoryModel!.latitude,
      "longitude": ratingHistoryModel!.longitude
    };

    await ajax
        .post("/ratinghistory/addRatingDetail", ratingHistory)
        .then((result) {
      if (result != null) {
        Fluttertoast.showToast(msg: "Your feedback submitted successfully.");
        Navigator.pop(context);
      } else {
        debugPrint(result.toString());
        setState(() {
          _isFeedbackSaving = false;
        });
        Fluttertoast.showToast(msg: "Fail to submit feedback");
      }
    });
  }

  Future<void> getCurrenLocation() async {
    Location location = Location();
    location.changeSettings(
        accuracy: LocationAccuracy.navigation,
        interval: 800,
        distanceFilter: 0);
    var result = await location.getLocation();

    await getPolyPoint(result!.latitude!, result!.longitude!);
    listener = location.onLocationChanged.listen((newLocation) async {
      await getPolyPoint(newLocation.latitude!, newLocation.longitude!);
      await moveCamera(newLocation);
    });

    setState(() {
      currentLocation = result;
      _isReadyToTrack = true;
      _gettingLatLng = true;
      _zoom = 22.0;
      _tilt = 75.0;
    });
  }

  double degreesToRadians(double degrees) {
    return degrees * pi / 180.0;
  }

  double radiansToDegrees(double radians) {
    return radians * 180.0 / pi;
  }

  double calculateHeading(LatLng start, LatLng end) {
    double startLat = degreesToRadians(start.latitude);
    double endLat = degreesToRadians(end.latitude);
    double startLng = degreesToRadians(start.longitude);
    double endLng = degreesToRadians(end.longitude);
    double dLng = endLng - startLng;

    double y = sin(dLng) * cos(endLat);
    double x =
        cos(startLat) * sin(endLat) - sin(startLat) * cos(endLat) * cos(dLng);
    double heading = atan2(y, x);

    return radiansToDegrees(heading);
  }

  // Define a function that calculates the bearing angle between two LatLng objects
  double getBearingAngle(LatLng source, LatLng destination) {
    // LatLng destination = LatLng(Destination.latitude, Destination.longitude);
    double lat1 = source.latitude;
    double lng1 = source.longitude;
    double lat2 = destination.latitude;
    double lng2 = destination.longitude;
    double deltaLng = lng2 - lng1;
    double y = sin(deltaLng) * cos(lat2);
    double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(deltaLng);
    double angle = atan2(y, x);
    return angle * (180 / pi);
  }

  Future<void> moveCamera(LocationData presentLocationData) async {
    if (polyLineCoordinates.isNotEmpty) {
      LatLng source = polyLineCoordinates[0];
      LatLng destination = polyLineCoordinates[1];
      double heading = calculateHeading(
        source,
        destination,
      );

      var bearingAngle = getBearingAngle(source, destination);

      // debugPrint("Camera heading: $heading bearing: $bearingAngle");
      final GoogleMapController controller = await _mapController.future;
      controller.getZoomLevel().then((value) {
        var cameraPosition = CameraPosition(
          target: source,
          tilt: _settings.mapTiltValue,
          zoom: _settings.mapZoomValue,
          // bearing: bearingAngle,
          bearing: heading,
        );

        controller.animateCamera(
          CameraUpdate.newCameraPosition(
            cameraPosition,
          ),
        );

        // _headerMarker = _headerMarker!.copyWith(
        //   rotationParam: bearingAngle,
        //   positionParam: LatLng(
        //     polyLineCoordinates[0].latitude,
        //     polyLineCoordinates[0].longitude,
        //   ),
        //   zIndexParam: 1,
        // );

        var sourceMarker = Marker(
            markerId: sourceMarkerId,
            position: source,
            icon: _markerbitmap!,
            rotation: currentLocation!.heading!,
            draggable: false,
        );

        double distance = calculateDistance(source.latitude!, source.longitude!,
            Destination.latitude, Destination.longitude);

        // _onCameraMove(cameraPosition);

        setState(() {
          currentLocation = presentLocationData;
          _distance = distance;
          _navigationStarted = true;
          _markers[sourceMarkerId] = sourceMarker;
        });

        debugPrint("$distance");
        if(distance < 0.3) {
          if (listener != null) {
            listener!.cancel();
          }
          // Navigator.pop(context);

          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) {
              return FractionallySizedBox(
                heightFactor: 0.8,
                child: ratingWidget(),
              );
            },
          ).whenComplete(() {
            Navigator.pop(context);
          });
        }
      });
    }
  }

  Future<void> getPolyPoint(double latitude, double longitude) async {
    PolylinePoints polylinePoints = PolylinePoints();
    polyLineCoordinates = [];
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      Configuration.googleKey,
      PointLatLng(latitude, longitude),
      PointLatLng(Destination.latitude, Destination.longitude),
      travelMode: TravelMode.driving,
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polyLineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
      debugPrint(
          "Lat: ${result.points[0].latitude}, Lng: ${result.points[0].longitude}");
    } else {
      debugPrint("----------------   No routes found ---------------");
      debugPrint(result.errorMessage);
    }
  }

  void buildMapComponents(ApplicationUser user) async {
    _settings = await SettingPreferences.getSettingDetail();

    final Uint8List? markerIcon =
        await getBytesFromAsset("assets/images/pulsating_map_icon.png", 150);
    var markerBitMap = BitmapDescriptor.fromBytes(markerIcon!);

    double distance = calculateDistance(Source.latitude!, Source.longitude!,
        Destination.latitude, Destination.longitude);
    //
    // final markers = getMapMarker(Source, Destination, markerBitMap);

    var sourceMarker = Marker(
      markerId: sourceMarkerId,
      position: Source,
      icon: markerBitMap,
    );

    var destinationMarker = Marker(
      markerId: const MarkerId("Destination"),
      position: Destination,
    );

    setState(() {
      currentLocation = null;
      _markers[sourceMarkerId] = sourceMarker;
      _markers[destinationMarkerId] = destinationMarker;
      _distance = distance;
      _isReadyToTrack = true;
      _markerbitmap = markerBitMap;
      _gettingLatLng = false;
      _zoom = 16.0;
      _tilt = 0.0;
      _navigationStarted = false;
      _searchingRoute = false;
      _user = user;
    });
  }

  Future<Uint8List?> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))
        ?.buffer
        .asUint8List();
  }

  updateLocationDetail() {
    getCurrenLocation().then((_) {
      Navigator.pop(context);
    });
  }

  LatLng getCurrentLocationLatLng() {
    if (polyLineCoordinates.isNotEmpty) {
      return LatLng(polyLineCoordinates[0]!.latitude!,
          polyLineCoordinates[0]!.longitude!);
    }

    return LatLng(currentLocation!.latitude!, currentLocation!.longitude!);
  }

  Future<dynamic> getBottomSheet() async {
    return showModalBottomSheet(
        context: context,
        isDismissible: false,
        enableDrag: false,
        builder: (context) {
          return Container(
            padding: const EdgeInsets.symmetric(
              vertical: 40,
              horizontal: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text("Your destination is Near petrol pump."),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.navigation_rounded),
                      onPressed: () {
                        updateLocationDetail();
                      },
                      label: const Text("Direction"),
                    ),
                    _gettingLatLng
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: RefreshProgressIndicator(),
                          )
                        : Text("$Source"),
                  ],
                )
              ],
            ),
          );
        });
  }

  Map<MarkerId, Marker> getMapMarker(
      LatLng source, LatLng destination, BitmapDescriptor bitmap) {
    Map<MarkerId, Marker> mapMarker = <MarkerId, Marker>{};

    mapMarker[sourceMarkerId] = Marker(
      markerId: sourceMarkerId,
      position: source,
      icon: bitmap,
    );

    mapMarker[sourceMarkerId] = Marker(
      markerId: const MarkerId("Destination"),
      position: destination,
    );

    return mapMarker;
  }

  GoogleMap getMap() {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(Source.latitude, Source.longitude),
        zoom: _zoom,
        bearing: 0,
      ),
      rotateGesturesEnabled: true,
      zoomControlsEnabled: true,
      zoomGesturesEnabled: true,
      scrollGesturesEnabled: true,
      compassEnabled: true,
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.10),
      onMapCreated: (GoogleMapController controller) {
        _mapController.complete(controller);
        // _mapController!.animateCamera(cameraUpdate!);
      },
      markers: _markers.values.toSet(),
      polylines: {
        Polyline(
          polylineId: const PolylineId("route"),
          color: Colors.blueAccent,
          points: polyLineCoordinates,
          width: 6,
        )
      },
    );
  }

  StreamBuilder<List<Marker>> getStreamMap() {
    return StreamBuilder<List<Marker>>(
        stream: null,
        builder: (context, snapshot) {
          return GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(Source.latitude, Source.longitude),
              zoom: _zoom,
              bearing: 0,
            ),
            rotateGesturesEnabled: true,
            zoomControlsEnabled: true,
            zoomGesturesEnabled: true,
            scrollGesturesEnabled: true,
            compassEnabled: true,
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height * 0.10),
            onMapCreated: (GoogleMapController controller) {
              _mapController.complete(controller);
              // _mapController!.animateCamera(cameraUpdate!);
            },
            markers: _markers.values.toSet(),
            polylines: {
              Polyline(
                polylineId: const PolylineId("route"),
                color: Colors.blueAccent,
                points: polyLineCoordinates,
                width: 6,
              )
            },
          );
        });
  }

  Widget buildBody() {
    if (currentLocation == null) {
      if (!_isReadyToTrack) {
        return const Center(child: RefreshProgressIndicator());
      } else {
        return getMap();
        // return getStreamMap();
      }
    } else {
      // return getStreamMap();
      return getMap();
    }
  }

  double calculateDistance(sourceLat, sourceLng, destLat, destLng) {
    var p = 0.017453292519943295;
    var a = 0.5 -
        cos((destLat - sourceLat) * p) / 2 +
        cos(sourceLat * p) *
            cos(destLat * p) *
            (1 - cos((destLng - sourceLng) * p)) /
            2;
    return 12742 * asin(sqrt(a));
  }

  Widget ratingWidget() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 30,
        ),
        margin: const EdgeInsets.symmetric(
          vertical: 20,
        ),
        child: Column(
          children: [
            RatingBar.builder(
              initialRating: 1,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                debugPrint("Rating: $rating");
                ratingHistoryModel.rating = rating;
              },
            ),
            const SizedBox(
              height: 20,
            ),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Share more about your experience",
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(
                top: 8,
              ),
              child: TextField(
                maxLines: 4,
                maxLength: _settings!.feedBackTextLimit,
                keyboardType: TextInputType.text,
                controller: feedBackController,
                onChanged: (value) {
                  ratingHistoryModel.comment = value;
                },
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Your comments here"),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                  ),
                  child: const Text("Close"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isFeedbackSaving = true;
                    });
                    _submitFeedback();
                  },
                  child: _isFeedbackSaving
                      ? Row(
                          children: const [
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text("Saving..."),
                          ],
                        )
                      : const Text("Save & Exit"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget mapFooter() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),
        height: 100,
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            !_navigationStarted
                ? ElevatedButton.icon(
                    icon: _searchingRoute
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.black,
                            ),
                          )
                        : const Icon(
                            Icons.play_arrow,
                          ),
                    onPressed: () {
                      debugPrint("Map zoom value: ${_settings!.mapZoomValue}");
                      debugPrint("Map zoom value: ${_settings!.mapTiltValue}");
                      setState(() {
                        _searchingRoute = true;
                        _zoom = _settings!.mapZoomValue;
                      });

                      getCurrenLocation().then((value) {
                        setState(() {
                          _navigationStarted = true;
                        });
                      });
                    },
                    label: const Text("Start"),
                  )
                : Expanded(
                    flex: 1,
                    child: InkWell(
                      onTap: () {
                        if (listener != null) {
                          listener!.cancel();
                        }
                        // Navigator.pop(context);

                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) {
                            return FractionallySizedBox(
                              heightFactor: 0.8,
                              child: ratingWidget(),
                            );
                          },
                        ).whenComplete(() {
                          Navigator.pop(context);
                        });
                      },
                      child: SizedBox(
                        height: 25,
                        width: 25,
                        child: Image.asset("assets/images/close.png"),
                      ),
                    ),
                  ),
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.only(
                  left: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${_distance.toStringAsFixed(2)} KM",
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 30,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Text(
                      "is remaining.",
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void startNavigation() {
    setState(() {
      _navigationStarted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Map page"),
      ),
      body: Stack(
        children: [
          buildBody(),
          mapFooter(),
        ],
      ),
    );
  }
}
