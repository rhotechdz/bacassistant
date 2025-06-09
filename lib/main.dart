import 'dart:io';
import 'dart:convert';

import 'package:animations/animations.dart';
import 'package:bacassistant/admob_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:bacassistant/routes.dart';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

late final SharedPreferences prefs;

Map? subjectsObject;
Map<String, dynamic>? hisgeoObject;
Map? manifestObject;
Map? curriculum;
List? fieldList;
List? bacList;
List? introElements;
List<String>? subjectsList;
String? chosenField;
String? chosenSubject;
String? appStorage;

late AdMobService adService;
AnchoredAdaptiveBannerAdSize? adSize;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  adService = AdMobService();
  SharedPreferences.getInstance().then((value) {
    prefs = value;
    //prefs.clear();
    chosenField = "شعبة علوم تجريبية";
    chosenSubject = "علوم الطبيعة والحياة";
    prefs.setString("chosenField", chosenField!);
    prefs.setString("chosenSubject", chosenSubject!);
    prefs.setBool("sports", true);
    prefs.setBool("tamazight", true);
    if (prefs.getInt('adCounter') == null) prefs.setInt('adCounter', 0);
  });
  loadFiles();
  runApp(const MyApp());
}

Future<void> loadFiles() async {
  rootBundle.loadString('AssetManifest.json')
    .then((result) => manifestObject = json.decode(result))
    .then((value) => bacList = manifestObject?.keys
    .where((element) => element.contains('/bac/')).toList().reversed.toList());
  rootBundle.loadString('assets/data/subjects.json')
    .then((result) => subjectsObject = json.decode(result))
    .then((value) => fieldList = subjectsObject?.keys.toList());
  rootBundle.loadString('assets/data/hisgeo.json')
    .then((result) => hisgeoObject = json.decode(result));
  rootBundle.loadString('assets/data/curriculum.json')
    .then((result) => curriculum = json.decode(result));
  getApplicationDocumentsDirectory()
    .then((value) => appStorage = value.path);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Color color = Colors.indigo;

    AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
      MediaQuery.of(context).size.width.truncate()
    ).then((size) => adSize = size);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      
      title: 'BAC Guide',
      theme: ThemeData(
        splashFactory: InkRipple.splashFactory,
        appBarTheme: AppBarTheme(
          color: const Color(0xFFF0EFFF),
          iconTheme: IconThemeData(
            color: Theme.of(context).colorScheme.onPrimaryContainer
          ),
        ),
        scaffoldBackgroundColor: const Color(0xFFF0EFFF),
        useMaterial3: true,
        fontFamily: 'Tajawal',
        colorSchemeSeed: color
      ),
      home: const HomePage(),
    );
  }
}

Widget subjectsPicker(BuildContext context, Function setState, [Function? callback]) {
  final String field = prefs.getString('chosenField')!;
  final List elements = subjectsObject![field].keys.toList();
  elements.removeLast();

  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisAlignment: MainAxisAlignment.center,
    children: List.generate(elements.length, (index)
      => InkWell(
        borderRadius: BorderRadius.circular(20.0),
        child: Container(
          height: 60,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0)
          ),
          child: Text(
            ' ${elements[index]} ',
            textAlign: TextAlign.center,
            style: txtTheme(context).headlineSmall,
          ),
        ),
        onTap: () {
          Navigator.of(context).pop();
          setState(() {
            prefs.setString('chosenSubject', elements[index]);
            chosenSubject = elements[index];
          }
          );
        },
      )
    )
  );
}

Widget fieldPicker(BuildContext context, Function setState) {

  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisAlignment: MainAxisAlignment.center,
    children: List.generate(fieldList!.length, (index)
      => InkWell(
        borderRadius: BorderRadius.circular(20.0),
        child: Container(
          height: 50,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0)
          ),
          child: Text(
            ' ${fieldList![index]} ',
            textAlign: TextAlign.center,
            style: txtTheme(context).titleLarge!.copyWith(
              fontWeight: FontWeight.bold
            ),
          ),
        ),
        onTap: () {
          String field = fieldList![index];
          Navigator.of(context).pop();
          setState(() {
            prefs.setString('chosenField', field);
            prefs.setString('chosenSubject', subjectsObject![field].keys.elementAt(0)); 
            chosenField = fieldList![index];
            chosenSubject = subjectsObject![field].keys.elementAt(0);
          });
        },
      )
    )
  );
}

void loadInterstitialAd() {
  int? adCounter = prefs.getInt('adCounter');
  print('adCounter: $adCounter');
  if (adCounter! >= 2) {
    adService.loadInterstitialAd();
    prefs.setInt('adCounter', 0);
  } else {
    prefs.setInt('adCounter', adCounter+1);
  }
}

void loadRewardedAd() {
  int? adCounter = prefs.getInt('adCounter');
  print('adCounter: $adCounter');
  if (adCounter! >= 1) {
    adService.loadRewardedInterstitialAd();
    prefs.setInt('adCounter', 0);
  } else {
    prefs.setInt('adCounter', adCounter+1);
  }
}

