import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/models/progress_model.dart';
import 'package:flutter_application_1/services/progress_service.dart';
import 'package:flutter_application_1/screens/patient/patient_progress_screen.dart';
import 'package:flutter_application_1/screens/patient/patient_dashboard.dart';
import 'package:flutter_application_1/screens/patient/patient_components.dart';

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({
      'access_token': 'mock_valid_token_test',
      'user_id': 'pat_test_001',
      'user_role': 'patient',
    });
  });

  group('Phase 4 Patient Progress & Recovery Analytics Model Tests', () {
    test('PatientProgressModel serializes and parses JSON correctly', () {
      final json = {
        'patient_id': 'pat_123',
        'period': 'this_month',
        'overall_percentage': 78,
        'progress_subtitle': 'Good Progress',
        'completed_count': 18,
        'in_progress_count': 5,
        'pending_count': 3,
        'adherence_percentage': 85,
        'exercise_compliance': {
          'total_assigned': 4,
          'total_completed': 18,
          'completion_percentage': 85,
          'weekly_adherence_percentage': 85,
          'weekly_activity': [
            {'day': 'M', 'date': '2026-08-24', 'completion_rate': 1.0, 'is_today': false},
            {'day': 'T', 'date': '2026-08-25', 'completion_rate': 0.75, 'is_today': false},
            {'day': 'W', 'date': '2026-08-26', 'completion_rate': 1.0, 'is_today': true},
          ],
        },
        'session_progress': {
          'completed_sessions': 3,
          'total_sessions': 5,
          'upcoming_sessions': 2,
        },
        'treatment_program': {
          'program_id': 'prog_999',
          'title': 'ACL Rehab Protocol',
          'current_phase': 'Phase 1: Protection & ROM',
          'overall_progress': 78,
        },
        'progress_over_time': [
          {'date': '2026-08-01', 'label': '1 Aug', 'value': 20.0},
          {'date': '2026-08-08', 'label': '8 Aug', 'value': 40.0},
          {'date': '2026-08-15', 'label': '15 Aug', 'value': 60.0},
          {'date': '2026-08-22', 'label': '22 Aug', 'value': 78.0},
        ],
        'date_labels': ['1 Aug', '8 Aug', '15 Aug', '22 Aug', 'Today'],
        'pain_trend': [
          {'date': '2026-08-01', 'pain_level': 6, 'source': 'assessment'},
          {'date': '2026-08-15', 'pain_level': 3, 'source': 'session_note'},
        ],
        'rom_trend': [
          {'date': '2026-08-01', 'flexion': '100°', 'extension': '0°', 'passive': '105°'},
        ],
        'has_data': true,
      };

      final model = PatientProgressModel.fromJson(json);

      expect(model.patientId, 'pat_123');
      expect(model.overallPercentage, 78);
      expect(model.progressSubtitle, 'Good Progress');
      expect(model.completedCount, 18);
      expect(model.inProgressCount, 5);
      expect(model.pendingCount, 3);
      expect(model.adherencePercentage, 85);
      expect(model.hasData, isTrue);
      expect(model.exerciseCompliance.totalAssigned, 4);
      expect(model.exerciseCompliance.weeklyActivity.length, 3);
      expect(model.treatmentProgram?.title, 'ACL Rehab Protocol');
      expect(model.progressOverTime.length, 4);
      expect(model.painTrend.length, 2);
      expect(model.romTrend.first.flexion, '100°');

      final serialized = model.toJson();
      expect(serialized['overall_percentage'], 78);
      expect(serialized['has_data'], isTrue);
    });

    test('PatientProgressModel.empty() creates valid default zero state', () {
      final empty = PatientProgressModel.empty('pat_empty');
      expect(empty.patientId, 'pat_empty');
      expect(empty.overallPercentage, 0);
      expect(empty.progressSubtitle, 'Not Started');
      expect(empty.completedCount, 0);
      expect(empty.hasData, isFalse);
    });

    test('ProgressService is a singleton', () {
      final s1 = ProgressService();
      final s2 = ProgressService();
      expect(identical(s1, s2), isTrue);
    });
  });

  group('Phase 4 Progress UI Widget Tests', () {
    testWidgets('Renders PatientProgressScreen with gauge, charts, and period switcher', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: PatientProgressScreen(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('My Progress'), findsOneWidget);
      expect(find.text('Overall Progress'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
      expect(find.text('In Progress'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('Progress Over Time'), findsOneWidget);
      expect(find.text('Weekly Consistency'), findsOneWidget);
      expect(find.byType(CircularProgressGauge), findsOneWidget);
      expect(find.byType(ProgressLineChart), findsOneWidget);
      expect(find.byType(WeeklyActivityBarChart), findsOneWidget);
    });

    testWidgets('Renders PatientDashboard with connected progress card and gauge', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: PatientDashboard(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Overall Progress'), findsWidgets);
      expect(find.text('Weekly Activity'), findsOneWidget);
      expect(find.byType(CircularProgressGauge), findsWidgets);
      expect(find.byType(WeeklyActivityBarChart), findsOneWidget);
    });
  });
}
