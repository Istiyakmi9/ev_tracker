import 'package:ev_tracker/modal/appData.dart';
import 'package:ev_tracker/modal/applicationUser.dart';
import 'package:ev_tracker/screens/dashboard/widgets/car_information.dart';
import 'package:ev_tracker/screens/dashboard/widgets/info_cards.dart';
import 'package:ev_tracker/screens/dashboard/widgets/servicing_history.dart';
import 'package:ev_tracker/utilities/NavigationPage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardIndexPage extends StatefulWidget {
  const DashboardIndexPage();

  @override
  _DashboardIndexPageState createState() => _DashboardIndexPageState();
}

class _DashboardIndexPageState extends State<DashboardIndexPage> {
  ApplicationUser _user = ApplicationUser();

  void _loadMapPage() {
    Navigator.of(context).pushNamed(NavigationPage.MapIndexPage);
  }

  @override
  void initState() {
    super.initState();
    ApplicationUser user = Provider.of<AppData>(context, listen: false).user;
    getUserdetail(user);
  }

  void getUserdetail(ApplicationUser user) async {
    // User user = await User.getUser();
    setState(() {
      _user = user;
    });
  }

  void _uploadImage() {}

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverList(
          delegate: SliverChildListDelegate(
            [
              Container(
                width: double.infinity,
                color: Colors.white,
                child: Image.asset("assets/images/dashboard-top.jpeg"),
              ),
              Container(
                width: double.infinity,
                color: Colors.white,
                padding: const EdgeInsets.only(
                    left: 20, right: 20, top: 0, bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "No image found",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    MaterialButton(
                      onPressed: _uploadImage,
                      color: Colors.white70,
                      elevation: 0.1,
                      child: const Text("Upload"),
                    )
                  ],
                ),
              ),
              const CarInformation(),
              // ServicingHistory(),
              // const StationRating(),
              Container(
                color: Colors.white,
                margin: const EdgeInsets.only(
                  bottom: 1,
                  top: 4,
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 20,
                ),
                child: const SizedBox(
                  height: 20,
                  child: Text("Quick access"),
                ),
              ),
            ],
          ),
        ),
        InfoCards(),
      ],
    );
  }
}
