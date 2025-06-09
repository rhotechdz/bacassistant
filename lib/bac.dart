
import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:bacassistant/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';


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
        itemCount: bacList!.length,
        padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 10.0),
        separatorBuilder: (context, index) {
          return const SizedBox(height: 4);
        },
        itemBuilder: (context, index) {
          final String year = bacList![index].substring(11, 15);
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20)
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(10),
                elevation: 2,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                backgroundColor: Theme.of(context).colorScheme.primaryContainer //.withOpacity(0.8)
              ),
              onPressed: () async {
                Future.delayed(const Duration(milliseconds: 150))
                  .then((value) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) {
                          return BacViewer(
                            year: year,
                            excep: false
                          );
                        }
                      )
                    );
                  }
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Text(
                  "مواضيع وحلول بكالوريا $year",
                  textAlign: TextAlign.end,
                  style: txtTheme(context).headlineSmall!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer
                  ),
                ),
              ),
            ),
          );
        },
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

class BacViewer extends StatefulWidget {
  final String year;
  final bool excep;

  const BacViewer({
    super.key,
    required this.year,
    required this.excep
  });

  @override
  State<BacViewer> createState() => _BacViewerState();
}

class _BacViewerState extends State<BacViewer> 
  with TickerProviderStateMixin {
  List fileIds = [];
  late TabController _tabController;
  bool loadError = false;
  late Map bacObject;
  List<Widget> buildWidgets = [
    const Center(child: CircularProgressIndicator()),
    const Center(child: CircularProgressIndicator())
  ];

  void _handleTabSelection() {
    setState(() {
      if (loadError) return;
      buildWidgets[_tabController.index] = PDFView(
        filePath: '$appStorage/${fileIds[_tabController.index]}.pdf',
        pageSnap: false,
        pageFling: false,
        autoSpacing: false,
        fitPolicy: FitPolicy.WIDTH,
        onError: (error) {},
      );
    });
  }

  Future _downloadFile(String id, String filename) async {
    File('$appStorage/$filename').existsSync()
    ? null
    : await Dio().download(
      'https://docs.google.com/uc?export=download&id=$id',
      '$appStorage/$filename',
      options: Options(
        receiveTimeout: const Duration(seconds: 30)
      )
    );
  }

  Future prepData(String year, int type) async {
    if (buildWidgets[type].runtimeType != Center) return;
    final data = await rootBundle.loadString('assets/bac/$year.json');
    bacObject = await json.decode(data);
    final cf = prefs.getString('chosenField');
    final cs = prefs.getString('chosenSubject');
    fileIds = bacObject[cf][cs];
    
    _downloadFile(
      fileIds[type], '${fileIds[type]}.pdf'
    ).then((value) {
      setState(() {
        /* buildWidgets[type] = PdfViewPinch(
          controller: PdfControllerPinch(
            document: PdfDocument.openFile('$appStorage/${fileIds[type]}.pdf'),
          )
        ); */
        buildWidgets[type] = PDFView(
          filePath: '$appStorage/${fileIds[type]}.pdf',
          pageSnap: false,
          pageFling: false,
          autoSpacing: false,
          fitPolicy: FitPolicy.WIDTH,
          onError: (error) {},
        );
      });
    }, onError: (error) {
      setState(() {
        loadError = true;
        buildWidgets = List.generate(2, (index) {
          return Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded, size: 48),
                const SizedBox(height: 30),
                Text(
                  'تحقق من اتصالك بالإنترنت',
                  style: txtTheme(context).headlineSmall!.copyWith(
                    fontWeight: FontWeight.bold
                  ),
                ),
              ],
            )
          );
        });
        /* buildWidgets[type] = Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48),
              const SizedBox(height: 30),
              Text(
                'تحقق من اتصالك بالإنترنت',
                style: txtTheme(context).headlineSmall!.copyWith(
                  fontWeight: FontWeight.bold
                ),
              ),
            ],
          )
        ) */
    });
      return null;
    });
  }

  @override
  void initState() {
    super.initState();
    prepData(widget.year, 0);
    prepData(widget.year, 1);
    _tabController = TabController(
      initialIndex: 0,
      length: 2,
      vsync: this,
    );
    _tabController.addListener(_handleTabSelection);
    
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      centerTitle: true,
      title: Text(
        prefs.getString("chosenSubject")!,
        style: const TextStyle(fontWeight: FontWeight.bold)
      ),
      bottom: TabBar(
        controller: _tabController,
        tabs: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Text(
              'الموضوع',
              style: txtTheme(context).titleMedium!.copyWith(
                fontWeight: FontWeight.bold
              )
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Text(
              'الإجابة النموذجية',
              style: txtTheme(context).titleMedium!.copyWith(
                fontWeight: FontWeight.bold
              )
            ),
          )
        ],
      ),
      actions: [
        /* IconButton(
          onPressed: () {
            //OpenFile.open('$appStorage/${fileIds[_tabController.index]}.pdf');
          },
          icon: const Icon(
            Icons.open_in_new,
            size: 24,
          )
        ) */
      ],
    ),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          buildWidgets[0],
          buildWidgets[1]
        ]
      ),
    );
  }
}