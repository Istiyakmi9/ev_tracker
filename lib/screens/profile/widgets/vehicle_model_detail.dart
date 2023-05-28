import 'package:flutter/material.dart';

import '../../../modal/Configuration.dart';

class VehicleModelDetail extends StatelessWidget {
  const VehicleModelDetail({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const ListTile(
            title: Text('Modal Detail'),
            subtitle: Text('Enter your make, modal and varient detail.'),
          ),
          Container(
            margin: const EdgeInsets.symmetric(
              vertical: 8,
              horizontal: 15,
            ),
            decoration: BoxDecoration(
              border: Border(
                bottom:
                    BorderSide(width: 0.5, color: Colors.lightBlue.shade900),
              ),
              color: Colors.white,
            ),
            child: TextFormField(
              keyboardType: TextInputType.text,
              initialValue: "mobile",
              decoration: InputDecoration(
                filled: true,
                fillColor: Configuration.colorFromHex("#ffffff"),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                ),
                border: const OutlineInputBorder(),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.transparent,
                  ),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.transparent,
                  ),
                ),
                prefixIcon: const Icon(
                  Icons.phone_android_outlined,
                ),
                hintText: "Enter user mobile no#",
              ),
              textInputAction: TextInputAction.next,
              onSaved: (value) {
                // _user!.mobile = value!;
              },
            ),
          ),
        ],
      ),
    );
  }
}
