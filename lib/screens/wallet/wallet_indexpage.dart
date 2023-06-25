import 'package:ev_tracker/screens/wallet/widget/balance_info.dart';
import 'package:ev_tracker/screens/wallet/widget/wallet_actions.dart';
import 'package:ev_tracker/screens/wallet/widget/wallet_detail.dart';
import 'package:ev_tracker/screens/wallet/widget/wallet_latest_feature.dart';
import 'package:ev_tracker/widgets/CustomAppBar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Wallet extends StatefulWidget {
  const Wallet({Key? key}) : super(key: key);

  @override
  State<Wallet> createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 30,
          vertical: 20,
        ),
        child: Column(
          children: [
            const WalletBalanceDetail(),
            const WalletActions(),
            WalletDetail(),
            const WalletLatestFeature(),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 25),
              child: const Text(
                "This feature is current not available.",
                style: TextStyle(
                  color: Colors.black45,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
