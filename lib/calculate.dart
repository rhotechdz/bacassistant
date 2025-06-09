

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:bacassistant/main.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';


class CalculatePage extends StatefulWidget {
  const CalculatePage({super.key});

  @override
  State<CalculatePage> createState() => _CalculatePageState();
}

class _CalculatePageState extends State<CalculatePage> {

  String? _errorText;
  int index = 0;
  double total = 0;
  double factors = 0;
  String? chosenField = prefs.getString("chosenField");
  Map subjectsMap = {};
  Map staticSubjectsMap = {};
  List keys = [];
  List staticKeys = [];
  String? scoreHistory = prefs.getString('scoreHistory');
  String title = '';
  List<double> points = [];
  List<Widget> children = [];
  bool tamazight = prefs.getBool("tamazight")??true;
  bool sports = prefs.getBool("sports")??true;
  BannerAd? bannerAd;
  
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    adService.loadBannerAd(adSize);
    staticSubjectsMap = subjectsObject![chosenField];
    subjectsMap = Map.from(staticSubjectsMap);
    keys = subjectsMap.keys.toList();
    staticKeys = staticSubjectsMap.keys.toList();
    title = keys[index];
    points = List.generate(staticSubjectsMap.length, (index) => 0.0);
    super.initState();
  }

  @override
  void dispose() {
    adService.bannerAd!.dispose();
    _controller.dispose();
    super.dispose();
  }

  void showScoreScreen() {
    showModalBottomSheet(
      context: context,
      builder: (builder) {
        return SizedBox(
          width: double.infinity,
          height: MediaQuery.of(key.currentContext!).size.height * 0.45,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            textBaseline: TextBaseline.ideographic,
            children: [
              Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0)
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    (total / factors).toStringAsFixed(2),
                    style: txtTheme(key.currentContext).displayLarge!
                      .copyWith(
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Noto Sans Display'
                      ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                textBaseline: TextBaseline.ideographic,
                children: [
                  Column(
                    children: [
                      IconButton(
                        onPressed: () {
                        },
                        iconSize: 50,
                        style: const ButtonStyle(
                          padding: MaterialStatePropertyAll(
                            EdgeInsets.only(top: 8, bottom: 8, left: 9, right: 12)
                          ),
                        ),
                        icon: const Icon(Icons.share_rounded)
                      ),
                      const SizedBox(height: 10),
                      const Text('مشاركة'),
                    ],
                  ),
                  Column(
                    children: [
                      IconButton.filled(
                        onPressed: () {
                          Navigator.pop(key.currentContext!);
                          setState(() {
                            index = 0;
                            points = List.generate(staticSubjectsMap.length, (index) => 0);
                            total = 0;
                            factors = 0;
                            title = keys[index];
                            _controller.value = const TextEditingValue(text: '');
                          });
                          showInputScreen();
                        },
                        iconSize: 50,
                        style: const ButtonStyle(
                          padding: MaterialStatePropertyAll(
                            EdgeInsets.symmetric(vertical: 8, horizontal: 6)
                          ),
                        ),
                        icon: const Icon(Icons.replay_rounded)
                      ),
                      const SizedBox(height: 10),
                      const Text('اعادة')
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      }
    );
  }

  void showInputScreen() {

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: StatefulBuilder(
            builder: (context, inSetState) {
              return Container(
                height: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        title,
                        textAlign: TextAlign.right,
                        style: txtTheme(context).titleLarge!.copyWith(
                          fontWeight: FontWeight.w700,
                        )
                      ),
                      Stack(
                        children: [
                          Container(
                            alignment: Alignment.center,
                            child: TextField(
                              autofocus: true,
                              textAlign: TextAlign.center,
                              enableInteractiveSelection: false,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}$'))
                              ],
                              decoration: InputDecoration(errorText: _errorText),
                              controller: _controller,
                              onEditingComplete: () {},
                              style: txtTheme(context).titleLarge!.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                              keyboardType: TextInputType.number,
                              onSubmitted: (value) async {
                          
                                if (_controller.value.text == '') {
                                  inSetState(() => _errorText = 'النقطة لا تكون فارغة');
                                  return;
                                } else {
                                  if (double.parse(_controller.value.text) > 20) {
                                    inSetState(() => _errorText = 'النقطة لا تتجاوز 20');
                                    return;
                                  }
                                }
                          
                                if (index+1 == subjectsMap.length) {
                                  Navigator.pop(context);
                                  setState(() {
                                    Future.delayed(const Duration(milliseconds: 200))
                                    .then((value) {
                                      showScoreScreen();
                                      loadInterstitialAd();
                                      setState(() {
                                        final Map parsed = scoreHistory == null ? {} : jsonDecode(scoreHistory!);
                                        final keys = parsed.keys;
                                        if (keys.length >= 4) {
                                          parsed.removeWhere((key, value) => key == keys.first);
                                        }
                                        parsed["${DateTime.now().millisecondsSinceEpoch}"] = {
                                          'points': points,
                                          'score': (total / factors).toStringAsFixed(2),
                                          'field': chosenField
                                        };
                                        scoreHistory = jsonEncode(parsed);
                                        prefs.setString('scoreHistory', scoreHistory!);
                                      });
                                    });
                                    _errorText = null;
                                    points[index] = double.parse(_controller.value.text);
                                    total += points[index] * subjectsMap[keys[index]];
                                    factors += subjectsMap[keys[index]];
                                    _controller.value = const TextEditingValue(text: '');
                                  });
                                  return;
                                }
                          
                                points[index] = double.parse(_controller.value.text);
                                inSetState(() {
                                  _errorText = null;
                                  total += points[index] * subjectsMap[keys[index]];
                                  factors += subjectsMap[keys[index]];
                                  _controller.value = const TextEditingValue(text: '');
                                  index++;
                                  title = keys[index];
                                });
                                setState(() {});
                              },
                            ),
                          ),
                          Container(
                            alignment: Alignment.bottomRight,
                            height: 50,
                            child: Text(
                              '${index+1}/${staticSubjectsMap.length}',
                              textAlign: TextAlign.left,
                              style: txtTheme(context).titleMedium!.copyWith(
                                color: Colors.grey[700]
                              ),
                              key: ValueKey(title)
                            ),
                          ),
                        ],
                      ),
                      
                    ],
                  ),
                ),
              );
            }
          ),
        );
      }
    );
  }

  void showScoreHistory() {
    final Map obj = jsonDecode(scoreHistory!);
    final keys = obj.keys.toList();

    showModalBottomSheet(
      context: context,
      builder: (builder) {
        return Container(
          padding: const EdgeInsets.only(top: 18),
          width: double.infinity,
          height: 20 + (100 * keys.length).toDouble(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(keys.length, (index) {
              String text = '';
              final int now = DateTime.now().millisecondsSinceEpoch;
              double difference = (now - int.parse(keys[index])) / 1000;

              switch (difference) {
                case < 120:
                  text = 'لحضات';
                case < 600:
                  text = '${((difference ~/ 60)).round()} دقائق';
                case < 3600:
                  text = '${((difference ~/ 60)).round()} دقيقة';
                case < 200000:
                  text = '${((difference ~/ 3600)).round()} ساعة';
                default:
                  text = '${((difference ~/ 86400)).round()} أيام';
              }
              return ListTile(
                leading: const Icon(Icons.chevron_left_rounded),
                title: Text(
                  obj[keys[index]]['score'].toString(),
                  style: txtTheme(context).displaySmall!
                  .copyWith(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Noto Sans Display'
                  ),
                  textAlign: TextAlign.end,
                ),
                subtitle: Text(
                  'منذ $text',
                  textAlign: TextAlign.end
                ),
                onTap: () {
                  /* Future.delayed(const Duration(milliseconds: 200))
                  .then((value) => ); */
                  showHistoryPage(obj[keys[index]]);
                },
              );
            }).reversed.toList(),
          )
        );
      }
    );
  }

  void showHistoryPage(Map obj) {
    String field = obj['field'];
    List points = obj['points'];
    List keys = subjectsObject![field].keys.toList();
    
    showDialog(
      context: context,
      builder:(context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.only(top: 16, right: 10, left: 10),
          title: Text(
            field,
            style: txtTheme(context).headlineSmall!
            .copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: Container(
            padding: const EdgeInsets.only(top: 8),
            height: 26 + (52 * points.length).toDouble(),
            width: 400,
            child: ListView.separated(
              itemBuilder:(context, index) {
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Text(
                          "${points[index]}",
                          style: txtTheme(context).titleLarge!
                          //.copyWith(fontWeight: FontWeight.w700)
                        ),
                      ),
                      
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          "${keys[index]}",
                          textAlign: TextAlign.end,
                          style: txtTheme(context).titleLarge!
                        ),
                      ),
                    ],
                  ),
                );
              },
              separatorBuilder:(context, index) {
                return const Divider(
                  height: 6,
                );
              },
              itemCount: points.length
            )
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: key,
      appBar: AppBar(
        centerTitle: true,
        actions: [
          scoreHistory != null
          ? IconButton(
            onPressed: () => showScoreHistory(),
            icon: const Icon(Icons.history_rounded)
          )
          : const SizedBox(),
          const SizedBox(width: 8)
        ],
        title: Text(
          prefs.getString("chosenField")!,
          textDirection: TextDirection.rtl,
          style: const TextStyle(fontWeight: FontWeight.w700)
        ),
      ),
      body: ListView.separated(
          padding: const EdgeInsets.only(top: 6, left: 6, right: 6),
          separatorBuilder: (context, index) => const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: SizedBox(height: 3),
          ),
          itemCount: staticSubjectsMap.length,
          itemBuilder: (context, index) {
            List<Widget> children = [
              Container(
                margin: const EdgeInsets.only(top: 7, left: 14),
                child: Text(
                  "${points[index]}",
                  style: txtTheme(context).headlineSmall!
                  .copyWith(
                    fontWeight: FontWeight.w500
                  )
                ),
              ),
            ];
        
            if (staticKeys[index] == "التربية البدنية") {
              children.insert(0,
                Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6, right: 0),
                      child: Text(
                        "${staticKeys[index]}",
                        textAlign: TextAlign.start,
                        style: txtTheme(context).titleLarge!.copyWith(
                          fontWeight: FontWeight.w500,
                        )
                      ),
                    ),
                    Checkbox(
                      value: sports,
                      onChanged: (value) {
                        setState(() {
                          sports = value!;
                          prefs.setBool("sports", value);
                          value
                          ? subjectsMap["التربية البدنية"] = 1
                          : subjectsMap.remove("التربية البدنية");
                          keys = subjectsMap.keys.toList();
                          points = List.generate(staticSubjectsMap.length, (index) => 0.0);
                        });
                      }
                    )
                  ],
                )
              );
            } else if (staticKeys[index] == "اللغة الأمازيغية") {
              children.insert(0,
                Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6, right: 0),
                      child: Text(
                        "${staticKeys[index]}",
                        textAlign: TextAlign.start,
                        style: txtTheme(context).titleLarge!.copyWith(
                          fontWeight: FontWeight.w500,
                        )
                      ),
                    ),
                    Checkbox(
                      value: tamazight,
                      onChanged: (value) {
                        setState(() {
                          tamazight = value!;
                          prefs.setBool("tamazight", value);
                          value
                          ? subjectsMap["اللغة الأمازيغية"] = 2
                          : subjectsMap.remove("اللغة الأمازيغية");
                          keys = subjectsMap.keys.toList();
                          points = List.generate(staticSubjectsMap.length, (index) => 0.0);
                        });
                      }
                    )
                  ],
                )
              );
            } else {
              children.insert(0,
                Container(
                margin: const EdgeInsets.only(top: 6, right: 14),
                child: Text(
                  "${staticKeys[index]}",
                  textAlign: TextAlign.start,
                  style: txtTheme(context).titleLarge!.copyWith(
                    fontWeight: FontWeight.w500
                  )
                ),
              ));
            }
            return Container(
              height: 54,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.7)
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: children.reversed.toList(),
              ),
            );
          },
        ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            index = 0;
            points = List.generate(staticSubjectsMap.length, (index) => 0);
            title = staticKeys[index];
            total = 0;
            factors = 0;
            _controller.value = const TextEditingValue(text: '');
          });
          showInputScreen();
        },
        child: const Icon(Icons.add_rounded),
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
