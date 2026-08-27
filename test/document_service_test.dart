import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/models/document_model.dart';
import 'package:flutter_application_1/services/document_service.dart';
import 'package:flutter_application_1/screens/patient/patient_documents_screen.dart';
import 'package:flutter_application_1/screens/patient/patient_bills_screen.dart';

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({
      'access_token': 'mock_valid_token_test',
      'user_id': 'pat_test_001',
      'user_role': 'patient',
    });
  });

  group('Phase 5 Document Model & Service Tests', () {
    test('DocumentModel serializes and parses JSON correctly', () {
      final json = {
        'id': 'doc_123',
        'patient_id': 'pat_001',
        'physiotherapist_id': 'phys_001',
        'file_id': 'gridfs_file_999',
        'file_name': 'patients/pat_001/xray_report.pdf',
        'original_file_name': 'Knee_XRay_Report.pdf',
        'file_type': 'pdf',
        'mime_type': 'application/pdf',
        'file_size': 2516582,
        'file_size_formatted': '2.4 MB',
        'document_category': 'Reports',
        'description': 'Post-op radiological evaluation',
        'uploaded_by': 'phys_001',
        'uploaded_by_role': 'physiotherapist',
        'uploaded_by_name': 'Dr. Sharma',
        'appointment_id': 'app_001',
        'clinical_note_id': 'note_001',
        'assessment_id': 'ass_001',
        'download_url': '/api/v1/patients/pat_001/documents/gridfs_file_999/download',
        'created_at': '2026-08-15T10:30:00.000Z',
        'is_active': true,
      };

      final doc = DocumentModel.fromJson(json);

      expect(doc.id, 'doc_123');
      expect(doc.patientId, 'pat_001');
      expect(doc.physiotherapistId, 'phys_001');
      expect(doc.fileId, 'gridfs_file_999');
      expect(doc.originalFileName, 'Knee_XRay_Report.pdf');
      expect(doc.fileType, 'pdf');
      expect(doc.fileSizeFormatted, '2.4 MB');
      expect(doc.category, 'Reports');
      expect(doc.uploadedByName, 'Dr. Sharma');
      expect(doc.dateFormatted, contains('Aug 2026'));
      expect(doc.isActive, isTrue);

      final out = doc.toJson();
      expect(out['id'], 'doc_123');
      expect(out['original_file_name'], 'Knee_XRay_Report.pdf');
      expect(out['is_active'], isTrue);
    });

    test('DocumentService is a singleton', () {
      final s1 = DocumentService();
      final s2 = DocumentService();
      expect(identical(s1, s2), isTrue);
    });
  });

  group('Phase 5 Document UI Widget Tests', () {
    testWidgets('Renders PatientDocumentsScreen with filter chips and app bar', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: PatientDocumentsScreen(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('My Documents'), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Reports'), findsOneWidget);
      expect(find.text('Prescriptions'), findsOneWidget);
      expect(find.text('Imaging / Scan'), findsOneWidget);
    });

    testWidgets('Renders PatientBillsScreen with invoice headers', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: PatientBillsScreen(patientId: 'pat_test_001'),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('My Invoices & Receipts'), findsOneWidget);
      expect(find.text('Total Billed'), findsOneWidget);
      expect(find.text('Total Paid'), findsOneWidget);
      expect(find.text('Remaining Due'), findsOneWidget);
    });
  });
}
