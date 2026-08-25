import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/models/exercise_model.dart';
import 'package:flutter_application_1/screens/patient/exercise_detail_screen.dart';
import 'package:flutter_application_1/screens/patient/exercise_list_screen.dart';
import 'package:flutter_application_1/screens/patient/patient_dashboard.dart';
import 'package:flutter_application_1/screens/patient/patient_programs_screen.dart';
import 'package:flutter_application_1/screens/patient/program_detail_screen.dart';
import 'package:flutter_application_1/screens/physio/exercise_library_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 2 Exercise & Treatment Program Model Tests', () {
    test('ExerciseModel parses JSON correctly', () {
      final json = {
        'id': 'ex_101',
        'category_id': 'cat_mobility',
        'category_name': 'Mobility',
        'title': 'Ankle Alphabet',
        'description': 'Active range of motion exercise for ankle joint mobility.',
        'body_part': 'Ankle & Foot',
        'difficulty': 'Beginner',
        'instructions': 'Rotate ankle through letters.',
        'sets': 2,
        'reps': 20,
        'duration_seconds': 300,
        'default_rest_seconds': 15,
        'is_active': true,
      };

      final model = ExerciseModel.fromJson(json);
      expect(model.id, 'ex_101');
      expect(model.title, 'Ankle Alphabet');
      expect(model.categoryName, 'Mobility');
      expect(model.bodyPart, 'Ankle & Foot');
      expect(model.difficulty, 'Beginner');
      expect(model.durationFormatted, '5 min');
      expect(model.isActive, true);
    });

    test('PatientExerciseAssignmentModel parses correctly', () {
      final json = {
        'id': 'assign_202',
        'patient_id': 'pat_303',
        'physiotherapist_id': 'phy_404',
        'exercise_id': 'ex_101',
        'exercise_title': 'Bridge Exercise',
        'body_part': 'Lower Body',
        'difficulty': 'Beginner',
        'sets': 3,
        'reps': 12,
        'duration': '10 min',
        'frequency': 'Daily',
        'instructions': 'Squeeze glutes at the top.',
        'start_date': '2026-08-25',
        'is_completed_today': true,
      };

      final model = PatientExerciseAssignmentModel.fromJson(json);
      expect(model.id, 'assign_202');
      expect(model.patientId, 'pat_303');
      expect(model.exerciseTitle, 'Bridge Exercise');
      expect(model.isCompletedToday, true);
      expect(model.sets, 3);
      expect(model.reps, 12);
    });

    test('TodayPlanModel parses and computes correctly', () {
      final json = {
        'date': '2026-08-25',
        'patient_id': 'pat_303',
        'total_exercises': 4,
        'completed_exercises': 2,
        'progress_percentage': 50,
        'exercises': [
          {
            'id': 'assign_1',
            'patient_id': 'pat_303',
            'physiotherapist_id': 'phy_404',
            'exercise_id': 'ex_1',
            'exercise_title': 'Bridge Exercise',
            'start_date': '2026-08-25',
            'is_completed_today': true,
          },
          {
            'id': 'assign_2',
            'patient_id': 'pat_303',
            'physiotherapist_id': 'phy_404',
            'exercise_id': 'ex_2',
            'exercise_title': 'Wall Squat',
            'start_date': '2026-08-25',
            'is_completed_today': false,
          },
        ],
      };

      final plan = TodayPlanModel.fromJson(json);
      expect(plan.totalExercises, 4);
      expect(plan.completedExercises, 2);
      expect(plan.progressPercentage, 50);
      expect(plan.exercises.length, 2);
      expect(plan.exercises.first.isCompletedToday, true);
    });

    test('PatientProgramModel & ProgramPhaseModel parse correctly', () {
      final json = {
        'id': 'prog_505',
        'title': 'Post-ACL Reconstruction Recovery',
        'description': '12-week comprehensive functional restoration protocol.',
        'condition': 'ACL Reconstruction',
        'patient_id': 'pat_303',
        'status': 'active',
        'progress_percentage': 78,
        'phases': [
          {
            'name': 'Phase 1: Protection & Extension',
            'description': 'Full knee extension restoration.',
            'order': 1,
            'status': 'completed',
          },
          {
            'name': 'Phase 2: Weight Bearing & Flexion',
            'description': 'Progressive closed chain loading.',
            'order': 2,
            'status': 'in_progress',
          },
        ],
      };

      final program = PatientProgramModel.fromJson(json);
      expect(program.id, 'prog_505');
      expect(program.title, 'Post-ACL Reconstruction Recovery');
      expect(program.condition, 'ACL Reconstruction');
      expect(program.isActive, true);
      expect(program.progressPercentage, 78);
      expect(program.phases.length, 2);
      expect(program.phases.first.isCompleted, true);
      expect(program.phases.last.isInProgress, true);
    });
  });

  group('Phase 2 Exercise UI Screen Integration Tests', () {
    testWidgets('Renders ExerciseLibraryScreen for Physio', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: ExerciseLibraryScreen()),
      );

      expect(find.text('Exercise Library'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Knee'), findsOneWidget);
      expect(find.text('Shoulder'), findsOneWidget);
    });

    testWidgets('Renders ExerciseListScreen for Patient (Today Plan)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: ExerciseListScreen()),
      );

      expect(find.text("Today's Plan"), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Renders ExerciseDetailScreen with prescription metrics', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ExerciseDetailScreen(
            exerciseName: 'Bridge Exercise',
            targetArea: 'Glutes • Lower Body',
            sets: '3',
            reps: '12',
            duration: '10:00',
            instructions: 'Squeeze glutes at top for 2 seconds, then lower slowly.',
          ),
        ),
      );

      expect(find.text('Bridge Exercise'), findsNWidgets(2)); // Title and Header
      expect(find.text('Glutes • Lower Body'), findsOneWidget);
      expect(find.text('Step-by-Step Instructions'), findsOneWidget);
      expect(find.text('Mark as Completed'), findsOneWidget);
    });

    testWidgets('Renders PatientProgramsScreen with active program', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: PatientProgramsScreen()),
      );

      expect(find.text('My Program'), findsOneWidget);
    });

    testWidgets('Renders ProgramDetailScreen with phase breakdown', (tester) async {
      const prog = PatientProgramModel(
        id: 'prog_test_1',
        title: 'Knee Rehabilitation Program',
        condition: 'ACL Reconstruction',
        progressPercentage: 78,
        phases: [
          ProgramPhaseModel(
            name: 'Phase 1: Pain Relief & Cryotherapy',
            description: 'Decompression and quad setting.',
            status: 'completed',
          ),
          ProgramPhaseModel(
            name: 'Phase 2: Mobility & Joint Range',
            description: 'Active-assisted range of motion.',
            status: 'in_progress',
          ),
        ],
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: ProgramDetailScreen(
            program: prog,
          ),
        ),
      );

      expect(find.text('Knee Rehabilitation Program'), findsOneWidget);
      expect(find.text('About this phase'), findsOneWidget);
      expect(find.text('Program Phases'), findsOneWidget);
      expect(find.text('View All Exercises'), findsOneWidget);
    });

    testWidgets('Renders PatientDashboard with Today Plan & Progress section', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: PatientDashboard()),
      );

      expect(find.text("Today's Exercises"), findsOneWidget);
      expect(find.text('Overall Progress'), findsNWidgets(2));
      expect(find.text("Today's Plan"), findsOneWidget);
      expect(find.text('See All Exercises >'), findsOneWidget);
    });
  });
}
