import 'dart:convert';

import 'package:bacassistant/main.dart';
import 'package:bacassistant/routes.dart';
import 'package:bacassistant/screens/introduction_flow/press_animation_button.dart';
import 'package:bacassistant/utils/initializer.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

extension ThemeContext on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colors => Theme.of(this).colorScheme;
}

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

  Future<Map<String, dynamic>> _loadTimestamp() async {
    final cached = prefs.getString('cached_exam_timestamp');
    if (cached != null && cached.isNotEmpty) {
      final decoded = jsonDecode(cached);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return decoded.cast<String, dynamic>();
      }
    }

    final response = await Dio().get(
      'https://bac-assistant.idrismore18.workers.dev/dev/timestamp',
    );
    final data = response.data;
    final normalized = data is Map<String, dynamic>
        ? data
        : (data as Map).cast<String, dynamic>();

    prefs.setString('cached_exam_timestamp', jsonEncode(normalized));
    return normalized;
  }

  /* @override
  void initState() {
    super.initState();
    AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
      MediaQuery.of(context).size.width.truncate()
    ).then((size) => adSize = size);
    adService.loadAppOpenAd();
    adService.listenToAppStateChanges();
  } */

  /* @override
  void didChangeDependencies() async {
    /* adSize == null
    ? await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
      MediaQuery.of(context).size.width.truncate()
    ).then((size) => adSize = size)
    : null; */
    /* adService.loadBannerAd(adSize);
    setState(() {}); */
    super.didChangeDependencies();
  } */

  @override
  void dispose() {
    adService.bannerAd!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double borderRadius = 48;
    return Scaffold(
      //backgroundColor: const Color(0xFFF0EFFF),
      appBar: AppBar(
        //backgroundColor: const Color(0xFFF0EFFF),
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
                                  style: context.textTheme.headlineSmall!
                                      .copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: context
                                              .colors.onPrimaryContainer)),
                            ),
                            content: fieldPicker(context, setState));
                      })
                }),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: IconButton(
                icon: const Icon(Icons.refresh_rounded),
                onPressed: () async {
                  setState(() {});
                }),
          ),
        ],
      ),
      body: ListView(children: [
        Container(
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: context.colors.primaryContainer,
          ),
          child: FutureBuilder<Object>(
              future: _loadTimestamp().then((value) {
                final examTimestamp = value['examTimestamp'] as int? ?? 0;
                final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
                final diff = (examTimestamp - now).clamp(0, 2147483647);

                int remainder = diff;
                intervals['أشهر'] = (remainder ~/ 2629743);
                remainder = remainder.remainder(2629743);
                intervals['يوم'] = (remainder ~/ 86400);
                remainder = remainder.remainder(86400);
                intervals['ساعة'] = (remainder ~/ 3600);
                remainder = remainder.remainder(3600);
                intervals['دقيقة'] = (remainder ~/ 60);

                return 0;
              }),
              builder: (context, snapshot) {
                Widget buildWidget = Container(
                  height: 250,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30.0, vertical: 25),
                  child: const Center(child: CircularProgressIndicator()),
                );
                if (snapshot.connectionState == ConnectionState.done) {
                  buildWidget = Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30.0, vertical: 25),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('تبقى لامتحان البكالوريا',
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.start,
                            style: context.textTheme.displaySmall!.copyWith(
                                fontWeight: FontWeight.w700,
                                color: context.colors.onPrimaryContainer)),
                        Padding(
                          padding: const EdgeInsets.only(top: 22),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(
                                  intervals.keys.length,
                                  (index) => Column(
                                        children: [
                                          Container(
                                            width: 50,
                                            height: 50,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              //color: context.colors.onPrimary.withOpacity(0.4)
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 8.0),
                                              child: Text(
                                                '${intervals.values.elementAt(index)}',
                                                style: context
                                                    .textTheme.headlineMedium!
                                                    .copyWith(
                                                        //color: context.colors.onPrimaryContainer.withOpacity(0.9),
                                                        fontWeight:
                                                            FontWeight.w600),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 10),
                                            child: Text(
                                              intervals.keys.elementAt(index),
                                              style: TextStyle(
                                                  color: context
                                                      .colors.onPrimaryContainer
                                                      .withValues(alpha: 0.8)),
                                            ),
                                          )
                                        ],
                                      ))),
                        )
                      ],
                    ),
                  );
                }

                return buildWidget;
              }),
        ),
        const SizedBox(height: 20),
        ...pages.map((element) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Container(
              //padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              height: 80,
              decoration: BoxDecoration(
                color: context.colors.primaryContainer,
                boxShadow: [
                  BoxShadow(
                      blurRadius: 1.5,
                      spreadRadius: 0.5,
                      offset: const Offset(0, 2),
                      color: context.colors.outline.withAlpha(100))
                ],
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              child: PressAnimationButton(
                //borderRadius: BorderRadius.circular(borderRadius),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(borderRadius)),
                ),
                label: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                        child: Container(
                            padding: const EdgeInsets.only(left: 25),
                            alignment: Alignment.centerLeft,
                            child: const Icon(
                              Icons.chevron_left_rounded,
                              size: 30,
                            ))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Text(element["title"],
                          //maxFontSize: 20,
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                            color: context.colors.onPrimaryContainer,
                          )),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: const BoxDecoration(
                            color: Color(0xFFF0EFFF), shape: BoxShape.circle),
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
                onPressed: () {
                  Navigator.of(context).push(
                    drillDown(element["route"] as Widget),
                  );
                },
              ),
            ),
          );
        }),
        const SizedBox(height: 40)
      ]),
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
