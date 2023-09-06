import 'package:ev_tracker/modal/WeatherResult.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';

import '../../../service/ajax.dart';

class CarInformation extends StatefulWidget {
  CarInformation({Key? key}) : super(key: key);

  @override
  State<CarInformation> createState() => _CarInformationState();
}

class _CarInformationState extends State<CarInformation> {
  final ajax = Ajax.getInstance();
  late WeatherResult weatherResult = WeatherResult();
  late LocationData locationData;
  Location currentLocation = Location();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await enableGPSGetWeatherDetail();
    });
  }

  void initDefaultValue() {
    debugPrint("Call back method invoked");
  }

  Future<void> enableGPSGetWeatherDetail() async {
    try {
      // enable GPS
      var future = Future.delayed(const Duration(seconds: 10));
      var subscription = future.asStream().listen((event) {
        initDefaultValue();
      });

      locationData = await currentLocation.getLocation();
      PermissionStatus permissionGranted;
      bool serviceEnabled;
      subscription.cancel();

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

      await _loadWeatherDetail(locationData);
    } on Exception catch (_) {
      debugPrint("Fail to enable GPS");
    }
  }

  Future<void> _loadWeatherDetail(LocationData locationData) async {
    await ajax
        .getByURL("https://api.open-meteo.com/v1/forecast?latitude="
            "${locationData.latitude}"
            "&longitude="
            "${locationData.longitude}"
            "&current_weather=true&hourly=temperature_2m,relativehumidity_2m,windspeed_10m")
        .then((value) {
      if (value != null) {
        var result = WeatherResult.fromJson(value);
        setState(() {
          weatherResult = result;
        });
      } else {
        debugPrint("Fail to get weather data");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(
              top: 10,
              bottom: 16,
            ),
            width: double.infinity,
            child: const Text(
              "Today's Weather",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.wind_power_sharp,
                        color: Colors.green,
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      if (weatherResult.current_weather == null)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: Text("0.0km/h"),
                        )
                      else
                        Text(
                          "${weatherResult?.current_weather?.windspeed}"
                          "${weatherResult?.hourly_units?.windspeed_10m}",
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text("Wind speed")
                ],
              ),
              Column(
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.thermostat_outlined,
                        color: Colors.redAccent,
                      ),
                      if (weatherResult.current_weather == null)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: Text("0.0" + "\u2103"),
                        )
                      else
                        Text(
                          "${weatherResult?.current_weather?.temperature}"
                          "${weatherResult?.hourly_units?.temperature_2m}",
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text("Temperature")
                ],
              ),
              Column(
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.water_drop,
                        color: Colors.blue,
                      ),
                      if (weatherResult.current_weather == null)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(),
                        )
                      else
                        Text(
                          "${weatherResult?.current_weather?.windspeed}"
                          "${weatherResult?.hourly_units?.relativehumidity_2m}",
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text("Humidity")
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}
