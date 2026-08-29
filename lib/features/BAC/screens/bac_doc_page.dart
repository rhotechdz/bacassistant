

import 'package:bacassistant/features/BAC/models/bac_doc_viewer.dart';
import 'package:bacassistant/features/BAC/models/bac_document.dart';
import 'package:bacassistant/features/BAC/bloc/bac_bloc.dart';
import 'package:bacassistant/features/BAC/bloc/bac_doc_event.dart';
import 'package:bacassistant/features/BAC/bloc/bac_doc_state.dart';
import 'package:bacassistant/utils/initializer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BacDocViewer extends StatelessWidget {
  final int year;
  late final BacDocument currentDocument;

  BacDocViewer({super.key, required this.year}) {
    currentDocument = BacDocument(
      year: year,
      subject: prefs.getString('chosenSubject')!,
      field: prefs.getString('chosenField')!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => BacBloc(
          currentDocument
        )..add(Initializing()),
        child: BlocBuilder<BacBloc, BacDocState>(
          builder: (context, state) {
            if (state is BacDocInitial) {
              return const Center(child: Text('Initializing...'));
            } else if (state is BacDocLoading) {
              debugPrint("Loading state: ${state.progress}, ${state.status}");
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text(state.status)
                  ],
                )
              );
            } else if (state is BacDocReady) {
              return BacPDFViewer(filePath: currentDocument.path, correctionPath: currentDocument.correctionPath);
            } else if (state is BacDocError) {
              return Center(child: Text('Error: ${state.message}\nDocument Path: ${state.documentPath}'));
            } else {
              return const Center(child: Text('Unknown state'));
            }
          },
        ),
      ),
    );
  }
}