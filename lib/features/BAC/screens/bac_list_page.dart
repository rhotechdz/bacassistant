
import 'package:bacassistant/features/BAC/screens/bac_doc_page.dart';
import 'package:bacassistant/main.dart';
import 'package:bacassistant/utils/initializer.dart';
import 'package:flutter/material.dart';

class BacPage extends StatefulWidget {
  
  const BacPage({super.key});
  
  @override
  State<BacPage> createState() => _BacPageState();
}

class _BacPageState extends State<BacPage> {

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
      appBar: AppBar(
        centerTitle: true,
        title: InkWell(
          child: Text(
            prefs.getString("chosenSubject")!,
            style: const TextStyle(fontWeight: FontWeight.bold)
          ),
          onTap: () {
            showDialog(
              context: context,
              builder: (_) {
                return AlertDialog(
                  scrollable: true,
                  content: subjectsPicker(context, setState)
                );
              }
            );
          },
        ),
      ),
      body: ListView.separated(
        itemCount: 11,
        padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 10.0),
        separatorBuilder: (context, index) {
          return const SizedBox(height: 4);
        },
        itemBuilder: (context, index) {
          final int year = (2012+index);
          return ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(10),
              elevation: 2,
              shadowColor: Colors.transparent,
              /* shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ), */
              backgroundColor: Theme.of(context).colorScheme.primaryContainer //.withOpacity(0.8)
            ),
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return BacDocViewer(year: year);
                  }
                )
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: Text(
                "مواضيع وحلول بكالوريا $year",
                textAlign: TextAlign.end,
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer
                ),
              ),
            ),
          );
        },
      ),
      /* bottomNavigationBar: adService.bannerAd != null 
      ? SizedBox(
        width: adService.bannerAd!.size.width.toDouble(),
        height: adService.bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: adService.bannerAd!),
      )
      : null, */
    );
  }
}