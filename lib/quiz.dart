

// ignore_for_file: no_logic_in_create_state, must_be_immutable

import 'package:animations/animations.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:bacassistant/main.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:linear_timer/linear_timer.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

List monthList = [
	'جانفي',
	'فيفري',
	'مارس',
	'أفريل',
	'ماي',
	'جوان',
	'جويلية',
	'أوت',
	'سبتمبر',
	'أكتوبر',
	'نوفمبر',
	'ديسمبر'
];
Map units = {
  'الوحدة الأولى': true,
  'الوحدة الثانية': false,
  'الوحدة الثالثة': false
};
Map difficulty = {
  0: true,
  1: false,
  2: false
};
int dateCount = 5;
int unitCount() => units.values.where((element) => element).length;
int progressValue = 0;
List progressList = [];


class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {

  double borderRadius = 20;
  DateTime? currentBackPressTime;
  bool canPopNow = false;
  int requiredSeconds = 2;
  BannerAd? bannerAd;

  @override
  void initState() {
    adService.loadBannerAd(adSize);
    super.initState();
  }

  @override
  void dispose() {
    adService.bannerAd!.dispose();
    super.dispose();
  }
    
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(
              height: 200,
              child: Row(
                //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(36),
                      child: Ink(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(36),
                          color: Theme.of(context).colorScheme.primaryContainer,
                        ),
                        child: Container(
                          height: 200,
                          alignment: Alignment.topCenter,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                'الوحدات',
                                style: txtTheme(context).headlineMedium!.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onPrimaryContainer
                                ),
                              ),
                              Text(
                                units.keys.where(
                                  (element) => units[element] == true
                                ).join('\n'),
                                textAlign: TextAlign.right,
                                style: txtTheme(context).titleSmall!.copyWith(
                                  color: Theme.of(context).colorScheme.onPrimaryContainer
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          builder:(context) {
                            return StatefulBuilder(
                              builder: (context, setState) {
                                return SizedBox(
                                  height: (75 * units.length).toDouble(),
                                  child: Column(
                                    children: List.generate(units.length, (index) {
                                      return ListTile(
                                        shape: index == 0
                                        ? const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(30),
                                            topLeft: Radius.circular(30)
                                          )
                                        )
                                        : null,
                                        visualDensity: const VisualDensity(vertical: 4),
                                        title: Padding(
                                          padding: const EdgeInsets.only(top: 6),
                                          child: Text(
                                            units.keys.elementAt(index),
                                            textAlign: TextAlign.end,
                                            style: txtTheme(context).headlineSmall!.copyWith(
                                              fontWeight: FontWeight.bold
                                            ),
                                          ),
                                        ),
                                        leading: Checkbox(
                                          value: units.values.elementAt(index),
                                          onChanged: (value) {
                                            if (unitCount() == 1 && !value!) return;
                                            setState(() {
                                              units[units.keys.elementAt(index)] = value;
                                            });
                                          }
                                        ),
                                        onTap: () {
                                          if (unitCount() == 1 && units[units.keys.elementAt(index)]!) return;
                                          setState(() {
                                            units[units.keys.elementAt(index)] = !units.values.elementAt(index);
                                          });
                                        },
                                      );
                                    }),
                                  ),
                                );
                              }
                            );
                          },
                        ).whenComplete(() => setState(() {}));
                      },
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(36),
                      child: Ink(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(36),
                          color: Theme.of(context).colorScheme.primaryContainer,
                        ),
                        child: SizedBox(
                          height: 200,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Text(
                                'التواريخ',
                                style: txtTheme(context).headlineMedium!.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onPrimaryContainer
                                ),
                              ),
                              Text(
                                dateCount.toString(),
                                textAlign: TextAlign.center,
                                style: txtTheme(context).headlineLarge!.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Noto Sans Display',
                                  color: Theme.of(context).colorScheme.onPrimaryContainer
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          dateCount = dateCount < 20
                          ? dateCount + 5
                          : 5;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              height: 80,
              child: InkWell(
                borderRadius: BorderRadius.circular(36),
                child: Ink(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(36),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  child: Container(
                    height: 100,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.play_arrow_outlined,
                      size: 48,
                      color: colorScheme(context).onPrimary,
                    )
                  ),
                ),
                onTap: () {
                  progressList = List.generate(dateCount, (index) => 0);
                  progressValue = 0;
                  Future.delayed(const Duration(milliseconds: 150))
                    .then((value) => Navigator.push(
                      context,
                      MaterialPageRoute(builder:(context) => const QuizNavigator())
                    )
                  );
                },
              ),
            ),
          ],
        ),
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

class Quiz extends StatefulWidget {
  late List dates;
  Quiz({super.key, required this.dates});

  @override
  State<Quiz> createState() => _QuizState(dates: dates);
}

