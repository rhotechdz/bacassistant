import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:share_plus/share_plus.dart';

class BacPDFViewer extends StatefulWidget {
  final String filePath;
  final String correctionPath;

  const BacPDFViewer({
    super.key,
    required this.filePath,
    required this.correctionPath,
  });

  @override
  State<BacPDFViewer> createState() => _BacPDFViewerState();
}

class _BacPDFViewerState extends State<BacPDFViewer> {
  late final PageController _pageController;
  int _currentPage = 0;
  bool _toggleUI = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _exitFullscreen();
    super.dispose();
  }

  void _enterFullscreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _exitFullscreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  void _onSwipe(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;

    if (velocity > 50) {
      setState(() {
        _currentPage = 0;
      });
      debugPrint("Swiped Left to Right → First PDF");
    } else if (velocity < -50) {
      setState(() {
        _currentPage = 1;
      });
      debugPrint("Swiped Right to Left → Second PDF");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _toggleUI
          ? AppBar(
              title: Text(_currentPage == 0 ? "Document" : "Correction"),
              backgroundColor: Colors.blue,
              actions: [
                IconButton(
                  icon: Icon(Icons.print),
                  onPressed: () async {
                    final params = ShareParams(
                        files: [_currentPage == 0 ? XFile(widget.filePath) : XFile(widget.correctionPath)],
                      );

                      final result = await SharePlus.instance.share(params);

                      if (result.status == ShareResultStatus.success) {
                        print('Thank you for sharing the picture!');
                      }
                  },
                ),
              ],
            )
          : null,
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            switchInCurve: Curves.easeIn,   // fade in curve
            switchOutCurve: Curves.easeOut, // fade out curve
            child: _currentPage == 0
                ? PDFView(
                    key: const ValueKey("firstPDF"),
                    filePath: widget.filePath,
                    pageSnap: false,
                    pageFling: false,
                    autoSpacing: false,
                    fitPolicy: FitPolicy.WIDTH,
                    onError: (error) {
                      debugPrint("Error displaying PDF: $error");
                    },
                  )
                : PDFView(
                    key: const ValueKey("secondPDF"),
                    filePath: widget.correctionPath,
                    pageSnap: false,
                    pageFling: false,
                    autoSpacing: false,
                    fitPolicy: FitPolicy.WIDTH,
                    onError: (error) {
                      debugPrint("Error displaying PDF: $error");
                    },
                  ),
          ),

          // swipe control area
          Align(
            alignment: Alignment.bottomCenter,
            child: RawGestureDetector(
              behavior: HitTestBehavior.translucent,
              gestures: {
                HorizontalDragGestureRecognizer:
                    GestureRecognizerFactoryWithHandlers<HorizontalDragGestureRecognizer>(
                  () => HorizontalDragGestureRecognizer(),
                  (HorizontalDragGestureRecognizer instance) {
                    instance.onEnd = _onSwipe;
                  },
                ),
              },
              child: Container(
                height: MediaQuery.of(context).size.height * 0.15,
                alignment: Alignment.center,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              debugPrint("Tapped");
              setState(() {
                _toggleUI = !_toggleUI;
              });
              if (_toggleUI) {
                _exitFullscreen();
              } else {
                _enterFullscreen();
              }
            },
          )
        ],
      ),
      floatingActionButton: _toggleUI
          ? FloatingActionButton(onPressed: () {})
          : null,
    );
  }
}