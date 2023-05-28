import 'package:flutter/material.dart';

import '../../utilities/NavigationPage.dart';

class ProfileIndexPage extends StatelessWidget {
  ProfileIndexPage();

  double cardWidth = 140;
  double cardHeight = 100;
  static const double gap = 10;
  static const double imageSize = 60;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(
            top: 25,
            bottom: 25,
          ),
          child: const Text(
            "Manage your assets",
            style: TextStyle(
              color: Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Card(
              elevation: 0,
              child: Container(
                width: cardWidth,
                height: cardHeight,
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 15,
                ),
                margin: const EdgeInsets.symmetric(
                  horizontal: gap,
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.of(context)
                        .pushNamed(NavigationPage.UserProfilePage);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(
                        "assets/images/user_profile.png",
                        width: 40,
                      ),
                      const Text("User"),
                    ],
                  ),
                ),
              ),
            ),
            Card(
              elevation: 0,
              child: Container(
                width: cardWidth,
                height: cardHeight,
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 15,
                ),
                margin: const EdgeInsets.symmetric(
                  horizontal: gap,
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.of(context)
                        .pushNamed(NavigationPage.VehicleDetailPage);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(
                        "assets/images/vehicle.png",
                        width: 60,
                      ),
                      Text("Vehicle")
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Card(
              elevation: 0,
              child: Container(
                width: cardWidth,
                height: cardHeight,
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 15,
                ),
                margin: const EdgeInsets.symmetric(
                  horizontal: gap,
                ),
                child: InkWell(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Icon(
                        Icons.person_pin_outlined,
                        size: 55,
                      ),
                      Text("Map Setting"),
                    ],
                  ),
                ),
              ),
            ),
            Card(
              elevation: 0,
              child: Container(
                width: cardWidth,
                height: cardHeight,
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 15,
                ),
                margin: const EdgeInsets.symmetric(
                  horizontal: gap,
                ),
                child: InkWell(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(
                        "assets/images/visited.jpeg",
                        height: imageSize,
                        width: imageSize,
                      ),
                      Text("Vehicle")
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Card(
              elevation: 0,
              child: Container(
                width: cardWidth,
                height: cardHeight,
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 15,
                ),
                margin: const EdgeInsets.symmetric(
                  horizontal: gap,
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, NavigationPage.SettingsPage);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(
                        "assets/images/setting.jpeg",
                        height: imageSize,
                        width: imageSize,
                      ),
                      Text("Setting"),
                    ],
                  ),
                ),
              ),
            ),
            Card(
              elevation: 0,
              child: Container(
                width: cardWidth,
                height: cardHeight,
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 15,
                ),
                margin: const EdgeInsets.symmetric(
                  horizontal: gap,
                ),
                child: InkWell(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(
                        "assets/images/station.jpeg",
                        height: imageSize,
                        width: imageSize,
                      ),
                      Text("Vehicle")
                    ],
                  ),
                ),
              ),
            )
          ],
        )
      ],
    );
  }
}
