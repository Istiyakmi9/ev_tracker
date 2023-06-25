import 'package:flutter/material.dart';

class WalletActions extends StatefulWidget {
  const WalletActions({Key? key}) : super(key: key);

  @override
  State<WalletActions> createState() => _WalletActionsState();
}

class _WalletActionsState extends State<WalletActions> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        top: 30,
        bottom: 10,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 0,
        vertical: 20,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onBackground,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          InkWell(
            child: Column(
              children: const [
                Icon(Icons.document_scanner, size: 30),
                Text("Scan")
              ],
            ),
          ),
          InkWell(
            child: Column(
              children: const [
                Icon(
                  Icons.payments_outlined,
                  size: 30,
                ),
                Text("Pay")
              ],
            ),
          ),
          InkWell(
            child: Column(
              children: const [
                Icon(
                  Icons.incomplete_circle,
                  size: 30,
                ),
                Text("Income"),
              ],
            ),
          ),
          InkWell(
            child: Column(
              children: const [
                Icon(
                  Icons.credit_card,
                  size: 30,
                ),
                Text("Card"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
