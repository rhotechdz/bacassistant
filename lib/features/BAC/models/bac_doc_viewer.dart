export 'package:bacassistant/features/BAC/screens/bac_doc_page.dart';

import 'package:bacassistant/features/BAC/screens/bac_doc_page.dart';

class BacPDFViewer extends BacOverviewPage {
  BacPDFViewer({
    super.key,
    required String filePath,
    required String correctionPath,
  }) : super(
          documentPath: filePath,
          correctionPath: correctionPath,
          year: DateTime.now().year,
        );
}