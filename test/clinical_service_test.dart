import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/models/clinical_models.dart';
import 'package:flutter_application_1/models/patient_model.dart';
import 'package:flutter_application_1/services/clinical_service.dart';
import 'package:flutter_application_1/screens/physio/patient_detail_screen.dart';
import 'package:flutter_application_1/screens/patient/patient_records_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('Phase 3 Clinical Assessment & SOAP Note Model Tests', () {
    test('AssessmentModel serializes and parses JSON correctly', () {
      final json = {
        'id': 'ASS_TEST_001',
        'assessment_date': '2026-08-26',
        'chief_complaint': 'Patellofemoral pain syndrome',
        'pain_level': 5,
        'pain_type': 'Aching',
        'active_rom_flexion': '115°',
        'active_rom_extension': '0°',
        'passive_rom': '120°',
        'muscle_strength_mmt': '4/5 (Good)',
        'functional_limitations': 'Pain when descending stairs',
        'posture_gait_notes': 'Antalgic gait',
        'special_tests': 'Clarke test positive',
        'clinical_goal': 'Full squat pain-free in 4 weeks',
      };

      final model = AssessmentModel.fromJson(json);
      expect(model.id, 'ASS_TEST_001');
      expect(model.date, '2026-08-26');
      expect(model.chiefComplaint, 'Patellofemoral pain syndrome');
      expect(model.painLevel, 5);
      expect(model.activeRomFlexion, '115°');
      expect(model.muscleStrengthMMT, '4/5 (Good)');

      final outJson = model.toJson();
      expect(outJson['chief_complaint'], 'Patellofemoral pain syndrome');
      expect(outJson['pain_level'], 5);
      expect(outJson['active_rom_flexion'], '115°');
    });

    test('SessionNoteModel serializes and parses SOAP note correctly', () {
      final json = {
        'id': 'NOTE_TEST_001',
        'session_number': 3,
        'session_date': '2026-08-26',
        'pain_level': 2,
        'subjective': 'Patient reports 50% improvement in morning knee stiffness.',
        'objective': 'Flexion increased to 125°, extension full at 0°.',
        'assessment': 'Marked improvement in quadriceps activation.',
        'plan': 'Progress to closed-chain squats and proprioception drills.',
        'therapist_name': 'Dr. Sharma',
      };

      final model = SessionNoteModel.fromJson(json);
      expect(model.id, 'NOTE_TEST_001');
      expect(model.sessionNumber, 3);
      expect(model.date, '2026-08-26');
      expect(model.painLevel, 2);
      expect(model.subjectiveNotes, contains('50% improvement'));
      expect(model.objectiveFindings, contains('125°'));
      expect(model.treatmentRendered, contains('quadriceps activation'));
      expect(model.planForNextSession, contains('closed-chain squats'));
      expect(model.therapistName, 'Dr. Sharma');

      final outJson = model.toJson();
      expect(outJson['session_number'], 3);
      expect(outJson['subjective'], model.subjectiveNotes);
      expect(outJson['objective'], model.objectiveFindings);
      expect(outJson['assessment'], model.treatmentRendered);
      expect(outJson['plan'], model.planForNextSession);
    });

    test('ClinicalService is a singleton', () {
      final s1 = ClinicalService();
      final s2 = ClinicalService();
      expect(identical(s1, s2), isTrue);
    });
  });

  group('Phase 3 Clinical UI Widget Tests', () {
    testWidgets('Renders PatientDetailScreen with assessment metrics and record action', (tester) async {
      const assessment = AssessmentModel(
        id: 'ASS_001',
        date: '2026-08-26',
        chiefComplaint: 'Post-ACL Reconstruction',
        painLevel: 4,
        painType: 'Aching',
        activeRomFlexion: '120°',
        activeRomExtension: '0°',
        passiveRom: '125°',
        muscleStrengthMMT: '4/5',
        functionalLimitations: 'Mild stiffness',
      );

      final patient = PatientModel(
        id: 'pat_widget_001',
        name: 'Test Patient',
        condition: 'ACL Reconstruction',
        assessment: assessment,
        sessionNotes: const [
          SessionNoteModel(
            id: 'note_1',
            sessionNumber: 1,
            date: '2026-08-20',
            painLevel: 4,
            subjectiveNotes: 'First session after evaluation',
            objectiveFindings: 'Flexion 110°',
            treatmentRendered: 'Cryotherapy and gentle mobilization',
            planForNextSession: 'Increase passive ROM',
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: PatientDetailScreen(patient: patient),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Patient Overview'), findsOneWidget);
      expect(find.text('Current Condition'), findsOneWidget);
      expect(find.text('Record / Edit'), findsOneWidget);
      expect(find.text('4/10'), findsOneWidget); // Pain metric
      expect(find.text('120°'), findsOneWidget); // Flexion ROM metric
      expect(find.text('0°'), findsOneWidget); // Extension metric
    });

    testWidgets('Renders PatientRecordsScreen with live assessment overview and notes tab', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PatientRecordsScreen(),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('My Records'), findsOneWidget);
      expect(find.text('Overview'), findsOneWidget);
      expect(find.text('Notes'), findsOneWidget);
      expect(find.text('Prescriptions'), findsOneWidget);
      expect(find.text('Reports'), findsOneWidget);
    });
  });
}
