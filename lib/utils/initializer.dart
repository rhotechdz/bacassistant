import 'package:bacassistant/services/admob/admob_service.dart';
import 'package:bacassistant/services/curriculum_cache.dart';
import 'package:bacassistant/firebase_options.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

late final SharedPreferences prefs;
late final String appStorage;

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
  }

  static Future<void> run() async {
    // Initialize shared preferences
    prefs = await SharedPreferences.getInstance();

    // Check if first run
    isFirstRun();

    await CurriculumCache().loadAll();

    // Initialize appStorage path
    appStorage = (await getApplicationDocumentsDirectory()).path;

    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize Firebase App Check
    await FirebaseAppCheck.instance.activate(
      androidProvider:
          kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
    );

    // Load ad service
    await MobileAds.instance.initialize();
    adService = AdMobService();
    adService.loadAppOpenAd();
    adService.listenToAppStateChanges();
  }
}
