import 'package:flutter/material.dart';

import '../../../service/ajax.dart';

class CarInformation extends StatefulWidget {
  CarInformation({Key? key}) : super(key: key);

  @override
  State<CarInformation> createState() => _CarInformationState();
}

class _CarInformationState extends State<CarInformation> {
  @override
  void initState() {
    super.initState();
  }

  final ajax = Ajax.getInstance();

  void loadWeatherDetail() {
    ajax.get("https://api.open-meteo.com/v1/forecast?latitude=23.692716&longitude=86.977147&current_weather=true&hourly=temperature_2m,relativehumidity_2m,windspeed_10m")
        .then((value) {
      if(value != null) {

      } else {

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
              "Today's Wheather",
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
                    children: const [
                      Icon(
                        Icons.wind_power_sharp,
                        color: Colors.green,
                      ),
                      SizedBox(
                        width: 4,
                      ),
                      Text(
                        "87%",
                        style: TextStyle(
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
                    children: const [
                      Icon(
                        Icons.thermostat_outlined,
                        color: Colors.redAccent,
                      ),
                      Text(
                        "25",
                        style: TextStyle(
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
                    children: const [
                      Icon(
                        Icons.water_drop,
                        color: Colors.blue,
                      ),
                      Text(
                        "69%",
                        style: TextStyle(
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
