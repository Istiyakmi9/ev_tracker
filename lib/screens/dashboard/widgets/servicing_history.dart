import 'package:ev_tracker/utilities/NavigationPage.dart';
import 'package:flutter/material.dart';

class ServicingHistory extends StatelessWidget {
  ServicingHistory({Key? key}) : super(key: key);

  List<dynamic> stations = [
    {
      "StationName": "ABC Station",
      "Address": "123 adams colony, Hyderabad",
      "VisitedOn": "16th Feb, 2023",
      "Time": "10:45 AM"
    },
    {
      "StationName": "Manikonda station",
      "Address": "#12/90 Manikonda colony, Hyderabad",
      "VisitedOn": "02nd Feb, 2023",
      "Time": "2:00 PM"
    },
    {
      "StationName": "Kondapur",
      "Address": "Twin tower kondapur road no. 12, Hyderabad",
      "VisitedOn": "23rd Jan, 2023",
      "Time": "9:00 PM"
    },
    {
      "StationName": "Miyapur",
      "Address": "Adams colony safinagar miyapur, Hyderabad",
      "VisitedOn": "18th Jan, 2023",
      "Time": "7:30 PM"
    }
  ];

  Widget _getStationList() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: stations.length,
      prototypeItem: ListTile(
        title: Text(stations.first["StationName"]),
      ),
      itemBuilder: (ctx, index) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              const SizedBox(
                width: 60,
                child: Icon(Icons.local_gas_station),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stations[index]["StationName"],
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(
                    width: 160,
                    child: Text(
                      stations[index]["Address"],
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  )
                ],
              ),
            ]),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  stations[index]["Time"],
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                Text(
                  stations[index]["VisitedOn"],
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                )
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),
      margin: const EdgeInsets.symmetric(
        vertical: 10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Recent Servicing History",
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, NavigationPage.NearestServicing);
                },
                icon: const Icon(
                  Icons.image_search_rounded,
                  color: Colors.deepPurple,
                ),
              )
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Flexible(
            fit: FlexFit.loose,
            child: _getStationList(),
          ),
        ],
      ),
    );
  }
}