class _QuizState extends State<Quiz> 
  with TickerProviderStateMixin {
  late List dates;
  _QuizState({required this.dates});

  late LinearTimerController timerController = LinearTimerController(this);
  final pageController = PageController();

  int dateIndex = 0;
  List options = [];
  bool enabled = true;

  String parseDate(String date) {

    if (date.contains('-')) {
      List dates = date.split('-');
      return "${parseDate(dates[1])} - ${parseDate(dates[0])}";
    }

    List parts = date.split('.');
    String output = '';
    
    output += "${parts[2]} ";
    output += "${monthList[int.parse(parts[1])-1]} ";
    output += "${parts[0]}";
    
    return output;
  }

  void prepareData() {
    dateIndex = dates.length - 1;

    options = List.generate(4, (index) {
      if (index < 3) {
        return {
          'color': Colors.white,
          'textColor': Colors.black,
          'date': index
        };
      } else {
        return {
          'color': Colors.white,
          'textColor': Colors.black,
          'date': dateIndex
        };
      }
    });
    options.shuffle();
  }

  @override
  void initState() {
    prepareData();
    super.initState();
    WidgetsBinding.instance
      .addPostFrameCallback((_) => timerController.start());
  }

  @override
  void dispose() {
    timerController.dispose();
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double borderRadius = 20;
    
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          //const SizedBox(height: 20),
          Expanded(
            child: Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              alignment: Alignment.center,
              child: Text(
                dates[dateIndex].split(':')[1],
                textAlign: TextAlign.center,
                style: txtTheme(context).displaySmall!.copyWith(
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              for (var option in options)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: InkWell(
                  borderRadius: BorderRadius.circular(borderRadius),
                  child: Ink(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(borderRadius),
                      color: option['color'],
                    ),
                    child: Container(
                      height: 70,
                      padding: const EdgeInsets.only(left: 60, right: 20, top: 6),
                      alignment: Alignment.centerRight,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(borderRadius),
                        border: Border.all(color: colorScheme(context).outline)
                      ),
                      child: AutoSizeText(
                        parseDate(dates[option['date']].split(':')[0]),
                        textDirection: TextDirection.rtl,
                        style: txtTheme(context).headlineSmall!.copyWith(
                          color: option['textColor']
                        ),
                        maxLines: 1,
                      ),
                    ),
                  ),
                  onTap: () {
                    if (!enabled) return;
                    int duration = 0;
                    timerController.stop();
                    
                    setState(() {
                      
                      if (option['date'] == dateIndex) {
                        option['color'] = Colors.green;
                        option['textColor'] = Colors.white;
                        duration = 400;
                        progressList[progressValue] = 1;
                      } else {
                        option['color'] = Colors.red;
                        option['textColor'] = Colors.white;
                        for (var op in options) {
                          if (op['date'] == dateIndex) {
                            op['color'] = Colors.green;
                            op['textColor'] = Colors.white;
                            break;
                          }
                        }
                        duration = 800;
                        progressList[progressValue] = -1;
                      }
                    });
                    context.read<ProgressNotifier>().update();
      
                    if (progressValue == dateCount-1) {
                      Future.delayed(const Duration(milliseconds: 600), () {
                        Navigator.of(context, rootNavigator: true).pushReplacement(
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) => const ResultsPage(),
                            transitionDuration: const Duration(milliseconds: 400),
                            transitionsBuilder: (
                              _, animation, secondaryAnimation, child
                            ) => 
                            FadeThroughTransition(
                              animation: animation,
                              secondaryAnimation: secondaryAnimation,
                              //transitionType: SharedAxisTransitionType.horizontal,
                              child: child
                            ),
                          ),
                        );
                      });
                      return;
                    }
          
                    Future.delayed(Duration(milliseconds: duration), () {
                      dates.removeLast();
                      dates.shuffle();
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => Quiz(dates: dates),
                          transitionDuration: const Duration(milliseconds: 400),
                          transitionsBuilder: (
                            _, animation, secondaryAnimation, child
                          ) => 
                          SharedAxisTransition(
                            animation: animation,
                            secondaryAnimation: secondaryAnimation,
                            transitionType: SharedAxisTransitionType.horizontal,
                            child: child
                          ),
                        ),
                      );
                    });
                    
                    progressValue++;
                    setState(() => enabled = false);
                  },
                ),
              ),
            ]
          ),
          const SizedBox(height: 6),
          LinearTimer(
            controller: timerController,
            duration: const Duration(seconds: 8),
            forward: false,
            onTimerEnd: () {
              progressList[progressValue] = 2;
              setState(() {
                for (var op in options) {
                  if (op['date'] == dateIndex) {
                    op['color'] = Colors.green;
                    op['textColor'] = Colors.white;
                    break;
                  }
                }
              });
              context.read<ProgressNotifier>().update();
      
              if (progressValue == dateCount-1) {
                Future.delayed(const Duration(milliseconds: 600), () {
                  Navigator.of(context, rootNavigator: true).pushReplacement(
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => const ResultsPage(),
                      transitionDuration: const Duration(milliseconds: 400),
                      transitionsBuilder: (
                        _, animation, secondaryAnimation, child
                      ) => 
                      FadeThroughTransition(
                        animation: animation,
                        secondaryAnimation: secondaryAnimation,
                        //transitionType: SharedAxisTransitionType.horizontal,
                        child: child
                      ),
                    ),
                  );
                });
                return;
              }
      
              progressValue++;
              Future.delayed(const Duration(milliseconds: 1500), () {
                dates.removeLast();
                dates.shuffle();
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => Quiz(dates: dates),
                    transitionDuration: const Duration(milliseconds: 400),
                    transitionsBuilder: (
                      _, animation, secondaryAnimation, child
                    ) => 
                    SharedAxisTransition(
                      animation: animation,
                      secondaryAnimation: secondaryAnimation,
                      transitionType: SharedAxisTransitionType.horizontal,
                      child: child
                    ),
                  ),
                );
              });
            },
          )
        ],
      )
    );
  }
}

