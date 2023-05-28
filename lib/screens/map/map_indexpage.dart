import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:ev_tracker/modal/Configuration.dart';
import 'package:ev_tracker/modal/locationDetail.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
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
  final Map<String, Marker> _markers = {};
  CameraUpdate? cameraUpdate;
  final Completer<GoogleMapController> _mapController = Completer();
  late List<Marker> _markerList = <Marker>[];
  LocationData? currentLocation;
  BitmapDescriptor? _markerbitmap;
  bool _searchingRoute = false;
  bool _navigationStarted = false;
  double cameraZoomValue = 16.0;
  bool _isReadyToTrack = false;
  double _distance = 0;
  StreamSubscription<LocationData>? listener;
  bool _gettingLatLng = false;
  Marker? _headerMarker;
  double _tilt = 0;
  double _zoom = 0;

  List<LatLng> polyLineCoordinates = [];

  LatLng Destination = const LatLng(0.0, 0.0);
  LatLng Source = const LatLng(0.0, 0.0);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      var result = ModalRoute.of(context)!.settings.arguments as LocationDetail;
      var sourceLat = result.locationData.latitude!;
      var sourceLng = result.locationData.longitude!;

      Source = LatLng(sourceLat, sourceLng);
      Destination = LatLng(result.latitude!, result.longitude!);
      buildMapComponents();
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

  Future<void> getCurrenLocation() async {
    Location location = Location();
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

  double degreesToRadians(double degrees) {
    return degrees * pi / 180.0;
  }

  double radiansToDegrees(double radians) {
    return radians * 180.0 / pi;
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

  void _onCameraMove(CameraPosition position) {
    double heading = calculateHeading(
      polyLineCoordinates[0],
      polyLineCoordinates[1],
    );

    debugPrint("Marker heading: $heading");
    _headerMarker = _headerMarker!.copyWith(
      rotationParam: heading,
      positionParam: LatLng(
        polyLineCoordinates[0].latitude,
        polyLineCoordinates[0].longitude,
      ),
    );
  }

  Future<void> moveCamera(LocationData presentLocationData) async {
    if (polyLineCoordinates.isNotEmpty) {
      LatLng source = polyLineCoordinates[0];
      LatLng destination = polyLineCoordinates[1];
      double heading = calculateHeading(
        source,
        destination,
      );

      var bearingAngle = getBearingAngle(
          source,
          destination
      );

      debugPrint("Camera heading: $heading bearing: $bearingAngle");
      final GoogleMapController controller = await _mapController.future;
      controller.getZoomLevel().then((value) {
        if (_zoom == 22) {
          var cameraPosition = CameraPosition(
            target: source,
            tilt: _tilt,
            zoom: _zoom,
            // bearing: bearingAngle,
            bearing: heading,
          );

          controller.animateCamera(
            CameraUpdate.newCameraPosition(
              cameraPosition,
            ),
          );

          _headerMarker = _headerMarker!.copyWith(
            rotationParam: bearingAngle,
            positionParam: LatLng(
              polyLineCoordinates[0].latitude,
              polyLineCoordinates[0].longitude,
            ),
            zIndexParam: 1
          );

          double distance = calculateDistance(
              source.latitude!,
              source.longitude!,
              Destination.latitude,
              Destination.longitude);

          // _onCameraMove(cameraPosition);

          setState(() {
            currentLocation = presentLocationData;
            _distance = distance;
            _navigationStarted = true;
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
        // debugPrint("Lat: ${point.latitude}, Lng: ${point.longitude}");
        polyLineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    } else {
      debugPrint("----------------   No routes found ---------------");
      debugPrint(result.errorMessage);
    }
  }

  void buildMapComponents() async {
    final Uint8List? markerIcon =
        await getBytesFromAsset("assets/images/navigation.png", 150);
    var markerBitMap = BitmapDescriptor.fromBytes(markerIcon!);

    _headerMarker = Marker(
      markerId: const MarkerId("Source head"),
      icon: markerBitMap,
      position: LatLng(Source.latitude, Source.longitude),
    );

    double distance = calculateDistance(Source.latitude!, Source.longitude!,
        Destination.latitude, Destination.longitude);
    // getBottomSheet();

    setState(() {
      currentLocation = null;
      _distance = distance;
      _isReadyToTrack = true;
      _markerbitmap = markerBitMap;
      _gettingLatLng = false;
      _zoom = 16.0;
      _tilt = 0.0;
      _navigationStarted = false;
      _searchingRoute = false;
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

  Set<Marker> getMapMarker(bool isLiveMarker) {
    Set<Marker> mapMarker;
    if (isLiveMarker) {
      mapMarker = {
        _headerMarker!,
        // Marker(
        //   markerId: const MarkerId("Source"),
        //   position: polyLineCoordinates[0]!,
        //   icon: _markerbitmap!,
        //   infoWindow: const InfoWindow(
        //       title: "Bada Bazaar", snippet: "Bada Bazaar Asansol Market"),
        // ),
        Marker(
          markerId: const MarkerId("Destination"),
          position: Destination!,
          infoWindow: const InfoWindow(
              title: "Bada Bazaar", snippet: "Bada Bazaar Asansol Market"),
        )
      };
    } else {
      mapMarker = {_headerMarker!};
    }

    return mapMarker;
  }

  GoogleMap getMap(bool isLiveMarker) {
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
      markers: getMapMarker(isLiveMarker),
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

  Widget buildBody() {
    if (currentLocation == null) {
      if (!_isReadyToTrack) {
        return const Center(child: RefreshProgressIndicator());
      } else {
        return getMap(false);
      }
    } else {
      return getMap(true);
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
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                          ),
                    onPressed: () {
                      setState(() {
                        _searchingRoute = true;
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
                        Navigator.pop(context);
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
