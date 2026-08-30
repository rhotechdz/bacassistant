//import 'package:bacassistant/main.dart';

import 'dart:convert';

import 'package:bacassistant/services/admob/admob_service.dart';
import 'package:bacassistant/firebase_options.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

late final SharedPreferences prefs;
late final String appStorage;

//Map<String, dynamic> subjectsMap = {};
Map<String, dynamic> hisgeoMap = {};
Map<String, dynamic> curriculumMap = {};
List fieldList = [];
List introElements = [];
List<String> subjectsList = [];
String? chosenField;
String? chosenSubject;

late AdMobService adService;
AnchoredAdaptiveBannerAdSize? adSize;

class Initializer {
  Initializer() {
    run();
  }

  static void isFirstRun() {
    if (prefs.getBool("firstRun") == null) {
      prefs.setBool("firstRun", false);
      setDefaults();
    }
  }

  static void setDefaults() {
    prefs.setString("chosenField", "شعبة علوم تجريبية");
    prefs.setString("chosenSubject", "علوم الطبيعة والحياة");
    prefs.setBool("firstRun", true);
    prefs.setBool("sports", true);
    prefs.setBool("tamazight", true);
    prefs.setInt("adCounter", 0);
  }

  static Future<void> loadFiles() async {
    rootBundle
        .loadString('assets/data/historical_events.json')
        .then((result) => hisgeoMap = json.decode(result));
    rootBundle
        .loadString('assets/data/curriculum.json')
        .then((result) => curriculumMap = json.decode(result));
  }

  static Future<void> run() async {
    // Initialize shared preferences
    prefs = await SharedPreferences.getInstance();

    // Check if first run
    isFirstRun();

    // Load JSON assets
    loadFiles();

    // Initialize appStorage path
    appStorage = (await getApplicationDocumentsDirectory()).path;

    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize Firebase App Check
    await FirebaseAppCheck.instance
        .activate(androidProvider: AndroidProvider.debug);

    // Load ad service
    await MobileAds.instance.initialize();
    adService = AdMobService();
    /* AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
      320 // width
    ).then((size) => adSize = size); */
  }
}
