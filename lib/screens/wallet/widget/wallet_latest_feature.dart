import 'package:flutter/material.dart';

class WalletLatestFeature extends StatelessWidget {
  const WalletLatestFeature({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Latest feature", style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 20,
          ),),
          Container(
            margin: const EdgeInsets.only(
              top: 10,
            ),
            padding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 20,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onBackground,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const SizedBox(
                  width: 140,
                  child: Text(
                    "You don't have any new feature in your account",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Image.asset(
                  "assets/images/unboxing.png",
                  height: 100,
                  width: 100,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
