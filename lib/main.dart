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
import 'package:bacassistant/themes/dark_theme.dart';
import 'package:bacassistant/themes/light_theme.dart';
import 'package:bacassistant/utils/constants.dart';
import 'package:bacassistant/utils/initializer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
  );
  await Initializer.run();
  fieldList = fieldDict.keys.toList();
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
          theme: lightTheme,
          darkTheme: darkTheme,
          builder: (context, child) => Directionality(
                textDirection: TextDirection.rtl,
                child: child!,
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

const Map<String, IconData> fieldIcons = {
  'شعبة علوم تجريبية': Icons.biotech_outlined,
  'شعبة آداب وفلسفة': Icons.menu_book_outlined,
  'شعبة لغات أجنبية': Icons.translate_outlined,
  'شعبة تسيير واقتصاد': Icons.business_center_outlined,
  'شعبة رياضيات': Icons.calculate_outlined,
  'شعبة تقني رياضي': Icons.engineering_outlined,
};

Widget fieldPicker(BuildContext context, Function setState) {
  final availableFields =
      fieldList.isEmpty ? fieldDict.keys.toList() : fieldList;
  final selectedField = prefs.getString('chosenField');
  final colorScheme = Theme.of(context).colorScheme;

  return Column(
    mainAxisSize: MainAxisSize.min,
    children: List.generate(
      availableFields.length,
      (index) {
        final field = availableFields[index] as String;
        final isSelected = field == selectedField;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Material(
            color: isSelected
                ? colorScheme.primaryContainer
                : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.of(context).pop();
                setState(() {
                  prefs.setString('chosenField', field);
                  prefs.setString(
                    'chosenSubject',
                    subjectsMap[field].keys.elementAt(0),
                  );
                  chosenField = field;
                  chosenSubject = subjectsMap[field].keys.elementAt(0);
                });
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                child: Row(
                  children: [
                    Icon(
                      fieldIcons[field] ?? Icons.school_outlined,
                      color: isSelected
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurfaceVariant,
                      size: 25,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        field,
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? colorScheme.onPrimaryContainer
                                      : colorScheme.onSurface,
                                ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      isSelected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.outline,
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
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
