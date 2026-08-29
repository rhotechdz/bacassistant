

import 'dart:io';

import 'package:bacassistant/features/BAC/models/bac_document.dart';
import 'package:bacassistant/features/BAC/bloc/bac_doc_event.dart';
import 'package:bacassistant/features/BAC/bloc/bac_doc_state.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class BacBloc extends Bloc<BacDocEvent, BacDocState> {
  final BacDocument doc;

  BacBloc(this.doc) : super(BacDocInitial()) {

    on<Initializing>((event, emit) {
      emit(BacDocInitial());
      add(DownloadSubject());
    });

    on<DownloadSubject>((event, emit) async {
      emit(BacDocLoading(0, "Downloading Subject..."));
      if (doc.exists(doc.path)) {
        emit(BacDocReady(doc.path));
      } else {
        try {
          final ref = FirebaseStorage.instance.ref()
            .child("BAC")
            .child(doc.year.toString())
            .child(doc.filename);

          final file = File(doc.path);
          DownloadTask downloadTask = ref.writeToFile(file);

          downloadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
            final progress = snapshot.bytesTransferred / snapshot.totalBytes;
            debugPrint("Download progress: ${(progress * 100).toStringAsFixed(2)}%");
          }, onError: (e) {
            debugPrint("Error downloading file: $e");
            add(Error("Error downloading file: $e", doc.path));
          }, onDone: () {
            add(DownloadCorrection());
          });
        } catch (e) {
          debugPrint("Error downloading file: $e");
        }
      }
    });

    on<DownloadCorrection>((event, emit) async {
      emit(BacDocLoading(0, "Downloading Correction..."));
      if (doc.exists(doc.correctionPath)) {
        debugPrint("Correction already exists at ${doc.correctionFilename}");
        emit(BacDocReady(doc.correctionPath));
      } else {
        debugPrint("Correction does not exist, starting download...");
        try {
          final ref = FirebaseStorage.instance.ref()
            .child("BAC")
            .child(doc.year.toString())
            .child(doc.correctionFilename);

          final file = File(doc.correctionPath);
          DownloadTask downloadTask = ref.writeToFile(file);

          downloadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
            final progress = snapshot.bytesTransferred / snapshot.totalBytes;
            debugPrint("Download progress: ${(progress * 100).toStringAsFixed(2)}%");
          }, onError: (e) {
            debugPrint("Error downloading file: $e");
            add(Error("Error downloading file: $e", doc.correctionPath));
          }, onDone: () {
            add(Ready(doc.correctionPath));
          });
        } catch (e) {
          debugPrint("Error downloading file: $e");
        }
      }
    });

    on<SwitchDocument>((event, emit) {
      

    });

    on<Ready>((event, emit) {
      emit(BacDocReady(event.documentPath));
    });

    on<Error>((event, emit) {
      emit(BacDocError(event.message, event.documentPath));
    });
  }
}