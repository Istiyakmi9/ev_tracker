import 'package:ev_tracker/modal/Configuration.dart';
import 'package:ev_tracker/utilities/NavigationPage.dart';
import 'package:flutter/material.dart';

class InfoCards extends StatelessWidget {
  Function? func;

  InfoCards({Key? key, required this.func}) : super(key: key);

  List<CardModal> cards = [
    CardModal(
      name: "Find Stations",
      icon: Icons.charging_station,
      isCallback: true,
      pageName: null,
    ),
    CardModal(
      name: "Feedback History",
      icon: Icons.history,
      isCallback: false,
      pageName: NavigationPage.RatingHistoryPage,
    ),
    CardModal(
        name: "Map Configuration",
        icon: Icons.map_sharp,
        isCallback: false,
        pageName: NavigationPage.MapConfiguration),
    CardModal(
        name: "Wallet",
        icon: Icons.wallet,
        isCallback: false,
        pageName: NavigationPage.WalletPage),
    CardModal(
        name: "My Booking",
        icon: Icons.book_online_outlined,
        isCallback: false,
        pageName: NavigationPage.BookingPage),
    CardModal(
        name: "Setting",
        icon: Icons.settings,
        isCallback: false,
        pageName: NavigationPage.SettingsPage),
  ];

  Widget cardBody(BuildContext context, CardModal item) {
    return InkWell(
      onTap: () {
        if (item.isCallback) {
          func!();
        } else {
          Navigator.pushNamed(
            context,
            item.pageName!,
            arguments: null,
          );
        }
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
  String? pageName;
  late bool isCallback;

  CardModal(
      {required this.name,
      required this.icon,
      required this.isCallback,
      required this.pageName});
}
