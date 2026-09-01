

import 'package:bacassistant/features/BAC/bloc/bac_bloc.dart';
import 'package:bacassistant/features/BAC/bloc/bac_doc_event.dart';
import 'package:bacassistant/features/BAC/bloc/bac_doc_state.dart';
import 'package:bacassistant/features/BAC/models/bac_document.dart';
import 'package:bacassistant/utils/initializer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:share_plus/share_plus.dart';

class BacDocViewer extends StatelessWidget {
  final int year;
  final String? subject;
  final String? field;

  BacDocViewer({
    super.key,
    required this.year,
    this.subject,
    this.field,
  }) {
    _currentDocument = BacDocument(
      year: year,
      subject: subject ?? prefs.getString('chosenSubject') ?? 'علوم الطبيعة والحياة',
      field: field ?? prefs.getString('chosenField') ?? 'شعبة علوم تجريبية',
    );
  }

  late final BacDocument _currentDocument;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => BacBloc(_currentDocument)..add(Initializing()),
        child: BlocBuilder<BacBloc, BacDocState>(
          builder: (context, state) {
            if (state is BacDocInitial) {
              return const Center(child: Text('Initializing...'));
            }

            if (state is BacDocLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 20),
                    Text(state.status),
                  ],
                ),
              );
            }

            if (state is BacDocReady) {
              return BacOverviewPage(
                documentPath: state.documentPath,
                correctionPath: state.correctionPath,
                year: year,
              );
            }

            if (state is BacDocError) {
              return Center(
                child: Text('Error: ${state.message}\nDocument Path: ${state.documentPath}'),
              );
            }

            return const Center(child: Text('Unknown state'));
          },
        ),
      ),
    );
  }
}

class BacOverviewPage extends StatefulWidget {
  final String documentPath;
  final String correctionPath;
  final int year;

  const BacOverviewPage({
    super.key,
    required this.documentPath,
    required this.correctionPath,
    required this.year,
  });

  @override
  State<BacOverviewPage> createState() => _BacOverviewPageState();
}

class _BacOverviewPageState extends State<BacOverviewPage> {
  bool _fullscreen = false;

  @override
  void dispose() {
    _exitFullscreen();
    super.dispose();
  }

  void _enterFullscreen() {
    setState(() => _fullscreen = true);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _exitFullscreen() {
    setState(() => _fullscreen = false);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  Future<void> _sharePdf(String path) async {
    await SharePlus.instance.share(
      ShareParams(files: [XFile(path)]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appBar = _fullscreen
        ? null
        : AppBar(
            title: Text('Bac ${widget.year}'),
            actions: [
              IconButton(
                icon: const Icon(Icons.print),
                onPressed: () => _sharePdf(widget.documentPath),
                tooltip: 'Print document',
              ),
              IconButton(
                icon: const Icon(Icons.print_outlined),
                onPressed: () => _sharePdf(widget.correctionPath),
                tooltip: 'Print correction',
              ),
              IconButton(
                icon: Icon(_fullscreen ? Icons.fullscreen_exit : Icons.fullscreen),
                onPressed: () {
                  if (_fullscreen) {
                    _exitFullscreen();
                  } else {
                    _enterFullscreen();
                  }
                },
              ),
            ],
          );

    return Scaffold(
      appBar: appBar,
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            if (!_fullscreen)
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _sharePdf(widget.documentPath),
                      icon: const Icon(Icons.print),
                      label: const Text('Print document'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _sharePdf(widget.correctionPath),
                      icon: const Icon(Icons.picture_as_pdf_outlined),
                      label: const Text('Print correction'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton.filled(
                    onPressed: () {
                      if (_fullscreen) {
                        _exitFullscreen();
                      } else {
                        _enterFullscreen();
                      }
                    },
                    icon: Icon(_fullscreen ? Icons.fullscreen_exit : Icons.fullscreen),
                  ),
                ],
              ),
            const SizedBox(height: 12),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 720;
                  final children = [
                    Expanded(
                      child: _PdfCard(
                        title: 'Document',
                        path: widget.documentPath,
                      ),
                    ),
                    const SizedBox(width: 12, height: 12),
                    Expanded(
                      child: _PdfCard(
                        title: 'Correction',
                        path: widget.correctionPath,
                      ),
                    ),
                  ];

                  return isWide
                      ? Row(children: children)
                      : Column(children: children);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PdfCard extends StatelessWidget {
  final String title;
  final String path;

  const _PdfCard({
    required this.title,
    required this.path,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            width: double.infinity,
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: PdfViewer.file(
              path,
              params: const PdfViewerParams(
                sizeDelegateProvider: PdfViewerSizeDelegateProviderLegacy(
                  minScale: 0.75,
                  maxScale: 2.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}