TextTheme txtTheme (context) => Theme.of(context).textTheme;
ColorScheme colorScheme (context) => Theme.of(context).colorScheme;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentPageIndex = 0;
  int? timestamp;
  Duration? diff;
  Map intervals = {};
  BannerAd? bannerAd;

  Future<String> _loadTimestamp() async {
    await Dio().download(
      "https://raw.githubusercontent.com/bacdz02/a5b1f45402b9/main/timestamp.txt",
      '$appStorage/timestamp.txt',
    );
    File file = File('$appStorage/timestamp.txt');
    String content = file.readAsStringSync();
    return content;
  }

  @override
  void initState() {
    super.initState();
    adService.loadAppOpenAd();
    adService.listenToAppStateChanges();
  }

  @override
  void didChangeDependencies() async {
    adSize == null
    ? await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
      MediaQuery.of(context).size.width.truncate()
    ).then((size) => adSize = size)
    : null;
    adService.loadBannerAd(adSize);
    setState(() {});
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    adService.bannerAd!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double borderRadius = 48;
    return Scaffold(
      backgroundColor: const Color(0xFFF0EFFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0EFFF),
        primary: true,
        leading: IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () => {
            showDialog(
              context: context,
              builder: (_) {
                return AlertDialog(
                  scrollable: true,
                  title: Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text('إختر الشعبة',
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.center,
                      style: txtTheme(context).headlineSmall!.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onPrimaryContainer
                      )
                    ),
                  ),
                  content: fieldPicker(context, setState)
                );
              }
            )
          }
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () async {
                setState(() {});
              }
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          const SizedBox(height: 10),
          Container(
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: FutureBuilder<Object>(
              future: _loadTimestamp()
                  .then((value) {
                    timestamp = int.parse(value);
                    int now = DateTime.timestamp().millisecondsSinceEpoch ~/ 1000;
                    int diff = timestamp! - now;
        
                    int remainder = 0;
                    intervals['أشهر'] = (diff ~/ 2629743); // weeks
                    remainder = diff.remainder(2629743);
                    intervals['يوم'] = (remainder ~/ 86400); // days
                    remainder = remainder.remainder(86400);
                    intervals['ساعة'] = (remainder ~/ 3600); // hours
                    remainder = remainder.remainder(3600);
                    intervals['دقيقة'] = (remainder ~/ 60); // minutes
                    remainder = remainder.remainder(60);
        
                    return 0;
                  }),
              builder: (context, snapshot) {
                Widget buildWidget = Container(
                  height: 250,
                  padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 25),
                  child: const Center(child: CircularProgressIndicator()),
                );
                if (snapshot.connectionState == ConnectionState.done) {
                  buildWidget = Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 25),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'تبقى لامتحان البكالوريا',
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.start,
                          style: txtTheme(context).displaySmall!.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.onPrimaryContainer
                          )
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 22),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(intervals.keys.length, (index) => 
                              Column(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.4)
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        '${intervals.values.elementAt(index)}',
                                        style: txtTheme(context).headlineMedium!.copyWith(
                                          color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.9),
                                          fontWeight: FontWeight.w600
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Text(
                                      intervals.keys.elementAt(index),
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8)
                                      ),
                                    ),
                                  )
                                ],
                              )
                            )
                          ),
                        )
                      ],
                    ),
                  );
                }
                
                return buildWidget;
              }
            ),
          ),
          const SizedBox(height: 20),
          ...pages.map((element) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Ink(
                //padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(
                    blurRadius: 1.5,
                    spreadRadius: 0.5,
                    offset: const Offset(0, 2),
                    color: colorScheme(context).outline.withOpacity(0.08)
                  )],
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(borderRadius),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.only(left: 25),
                          alignment: Alignment.centerLeft,
                          child: const Icon(
                            Icons.chevron_left_rounded,
                            size: 30,
                          ))
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Text(
                          element["title"],
                          //maxFontSize: 20,
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                            color: colorScheme(context).onPrimaryContainer,
                          )
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF0EFFF),
                            shape: BoxShape.circle
                          ),
                          child: Image.asset(
                            'assets/images/${element["icon"]}',
                            width: 30,
                            height: 30,
                            color: const Color(0xFF7789F0),
                          ),
                        ),
                      ),
                      
                    ],
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => element["route"],
                        transitionDuration: const Duration(milliseconds: 100),
                        transitionsBuilder: (
                          _, animation, secondaryAnimation, child
                        ) => FadeThroughTransition(
                          animation: animation,
                          secondaryAnimation: secondaryAnimation,
                          child: child
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          }),
          const SizedBox(height: 40)
        ]
      ),
      bottomNavigationBar: adService.bannerAd != null 
      ? SizedBox(
        width: adService.bannerAd!.size.width.toDouble(),
        height: adService.bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: adService.bannerAd!),
      )
      : null,
    );
  }
}
