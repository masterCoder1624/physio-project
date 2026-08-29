import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/models/patient_model.dart';
import 'package:flutter_application_1/screens/patient/add_patient_screen.dart';
import 'package:flutter_application_1/screens/patient/patient_dashboard.dart';

void main() {
  group('PatientModel', () {
    test('validates required fields and gender selection', () {
      final validPatient = PatientModel(
        name: 'Aditya Kumar',
        condition: 'Knee Injury Rehab',
        gender: 'Male',
      );

      expect(validPatient.validate(), isNull);

      final invalidPatient = PatientModel(name: 'A', condition: '');
      final validationMessage = invalidPatient.validate();

      expect(validationMessage, isNotNull);
      expect(validationMessage, contains('at least 2 characters'));
      expect(validationMessage, contains('Condition'));
    });

    test('creates a patient model from JSON data', () {
      final patient = PatientModel.fromJson({
        'name': 'Riya',
        'primary_condition': 'Back pain',
        'gender': 'Female',
        'physiotherapist_id': 'physio-123',
      });

      expect(patient.name, 'Riya');
      expect(patient.condition, 'Back pain');
      expect(patient.gender, 'Female');
      expect(patient.physioId, 'physio-123');
    });
  });

  group('AddPatientScreen UI Corrections', () {
    testWidgets('starts with empty input fields and NO pre-filled data', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(home: AddPatientScreen()),
      );
      await tester.pump();

      // Verify headers
      expect(find.text('Patient Information'), findsOneWidget);
      expect(find.text('Full Name'), findsOneWidget);

      // Verify no photo upload or avatar picker widgets
      expect(find.text('Add Photo'), findsNothing);
      expect(find.text('Upload Photo'), findsNothing);
      expect(find.byIcon(Icons.camera_alt_rounded), findsNothing);
      expect(find.byIcon(Icons.add_a_photo_rounded), findsNothing);

      // Verify text fields are present and empty
      final textFields = find.byType(TextField);
      expect(textFields, findsWidgets);

      for (final element in textFields.evaluate()) {
        final textField = element.widget as TextField;
        if (textField.controller != null) {
          expect(textField.controller!.text, isEmpty);
        }
      }
    });
  });

  group('Patient Multi-Screen Sliding Experience', () {
    testWidgets('renders all 7 horizontal section pills and PageView', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(home: PatientDashboard()),
      );
      await tester.pump();

      // Verify 7 section pills
      expect(find.text('Overview'), findsOneWidget);
      expect(find.text('Appointments'), findsOneWidget);
      expect(find.text('Exercises'), findsWidgets);
      expect(find.text('My Progress'), findsOneWidget);
      expect(find.text('Documents'), findsOneWidget);
      expect(find.text('Messages'), findsWidgets);
      expect(find.text('My Program'), findsOneWidget);

      // Verify PageView is present
      expect(find.byType(PageView), findsOneWidget);

      // Verify tapping a section pill switches tab
      await tester.tap(find.text('Appointments'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      // Verify Appointment tab contents
      expect(find.text('Upcoming'), findsOneWidget);
      expect(find.text('Past'), findsOneWidget);
      expect(find.text('Book Appointment'), findsOneWidget);
    });
  });
}
