import 'package:flutter/material.dart';

class StationRating extends StatelessWidget {
  const StationRating({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 30,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 20,
          ),
          const Text(
            "Rating card",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(
              top: 10,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black45, //New
                        blurRadius: 8.0,
                      )
                    ],
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.white,
                  ),
                  width: MediaQuery.of(context).size.width * 0.418,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Place 1",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        "Here address will come where you last visited with time value.",
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.local_gas_station,
                          color: Colors.deepOrange,
                        ),
                        title: Text("Station Name"),
                        subtitle: Text("Lat & Lng"),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Container(
                  child: Text("sample"),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black,
                    ),
                    color: Colors.white,
                  ),
                  width: MediaQuery.of(context).size.width * 0.418,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
