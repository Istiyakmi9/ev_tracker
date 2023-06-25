import 'dart:convert';
import 'dart:io';

import 'package:ev_tracker/modal/Configuration.dart';
import 'package:ev_tracker/modal/appData.dart';
import 'package:ev_tracker/modal/SettingPreferences.dart';
import 'package:ev_tracker/screens/app_introduction/introduction_indexpage.dart';
import 'package:ev_tracker/screens/booking/booking_indexpage.dart';
import 'package:ev_tracker/screens/dashboard/widgets/nearest_servicing.dart';
import 'package:ev_tracker/screens/dashboard/widgets/rating_history.dart';
import 'package:ev_tracker/screens/login/login_indexpage.dart';
import 'package:ev_tracker/screens/map/map_configuration.dart';
import 'package:ev_tracker/screens/map/map_indexpage.dart';
import 'package:ev_tracker/screens/profile/profile_indexpage.dart';
import 'package:ev_tracker/screens/profile/widgets/privacy_and_policy.dart';
import 'package:ev_tracker/screens/profile/widgets/settings/setting.dart';
import 'package:ev_tracker/screens/profile/widgets/user_profile.dart';
import 'package:ev_tracker/screens/profile/widgets/vehicle_detail.dart';
import 'package:ev_tracker/screens/search/search_indexpage.dart';
import 'package:ev_tracker/screens/track_history/track_indexpage.dart';
import 'package:ev_tracker/screens/wallet/wallet_indexpage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/dashboard/dashboard_indexpage.dart';
import 'screens/home_layout/home_indexpage.dart';
import 'utilities/NavigationPage.dart';

// late SharedPreferences sharedPreferences;

late bool flag;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await GetStorage.init();
  await configureAppData();
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppData(),
      child: MyApp(),
    ),
  );
}

Future<void> configureAppData() async {
  var pref = await SharedPreferences.getInstance();
  bool? prefFlag = pref.getBool("infoScreenCompleted");
  if (prefFlag != null && prefFlag!) {
    flag = true;
  } else {
    flag = false;
  }

  SettingPreferences.cleanSetting();
  SettingPreferences settings = await SettingPreferences.getSettingDetail();
  SettingPreferences.update(settings);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: const ColorScheme(
          primary: Color(0xFFFFA500),
          // <---- I set white color here
          secondary: Color(0xff000000),
          background: Color(0xFF636363),
          surface: Color(0xFF808080),
          onBackground: Color(0xFFFFA500),
          error: Colors.redAccent,
          onError: Colors.redAccent,
          onPrimary: Color(0xee000000),
          onSecondary: Colors.black,
          onSurface: Color(0xFF241E30),
          brightness: Brightness.light,
        ),
      ),
      initialRoute: "/",
      routes: {
        // NavigationPage.DashboardPage: (_) => DashboardIndexPage(changePage: null),
        NavigationPage.ProfilePage: (_) => ProfileIndexPage(),
        NavigationPage.VehicleDetailPage: (_) => const VehicleDetail(),
        NavigationPage.SearchPage: (_) => SearchIndexPage(),
        NavigationPage.TrackPage: (_) => TrackIndexPage(),
        NavigationPage.LoginPage: (_) => const LoginIndexPage(),
        NavigationPage.MapIndexPage: (_) => const MapIndexPage(),
        // NavigationPage.MMapIndexPage: (_) => const MapboxMapIndexPage(),
        NavigationPage.UserProfilePage: (_) => const UserProfile(),
        NavigationPage.SettingsPage: (_) => const Setting(),
        NavigationPage.NearestServicing: (_) => NearestServicing(),
        NavigationPage.MapConfiguration: (_) => const MapConfiguration(),
        NavigationPage.RatingHistoryPage: (_) => const RatingHistory(),
        NavigationPage.PrivacyAndPolicyPage: (_) => PrivacyAndPolicy(),
        NavigationPage.WalletPage: (_) => const Wallet(),
        NavigationPage.BookingPage: (_) => const Booking(),
        NavigationPage.HomePage: (_) =>
            HomeIndePage(NavigationPage.DashboardIndex),
      },
      onUnknownRoute: (setting) {
        return MaterialPageRoute(builder: (_) => const LoginIndexPage());
      },
      // home: Home(NavigationPage.DashboardIndex),
      home: flag! ? const LoginIndexPage() : AppIntroductionPage(),
      // home: const LoginIndexPage(),
    );
  }
}
