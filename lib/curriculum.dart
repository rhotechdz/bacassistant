
import 'package:auto_size_text/auto_size_text.dart';
import 'package:bacassistant/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:url_launcher/url_launcher.dart';

class CurriculumPage extends StatefulWidget {
  const CurriculumPage({super.key});

  @override
  State<CurriculumPage> createState() => _CurriculumPageState();
}

class _CurriculumPageState extends State<CurriculumPage> {
  List keys = [];
  dynamic lessons = [];
  bool expandable = false;
  Widget? buildWidget; 
  List<Widget> children = [];
  BannerAd? bannerAd;

  Future<void> _launchUrl(url) async {
    if (!await launchUrl(url)) {
      throw 'Could not launch $url';
    }
  }

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

  void prepData() {

    if (curriculum!.keys.toList().contains(chosenSubject)) {
      curriculum![chosenSubject].forEach((value) {
        if (value["الشعب"] is int || value["الشعب"].contains(chosenField)) {
          lessons = value['الدروس'];
        }
      });
      List output = [];

      parseEntry(lessons, 0, output);

      children = [
        const SizedBox(),
        ...output.map<Widget>((element) => convert(element))
      ];

      buildWidget = ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          return children[index];
        },
        itemCount: children.length
      );
      
    } else {
      buildWidget = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48
            ),
            const SizedBox(height: 30),
            Text(
              "لا توجد مراجع لهذه المادة",
              style: txtTheme(context).headlineSmall!,
            ),
          ]
        ),
      );
    }
  }

  parseEntry(element, index, path, [key]) {
    if (key != null) keys.add(key);

    if (element is Map) {
      element.keys.toList().asMap().entries.forEach((entry) {
        path.add([]);
        parseEntry(element[entry.value], entry.key, path[entry.key], entry.value);
      });
    } else {
      element.forEach((e) => path.add(e));
    }
  }

  convert(element) {
    if (element is List) {
      String key = keys.removeAt(0);
      expandable = true;

      return ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        backgroundColor: colorScheme(context).primaryContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0)
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0)
        ),
        collapsedBackgroundColor: colorScheme(context).primaryContainer,
        collapsedTextColor: Theme.of(context).primaryColor,
        title: AutoSizeText(
          key,
          overflow: TextOverflow.fade,
          maxFontSize: 18,
          textAlign: key.contains('e') ? TextAlign.start : TextAlign.end,
          style: txtTheme(context).headlineSmall!.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme(context).onPrimaryContainer
          )
        ),
        children: element.map<Widget>((e) => convert(e)).toList(),
      );
    } else {
      return Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30.0),
          color: colorScheme(context).primaryContainer
        ),
        
        child: InkWell(
          borderRadius: BorderRadius.circular(30.0),
          onTap: (() {
            _launchUrl(Uri.parse(
              'https://youtube.com/results?search_query=$element+باك+$chosenField')
            );
          }),
          onLongPress: () {
            Clipboard.setData(ClipboardData(text: element)).then((_) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                duration: Duration(seconds: 1),
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      Icons.done,
                      color: Colors.white,
                    ),
                    Text(
                      'تم النسخ',
                      textAlign: TextAlign.end,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ))
            );
          });
          },
          child: Container(
            alignment: element.contains('e')
            ? Alignment.centerLeft
            : Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 22),
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30.0)
            ),
            child: AutoSizeText(
              element,
              maxLines: 1,
              textDirection: TextDirection.ltr,
              textAlign: element.contains('e') ? TextAlign.start : TextAlign.end,
              style: const TextStyle(
                fontSize: 20
              ),
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    prepData();
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: InkWell(
          child: Text(
            chosenSubject!,
            style: const TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          onTap: () {
            showDialog(
              context: context,
              builder: (_) {
                return AlertDialog(
                  scrollable: true,
                  content: subjectsPicker(context, setState, prepData)
                );
              }
            );
          },
        ),
      ),
      body: buildWidget,
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
