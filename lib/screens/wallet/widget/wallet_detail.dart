import 'package:flutter/material.dart';

class WalletDetail extends StatelessWidget {
  WalletDetail({Key? key}) : super(key: key);

  final double _vspacing = 12;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 30, right: 30, top: 20, bottom: 10),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: _vspacing,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                InkWell(
                  child: Row(
                    children: const [
                      Icon(
                        Icons.transfer_within_a_station,
                        color: Colors.blue,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Text(
                        "Transfer",
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    ],
                  ),
                ),
                InkWell(
                  child: Row(
                    children: const [
                      Icon(
                        Icons.monetization_on_outlined,
                        color: Colors.redAccent,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Text(
                        "Funds",
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: _vspacing,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                InkWell(
                  child: Row(
                    children: const [
                      Icon(
                        Icons.add_card,
                        color: Colors.red,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Text(
                        "Repay",
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    ],
                  ),
                ),
                InkWell(
                  child: Row(
                    children: const [
                      Icon(
                        Icons.data_exploration,
                        color: Colors.deepPurpleAccent,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Text(
                        "Data",
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: _vspacing,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                InkWell(
                  child: Row(
                    children: const [
                      Icon(
                        Icons.chat,
                        color: Colors.green,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Text(
                        "Message",
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    ],
                  ),
                ),
                InkWell(
                  child: Row(
                    children: const [
                      Icon(
                        Icons.expand,
                        color: Colors.lightBlue,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Text(
                        "More",
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
