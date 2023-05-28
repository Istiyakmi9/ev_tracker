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
      message1: 'The quickest way to get diagnosed and',
      message2: 'Treated, from the comfort of your home!',
    ),
    OnLoadingPage(
      imgPath: "assets/images/ev_2.jpg",
      title: 'How to use',
      message1: 'AccurateDoctor- The fastest way to see your',
      message2: 'patients virtually',
    ),
    OnLoadingPage(
      imgPath: "assets/images/ev_3.jpg",
      title: 'Charging guide',
      message1: 'To provide quality telehealth services to all ',
      message2: 'including most secluded areas',
    ),
    OnLoadingPage(
      imgPath: "assets/images/ev_4.jpg",
      title: 'Location station on map',
      message1: 'Extend access to your healthcare service',
      message2: 'amid covid-19 with AccurateDoctor',
    ),
  ];

  moveNextPage() {
    pageController.nextPage(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeIn,
    );
  }

  void setPreferenceAndLoadLoginPage() {
    SharedPreferences.getInstance().then((pref) {
      pref.setBool("infoScreenCompleted", true);
      debugPrint("Preferences set successfully");

      Navigator.pushNamedAndRemoveUntil(
        context,
        NavigationPage.LoginPage,
            (route) => false,
      );
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
            right: -30,
            bottom: -30,
            child: InkWell(
              onTap: () {
                if (_activePage != 3) {
                  moveNextPage();
                } else {
                  setPreferenceAndLoadLoginPage();
                }
              },
              child: Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(80),
                    bottomLeft: Radius.circular(0),
                  ),
                  border: Border.all(
                    width: 1,
                    color: Colors.yellow,
                    style: BorderStyle.solid,
                  ),
                  color: Colors.yellow,
                ),
                child: const Center(
                  child: Icon(Icons.arrow_forward),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
