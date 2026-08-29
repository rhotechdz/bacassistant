import 'package:bacassistant/features/BAC/screens/bac_list_page.dart';
import 'package:bacassistant/features/grade_calculator/screens/grade_calculator.dart';
import 'package:bacassistant/quiz.dart';
import 'package:bacassistant/screens/home.dart';
import 'package:bacassistant/screens/introduction_flow/introduction_flow.dart';
import 'package:bacassistant/screens/login.dart';
import 'package:bacassistant/services/google_sign_in/auth_bloc.dart';
import 'package:bacassistant/services/google_sign_in/auth_event.dart';
import 'package:bacassistant/services/google_sign_in/auth_state.dart';
import 'package:bacassistant/themes/bloc/theme.dart';
import 'package:bacassistant/utils/constants.dart';
import 'package:bacassistant/utils/initializer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Initializer.run();
  runApp(MultiBlocProvider(
    providers: [
      BlocProvider(create: (_) => ThemeBloc()),
      BlocProvider(create: (_) => AuthBloc()..add(AppStarted())),
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(builder: (context, state) {
      return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'BAC Guide',
          themeMode: state.themeMode,
          darkTheme: ThemeData.dark(),
          //theme: lightTheme,
          theme: ThemeData(
            fontFamily: 'Tajawal',
            colorScheme: ColorScheme.fromSeed(
              seedColor:
                  Colors.deepPurpleAccent, // change seed for your brand color
              brightness: Brightness.light,
            ),
          ),
          routes: {
            '/grade_calculator': (context) => GradeCalculatorPage(),
            '/bac_list': (context) => BacPage(),
            '/quiz': (context) => QuizPage(),
          },
          home: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthInitial || state is AuthLoading) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (state is Authenticated) {
                return const HomePage();
              }

              return prefs.getBool('firstRun') == true
                  ? const IntroductionFlow()
                  : const LoginPage();
            },
          ));
    });
  }
}

Widget subjectsPicker(BuildContext context, Function setState,
    [Function? callback]) {
  final String field = prefs.getString('chosenField')!;
  final List elements = subjectsMap[field].keys.toList();
  elements.removeLast();

  return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
          elements.length,
          (index) => InkWell(
                borderRadius: BorderRadius.circular(20.0),
                child: Container(
                  height: 60,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(20.0)),
                  child: Text(
                    ' ${elements[index]} ',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  setState(() {
                    prefs.setString('chosenSubject', elements[index]);
                    chosenSubject = elements[index];
                  });
                },
              )));
}

Widget fieldPicker(BuildContext context, Function setState) {
  return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
          fieldList.length,
          (index) => InkWell(
                borderRadius: BorderRadius.circular(20.0),
                child: Container(
                  height: 50,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(20.0)),
                  child: Text(
                    ' ${fieldList[index]} ',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                onTap: () {
                  String field = fieldList[index];
                  Navigator.of(context).pop();
                  setState(() {
                    prefs.setString('chosenField', field);
                    prefs.setString(
                        'chosenSubject', subjectsMap[field].keys.elementAt(0));
                    chosenField = fieldList[index];
                    chosenSubject = subjectsMap[field].keys.elementAt(0);
                  });
                },
              )));
}

void loadInterstitialAd() {
  int? adCounter = prefs.getInt('adCounter');
  debugPrint('adCounter: $adCounter');
  if (adCounter! >= 2) {
    adService.loadInterstitialAd();
    prefs.setInt('adCounter', 0);
  } else {
    prefs.setInt('adCounter', adCounter + 1);
  }
}

void loadRewardedAd() {
  int? adCounter = prefs.getInt('adCounter');
  debugPrint('adCounter: $adCounter');
  if (adCounter! >= 1) {
    adService.loadRewardedInterstitialAd();
    prefs.setInt('adCounter', 0);
  } else {
    prefs.setInt('adCounter', adCounter + 1);
  }
}
