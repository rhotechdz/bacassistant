import 'package:bacassistant/features/BAC/services/bac_availability_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BacAvailabilityService', () {
    test('parses available PDF names and excludes corrections', () {
      final files = BacAvailabilityService.parseFileNames([
        '2023/physics-maths-2023.pdf',
        '2023/correction-physics-maths-2023.pdf',
        '2023/notes.txt',
      ]);

      expect(files, {'physics-maths-2023.pdf'});
    });

    test('matches regular and field-independent subjects', () {
      expect(
        BacAvailabilityService.documentIsAvailable(
          files: {'physics-maths-2023.pdf'},
          year: 2023,
          subject: 'العلوم الفيزيائية',
          field: 'شعبة رياضيات',
        ),
        isTrue,
      );
      expect(
        BacAvailabilityService.documentIsAvailable(
          files: {'islam-2023.pdf'},
          year: 2023,
          subject: 'العلوم الإسلامية',
          field: 'شعبة رياضيات',
        ),
        isTrue,
      );
      expect(
        BacAvailabilityService.documentIsAvailable(
          files: {'physics-maths-2023.pdf'},
          year: 2023,
          subject: 'الإعلام الآلي',
          field: 'شعبة رياضيات',
        ),
        isFalse,
      );
    });
  });
}
