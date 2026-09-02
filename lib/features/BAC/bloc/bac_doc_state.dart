abstract class BacDocState {}

class BacDocInitial extends BacDocState {}

class BacDocLoading extends BacDocState {
  final double progress;
  final String status;

  BacDocLoading(this.progress, this.status);

  List<Object?> get props => [progress, status];
}

class BacDocReady extends BacDocState {
  final String documentPath;
  final String correctionPath;

  BacDocReady(this.documentPath, this.correctionPath);
}

class BacDocError extends BacDocState {
  final String message;
  final String documentPath;
  final bool isOffline;

  BacDocError(this.message, this.documentPath, {this.isOffline = false});
}
