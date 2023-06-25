import 'package:ev_tracker/modal/SettingPreferences.dart';
import 'package:ev_tracker/screens/app_introduction/screens/on_loading_page.dart';
import 'package:ev_tracker/utilities/NavigationPage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppIntroductionPage extends StatefulWidget {
  AppIntroductionPage({Key? key}) : super(key: key);

  @override
  State<AppIntroductionPage> createState() => _AppIntroductionPageState();
}

class _AppIntroductionPageState extends State<AppIntroductionPage> {
  PageController pageController = PageController(initialPage: 0);

  int _activePage = 0;

  final List<Widget> _pages = [
    OnLoadingPage(
      imgPath: "assets/images/ev_1.jpeg",
      title: 'Electric vehicle station',
      message1: 'Recharge your vehicle and get your nearby vehicle ',
      message2:
          'Charging station. Track your route and see station trafic also.',
    ),
    OnLoadingPage(
      imgPath: "assets/images/ev_2.jpg",
      title: 'How to use',
      message1: 'Enable your GPS on requested by app. Click trace button',
      message2: 'By default it will search for electric stations.',
    ),
    OnLoadingPage(
      imgPath: "assets/images/ev_3.jpg",
      title: 'Charging guide',
      message1: 'Update your app status once charging completed.',
      message2: 'Put your rating and feedback to make a record of it.',
    ),
    OnLoadingPage(
      imgPath: "assets/images/ev_4.jpg",
      title: 'Location station on map',
      message1: 'Locate electric vehicle station near by your. Observe route and ',
      message2: 'station traffic and start your trip.',
    ),
  ];

  moveNextPage() {
    pageController.nextPage(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeIn,
    );
  }

  Future<void> setPreferenceAndLoadLoginPage() async {
    SettingPreferences settings = await SettingPreferences.getSettingDetail();
    settings.mapZoomValue = 22.0;
    settings.mapTiltValue = 75.0;
    settings.defaultSearchKey = "petrol pump";
    SettingPreferences.update(settings);

    SharedPreferences.getInstance().then((pref) {
      pref.setBool("infoScreenCompleted", true);

      Navigator.pushNamedAndRemoveUntil(
        context,
        NavigationPage.LoginPage,
        (route) => false,
      );

      debugPrint("Preferences set successfully");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: pageController,
            onPageChanged: (int page) {
              setState(() {
                _activePage = page;
              });
            },
            itemCount: _pages.length,
            itemBuilder: (BuildContext context, int index) {
              return _pages[index % _pages.length];
            },
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: InkWell(
              onTap: () {
                if (_activePage != 3) {
                  moveNextPage();
                } else {
                  setPreferenceAndLoadLoginPage();
                }
              },
              child: Container(
                height: 40,
                width: 60,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(0),
                  ),
                  border: Border.all(
                    width: 1,
                    color: Colors.yellow,
                    style: BorderStyle.solid,
                  ),
                  color: Colors.yellow,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.arrow_forward,
                      ),
                    ],
                  ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
