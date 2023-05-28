import 'package:ev_tracker/modal/Configuration.dart';
import 'package:ev_tracker/utilities/NavigationPage.dart';
import 'package:flutter/material.dart';

class InfoCards extends StatelessWidget {
  InfoCards({Key? key}) : super(key: key);

  final List<CardModal> cards = [
    CardModal(
        name: "Find Stations",
        icon: Icons.charging_station,
        pageName: NavigationPage.SearchPage),
    CardModal(
        name: "Charging History",
        icon: Icons.history,
        pageName: NavigationPage.SearchPage),
    CardModal(
        name: "Map Configuration",
        icon: Icons.map_sharp,
        pageName: NavigationPage.MapConfiguration),
    CardModal(
        name: "Wallet",
        icon: Icons.wallet,
        pageName: NavigationPage.SearchPage),
    CardModal(
        name: "My Booking",
        icon: Icons.book_online_outlined,
        pageName: NavigationPage.SearchPage),
    CardModal(
        name: "Setting",
        icon: Icons.settings,
        pageName: NavigationPage.SearchPage),
  ];

  Widget cardBody(BuildContext context, CardModal item) {
    return InkWell(
      onTap: () {
        debugPrint(item.pageName);
        Navigator.pushNamed(
          context,
          item.pageName,
          arguments: null,
        );
      },
      child: Container(
        alignment: Alignment.center,
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Icon(
                item.icon,
                size: 40,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            Text(item.name),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return cardBody(context, cards[index]);
        },
        childCount: cards.length,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 1,
        crossAxisSpacing: 1,
        childAspectRatio: 1.2,
      ),
    );
  }
}

class CardModal {
  late String name;
  late IconData icon;
  late String pageName;

  CardModal({
    required this.name,
    required this.icon,
    required this.pageName,
  });
}
