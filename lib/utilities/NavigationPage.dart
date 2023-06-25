import 'package:ev_tracker/screens/dashboard/dashboard_indexpage.dart';
import 'package:ev_tracker/screens/login/login_indexpage.dart';
import 'package:ev_tracker/screens/map/mmap_indexpage.dart';
import 'package:ev_tracker/screens/profile/profile_indexpage.dart';
import 'package:ev_tracker/screens/track_history/track_indexpage.dart';
import 'package:ev_tracker/screens/search/search_indexpage.dart';
import 'package:flutter/material.dart';

class NavigationPage {
  static const String DashboardPage = "dashboard";
  static const String SearchPage = "search";
  static const String MapConfiguration = "mapConfiguration";
  static const String TrackPage = "track";
  static const String ProfilePage = "profile";
  static const String LoginPage = "login";
  static const String HomePage = "home";
  static const String MapIndexPage = "mapIndexPage";
  static const String MMapIndexPage = "mapBoxMapIndexPage";
  static const String UserProfilePage = "user_profile";
  static const String VehicleDetailPage = "vehicle_detail";
  static const String SettingsPage = "setting";
  static const String RecentlyVisitedPage = "last_visited";
  static const String StationsPage = "stattions";
  static const String HistoryPage = "history";
  static const String NearestServicing = "nearest_servicing";
  static const String RatingHistoryPage = "ratingHistoryPage";
  static const String PrivacyAndPolicyPage = "privacyAndPolicyPage";
  static const String WalletPage = "walletPage";
  static const String BookingPage = "booking";

  static const int DashboardIndex = 0;
  static const int SearchIndex = 1;
  static const int TrackIndex = 2;
  static const int ProfileIndex = 3;
  static const int LoginIndex = 4;
}