class QuizNavigator extends StatefulWidget {
  const QuizNavigator({super.key});

  @override
  State<QuizNavigator> createState() => _QuizNavigatorState();
}

class _QuizNavigatorState extends State<QuizNavigator> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  List dates = [];

  void prepareData() {
    units.forEach((key, value) {
      if (value) {
        List keys = hisgeoObject!["التواريخ"][key].keys.toList();
        keys.shuffle();
        for (int i = 0; i < dateCount+4 ~/ unitCount(); i++) {
          dates.add("${keys[i]}:${hisgeoObject!['التواريخ'][key][keys[i]]}");
        }
      }
    });
    dates.shuffle();
  }

  @override
  void initState() {
    prepareData();
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ProgressNotifier(),
      child: Scaffold(
        appBar: AppBar(
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(8),
            child: Container(
              //height: 6,
              alignment: Alignment.bottomCenter,
              padding: const EdgeInsets.only(right: 4),
              child: Consumer<ProgressNotifier>(
                builder:(context, value, child) {
                  /* if (progressList.last != 0) {
            
                  } */
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: List.generate(progressList.length, (index) {
                      var progress = progressList[index];
                      var color = colorScheme(context).secondaryContainer; //Colors.grey[200]!.withOpacity(0.8);
                      switch (progress) {
                        case 1:
                          color = Colors.green;
                        case -1:
                          color = Colors.red;
                        case 2:
                          color = Colors.grey[700]!.withOpacity(0.9);
                      }
                      
                      return Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: 6,
                          margin: const EdgeInsets.only(left: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: color
                          ),
                        ),
                      );
                    }).reversed.toList() 
                  );
                },
              ),
            ),
          ),
        ),
        body: Navigator(
          key: _navigatorKey,
          initialRoute: '/',
          onGenerateRoute: (settings) {
            return PageRouteBuilder(
              pageBuilder:(context, animation, secondaryAnimation) {
                return Quiz(dates: dates);
              },
              transitionDuration: const Duration(milliseconds: 300),
              transitionsBuilder: (
                _, animation, secondaryAnimation, child
              ) => 
              SharedAxisTransition(
                animation: animation,
                secondaryAnimation: secondaryAnimation,
                transitionType: SharedAxisTransitionType.horizontal,
                child: child
              ),
              settings: settings,
            );
          },
        ),
      ),
    );
  }
}

class ResultsPage extends StatefulWidget {
  const ResultsPage({super.key});

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}


class _ResultsPageState extends State<ResultsPage> {
  double end = progressList.where((e) => e == 1).length / progressList.length;
  

  @override
  void initState() {
    loadRewardedAd();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0EFFF),
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            //SizedBox(height: 20,),
            SizedBox(
              height: 200,
              width: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  /* Container(
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(200)
                    ),
                  ), */
                  Text(
                    "${progressList.where((e) => e == 1).length}/${progressList.length}",
                    style: GoogleFonts.nunito(
                      fontSize: 45,
                      fontWeight: FontWeight.bold,
                      color: colorScheme(context).onPrimaryContainer.withValues(alpha: 0.7)
                    ),/* TextStyle(
                      fontSize: 45,
                      fontWeight: FontWeight.bold,
                      
                      fontFamily: 'Noto Sans Display',
                      color: colorScheme(context).onPrimaryContainer.withValues(alpha: 0.7)
                    ), */
                  ).animate(
                    delay: const Duration(milliseconds: 1000),
                    effects: [
                      const FadeEffect(
                        curve: Curves.ease,
                        begin: 0,
                        end: 1,
                        duration: Duration(milliseconds: 600)
                      ),
                    ]
                  ),
                  
                  SizedBox(
                    height: 200,
                    width: 200,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.0, end: end),
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.ease,
                      builder: (context, value, _) => CircularProgressIndicator(
                        value: value,
                        strokeWidth: 12,
                        strokeCap: StrokeCap.round,
                        backgroundColor: colorScheme(context).primaryContainer,
                      ),
                    ),
                  ),
                ],
              )
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton.filledTonal(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    iconSize: 50,
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(
                        colorScheme(context).primary
                      ),
                    ),
                    icon: const Icon(
                      Icons.refresh_rounded,
                      color: Colors.white,
                    )
                  ),
                  const SizedBox(height: 20),
                  const Text('اعادة')
                ],
              )
            )
          ],
        ),
      ),
    );
  }
}

class ProgressNotifier extends ChangeNotifier {
  void update() {
    notifyListeners();
  }
}