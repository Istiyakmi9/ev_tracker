import 'package:ev_tracker/widgets/CustomAppBar.dart';
import 'package:flutter/material.dart';

class Booking extends StatelessWidget {
  const Booking({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Container(
        color: const Color(0x44e1e5eb),
        padding: const EdgeInsets.symmetric(
          horizontal: 0,
          vertical: 0,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset(
              "assets/images/booking.jpeg",
              height: 200,
              width: 400,
            ),
            const SizedBox(
              height: 25,
            ),
            Wrap(
              alignment: WrapAlignment.center,
              children: const [
                Text(
                  "This page is under construction",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 20,
                  ),
                  child: Text(
                    "This page will allow user to book their vehicle for the servicing. In upcoming version there is lot's of new feature we are going to add.",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
