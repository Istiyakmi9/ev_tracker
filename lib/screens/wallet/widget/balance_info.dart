import 'package:flutter/material.dart';

class WalletBalanceDetail extends StatelessWidget {
  const WalletBalanceDetail({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Text(
                    "Rs",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Text(
                    "0.00",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 30,
                    ),
                  ),
                ],
              ),
              const Text("My balance")
            ],
          ),
          CircleAvatar(
            radius: 30,
            child: Image.asset("assets/images/profile_user.png"),
          )
        ],
      ),
    );
  }
}
