import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/models/patient_model.dart';

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
}
