import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/models/appointment_model.dart';
import 'package:flutter_application_1/screens/patient/appointment_detail_screen.dart';
import 'package:flutter_application_1/screens/patient/patient_appointments_screen.dart';
import 'package:flutter_application_1/screens/patient/patient_book_appointment_screen.dart';
import 'package:flutter_application_1/screens/patient/patient_dashboard.dart';
import 'package:flutter_application_1/screens/physio/calendar_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Appointment Model & Screen Connectivity Tests', () {
    test('AppointmentModel parses JSON correctly', () {
      final json = {
        'id': 'appt_123',
        'patient_id': 'pat_456',
        'physiotherapist_id': 'phy_789',
        'patient_name': 'Rahul Sharma',
        'patient_condition': 'Knee Rehabilitation',
        'physio_name': 'Dr. Vashu User',
        'appointment_date': '2026-08-25',
        'start_time': '09:00 AM',
        'duration': '45 min',
        'appointment_type': 'In-person',
        'status': 'confirmed',
      };

      final model = AppointmentModel.fromJson(json);

      expect(model.id, 'appt_123');
      expect(model.patientName, 'Rahul Sharma');
      expect(model.initials, 'RS');
      expect(model.isConfirmed, true);
      expect(model.isPending, false);
      expect(model.isCancelled, false);
      expect(model.isCompleted, false);
      expect(model.statusColor, const Color(0xFF16A34A));
    });

    test('SlotItemModel parses correctly', () {
      final json = {
        'time': '05:00 PM',
        'available': true,
      };

      final slot = SlotItemModel.fromJson(json);
      expect(slot.time, '05:00 PM');
      expect(slot.available, true);
    });

    testWidgets('Renders CalendarScreen for Physio', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: CalendarScreen()),
      );

      expect(find.text('Calendar'), findsOneWidget);
      expect(find.text('Manage your appointments'), findsOneWidget);
      expect(find.text("TODAY'S SCHEDULE"), findsOneWidget);
      expect(find.text('All Appointments'), findsOneWidget);
    });

    testWidgets('Renders PatientAppointmentsScreen', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: PatientAppointmentsScreen()),
      );

      expect(find.text('My Appointments'), findsOneWidget);
      expect(find.text('Upcoming'), findsOneWidget);
      expect(find.text('Past'), findsOneWidget);
      expect(find.text('Book New Appointment'), findsOneWidget);
    });

    testWidgets('Renders PatientBookAppointmentScreen with available slot selector', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: PatientBookAppointmentScreen()),
      );

      expect(find.text('Book Appointment'), findsOneWidget);
      expect(find.text('Select Date'), findsOneWidget);
      expect(find.text('Available Slots'), findsOneWidget);
      expect(find.text('Confirm Appointment'), findsOneWidget);
    });

    testWidgets('Renders AppointmentDetailScreen with bound live data', (tester) async {
      const appt = AppointmentModel(
        id: 'appt_real_999',
        patientId: 'pat_real_111',
        physiotherapistId: 'phy_real_222',
        patientName: 'Priya Verma',
        physioName: 'Dr. Sarah Jenkins',
        physioSpecialty: 'Spine & Posture Rehab',
        appointmentDate: '2026-09-15',
        startTime: '11:00 AM',
        duration: '60 min',
        appointmentType: 'In-person',
        status: 'confirmed',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: AppointmentDetailScreen(
            appointment: appt,
          ),
        ),
      );

      expect(find.text('Appointment Details'), findsOneWidget);
      expect(find.text('Dr. Sarah Jenkins'), findsOneWidget);
      expect(find.text('Spine & Posture Rehab'), findsOneWidget);
      expect(find.text('2026-09-15'), findsOneWidget);
      expect(find.text('11:00 AM'), findsOneWidget);
      expect(find.text('Cancel Appointment'), findsOneWidget);
    });

    testWidgets('Renders PatientDashboard with upcoming appointment section', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PatientDashboard(),
        ),
      );

      expect(find.text('Upcoming Appointment'), findsOneWidget);
      expect(find.text('View >'), findsOneWidget);
    });
  });
}
