import 'package:ev_tracker/modal/appData.dart';
import 'package:ev_tracker/modal/applicationUser.dart';
import 'package:ev_tracker/screens/dashboard/dashboard_indexpage.dart';
import 'package:ev_tracker/screens/login/login_indexpage.dart';
import 'package:ev_tracker/screens/profile/profile_indexpage.dart';
import 'package:ev_tracker/screens/search/search_indexpage.dart';
import 'package:ev_tracker/screens/track_history/track_indexpage.dart';
import 'package:ev_tracker/service/db/DbService.dart';
import 'package:ev_tracker/utilities/NavigationPage.dart';
import 'package:ev_tracker/widgets/CustomAppBar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeIndePage extends StatefulWidget {
  int pageIndex;

  HomeIndePage(this.pageIndex);

  @override
  _HomeIndePageState createState() => _HomeIndePageState();
}

class _HomeIndePageState extends State<HomeIndePage> {
  int pageIndex = 0;
  ApplicationUser? _user;

  @override
  void initState() {
    super.initState();

    ApplicationUser user = Provider.of<AppData>(context, listen: false).user;
    loadProfileDetail(user);
  }

  void loadProfileDetail(ApplicationUser user) async {
    // var result = await User.getUser();
    setState(() {
      pageIndex = widget.pageIndex;
      _user = user;
    });
  }

  void _loadPageOnTap(int index) {
    setState(() {
      pageIndex = index;
    });
  }

  List<BottomNavigationBarItem> _getMenuItems() {
    List<BottomNavigationBarItem> items = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: "Home",
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.location_searching),
        label: "Search",
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.map),
        label: "History",
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.account_circle),
        label: "Profile",
      ),
    ];

    return items;
  }

  void changePage() {
    debugPrint("change page called");
    setState(() {
      pageIndex = NavigationPage.SearchIndex;
    });
  }

  Widget getPage(int pageIndex) {
    late Widget page;
    switch (pageIndex) {
      case NavigationPage.DashboardIndex:
        page = DashboardIndexPage(
          changePage: changePage,
        );
        break;
      case NavigationPage.ProfileIndex:
        page = ProfileIndexPage();
        break;
      case NavigationPage.SearchIndex:
        page = SearchIndexPage(); // const MapboxMapIndexPage();
        break;
      case NavigationPage.TrackIndex:
        page = TrackIndexPage();
        break;
      case NavigationPage.LoginIndex:
        page = const LoginIndexPage();
        break;
      default:
        page = DashboardIndexPage(
          changePage: changePage,
        );
        break;
    }

    return page;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).colorScheme.onBackground,
        currentIndex: pageIndex,
        selectedItemColor: Colors.black87,
        unselectedItemColor: Colors.black.withOpacity(0.2),
        onTap: _loadPageOnTap,
        items: _getMenuItems(),
        type: BottomNavigationBarType.fixed,
      ),
      body: getPage(pageIndex),
    );
  }
}
