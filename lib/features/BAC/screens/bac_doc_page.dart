import 'package:bacassistant/features/BAC/bloc/bac_bloc.dart';
import 'package:bacassistant/features/BAC/bloc/bac_doc_event.dart';
import 'package:bacassistant/features/BAC/bloc/bac_doc_state.dart';
import 'package:bacassistant/features/BAC/models/bac_document.dart';
import 'package:bacassistant/utils/initializer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdfrx/pdfrx.dart';

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
      subject:
          subject ?? prefs.getString('chosenSubject') ?? 'علوم الطبيعة والحياة',
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
                child: Text(
                    'Error: ${state.message}\nDocument Path: ${state.documentPath}'),
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
  bool _showCorrection = false;

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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final selectedPath =
        _showCorrection ? widget.correctionPath : widget.documentPath;
    final subject = prefs.getString('chosenSubject') ?? 'علوم الطبيعة والحياة';

    final appBar = _fullscreen
        ? null
        : AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: colorScheme.surface,
            elevation: 0,
            scrolledUnderElevation: 0,
            titleSpacing: 0,
            leading: IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back_rounded, size: 28),
              color: colorScheme.onSurface,
            ),
            title: Text(
              'بكالوريا ${widget.year} - $subject',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                  ),
            ),
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.more_vert_rounded, size: 24),
                color: colorScheme.onSurface,
              ),
            ],
          );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: appBar,
        body: _fullscreen
            ? Stack(
                children: [
                  Positioned.fill(
                    child: PdfViewer.file(
                      selectedPath,
                      params: const PdfViewerParams(
                        scrollPhysics: BouncingScrollPhysics(),
                        sizeDelegateProvider:
                            PdfViewerSizeDelegateProviderLegacy(
                          minScale: 0.75,
                          maxScale: 2.5,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: IconButton(
                      onPressed: _exitFullscreen,
                      style: IconButton.styleFrom(
                        backgroundColor:
                            colorScheme.surface.withValues(alpha: 0.92),
                        foregroundColor: colorScheme.onSurface,
                      ),
                      icon: const Icon(Icons.fullscreen_exit_rounded),
                    ),
                  ),
                ],
              )
            : SafeArea(
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: Container(
                        height: 52,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: colorScheme.outlineVariant,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () =>
                                    setState(() => _showCorrection = false),
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: !_showCorrection
                                        ? colorScheme.primary
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'الموضوع',
                                    style: TextStyle(
                                      color: !_showCorrection
                                          ? colorScheme.onPrimary
                                          : colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () =>
                                    setState(() => _showCorrection = true),
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: _showCorrection
                                        ? colorScheme.primary
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'الحل',
                                    style: TextStyle(
                                      color: _showCorrection
                                          ? colorScheme.onPrimary
                                          : colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerLow,
                              border: Border.all(
                                color: colorScheme.outlineVariant,
                              ),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: SizedBox.expand(
                              child: PdfViewer.file(
                                selectedPath,
                                params: const PdfViewerParams(
                                  scrollPhysics: BouncingScrollPhysics(),
                                  sizeDelegateProvider:
                                      PdfViewerSizeDelegateProviderLegacy(
                                    minScale: 0.75,
                                    maxScale: 2.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.primary,
                                foregroundColor: colorScheme.onPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.print_rounded),
                                  SizedBox(width: 8),
                                  Text('طباعة'),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _enterFullscreen,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: colorScheme.primary,
                                side: BorderSide(
                                  color: colorScheme.primary,
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.open_in_new_rounded),
                                  SizedBox(width: 8),
                                  Text('فتح'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
