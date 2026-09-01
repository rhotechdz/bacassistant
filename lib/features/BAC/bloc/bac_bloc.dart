

import 'package:bacassistant/features/BAC/bloc/bac_doc_event.dart';
import 'package:bacassistant/features/BAC/bloc/bac_doc_state.dart';
import 'package:bacassistant/features/BAC/models/bac_document.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BacBloc extends Bloc<BacDocEvent, BacDocState> {
  final BacDocument doc;

  BacBloc(this.doc) : super(BacDocInitial()) {
    on<Initializing>((event, emit) async {
      emit(BacDocInitial());
      add(DownloadSubject());
    });

    on<DownloadSubject>((event, emit) async {
      emit(BacDocLoading(0.1, 'Downloading subject...'));
      try {
        await doc.downloadDocument(correction: false);
        if (doc.exists(doc.path)) {
          add(DownloadCorrection());
        } else {
          add(Error('Document could not be downloaded.', doc.path));
        }
      } catch (e) {
        debugPrint('Error downloading document: $e');
        add(Error('Error downloading document: $e', doc.path));
      }
    });

    on<DownloadCorrection>((event, emit) async {
      emit(BacDocLoading(0.7, 'Downloading correction...'));
      try {
        await doc.downloadDocument(correction: true);
        if (doc.exists(doc.correctionPath)) {
          add(Ready(doc.path, doc.correctionPath));
        } else {
          add(Error('Correction could not be downloaded.', doc.correctionPath));
        }
      } catch (e) {
        debugPrint('Error downloading correction: $e');
        add(Error('Error downloading correction: $e', doc.correctionPath));
      }
    });

    on<SwitchDocument>((event, emit) {
      emit(BacDocReady(event.documentPath, doc.correctionPath));
    });

    on<Ready>((event, emit) {
      emit(BacDocReady(event.documentPath, event.correctionPath));
    });

    on<Error>((event, emit) {
      emit(BacDocError(event.message, event.documentPath));
    });
  }
}