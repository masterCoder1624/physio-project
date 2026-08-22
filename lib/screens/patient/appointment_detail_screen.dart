import 'package:flutter/material.dart';
import '../../constants/patient_theme.dart';
import 'patient_chat_screen.dart';
import 'patient_components.dart';

/// Appointment Details Deep-Dive Screen
class AppointmentDetailScreen extends StatelessWidget {
  const AppointmentDetailScreen({
    super.key,
    this.doctorName = 'Dr. Vashu User',
    this.specialty = 'Sports & Orthopedic Physiotherapy',
    this.time = 'Today, 05:00 PM',
    this.date = '19 Aug 2026',
    this.duration = '30 min',
    this.status = 'Scheduled',
  });

  final String doctorName;
  final String specialty;
  final String time;
  final String date;
  final String duration;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PatientTheme.pageBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: PatientTheme.textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Appointment Details',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: PatientTheme.textDark),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Doctor Card
            PatientCard(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: PatientTheme.primaryTealLight,
                    child: const Icon(Icons.medical_services_rounded, color: PatientTheme.primaryTeal, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doctorName,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: PatientTheme.textDark),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          specialty,
                          style: const TextStyle(fontSize: 12, color: PatientTheme.textSecondary),
                        ),
                        const SizedBox(height: 6),
                        const StatusBadge(label: 'Confirmed', isCompleted: true),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Time & Location Details
            PatientCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  _buildDetailRow(Icons.event_available_rounded, 'Date', date),
                  const Divider(height: 20, color: PatientTheme.border),
                  _buildDetailRow(Icons.access_time_rounded, 'Time', time),
                  const Divider(height: 20, color: PatientTheme.border),
                  _buildDetailRow(Icons.timer_outlined, 'Duration', duration),
                  const Divider(height: 20, color: PatientTheme.border),
                  _buildDetailRow(Icons.location_on_outlined, 'Clinic', 'PhysioVerse Clinic, Bandra West, Mumbai'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Actions
            PrimaryTealButton(
              label: 'Message Physiotherapist',
              icon: Icons.chat_bubble_outline_rounded,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PatientChatScreen()),
                );
              },
            ),
            const SizedBox(height: 12),

            SecondaryOutlineButton(
              label: 'Reschedule Appointment',
              icon: Icons.edit_calendar_rounded,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Select a new date and time from Book Appointment.')),
                );
              },
            ),
            const SizedBox(height: 12),

            Center(
              child: TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Appointment cancellation requested.')),
                  );
                },
                child: const Text(
                  'Cancel Appointment',
                  style: TextStyle(color: PatientTheme.errorRed, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: PatientTheme.primaryTeal),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(fontSize: 12.5, color: PatientTheme.textSecondary, fontWeight: FontWeight.w500),
        ),
        const Spacer(),
        Expanded(
          flex: 2,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: PatientTheme.textDark),
          ),
        ),
      ],
    );
  }
}
