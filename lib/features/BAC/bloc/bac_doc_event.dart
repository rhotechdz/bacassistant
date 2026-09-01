

abstract class BacDocEvent {}

class Initializing extends BacDocEvent {}

class DownloadSubject extends BacDocEvent {}

class DownloadCorrection extends BacDocEvent {}

class SwitchDocument extends BacDocEvent {
  final String documentPath;

  SwitchDocument(this.documentPath);
}

class Ready extends BacDocEvent {
  final String documentPath;
  final String correctionPath;

  Ready(this.documentPath, this.correctionPath);
}

class Error extends BacDocEvent {
  final String message;
  final String documentPath;

  Error(this.message, this.documentPath);
}