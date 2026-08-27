import 'package:flutter/material.dart';
import '../../constants/patient_theme.dart';
import '../../models/appointment_model.dart';
import '../../services/appointment_service.dart';
import 'patient_book_appointment_screen.dart';
import 'patient_chat_screen.dart';
import 'patient_components.dart';

/// Appointment Details Deep-Dive Screen (connected with backend)
class AppointmentDetailScreen extends StatefulWidget {
  const AppointmentDetailScreen({
    super.key,
    this.appointment,
    this.doctorName,
    this.specialty,
    this.time,
    this.date,
    this.duration,
    this.status,
  });

  final AppointmentModel? appointment;
  final String? doctorName;
  final String? specialty;
  final String? time;
  final String? date;
  final String? duration;
  final String? status;

  @override
  State<AppointmentDetailScreen> createState() => _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState extends State<AppointmentDetailScreen> {
  bool _isCancelling = false;

  String get _doctorName => widget.appointment?.physioName ?? widget.doctorName ?? 'Dr. Vashu User';
  String get _specialty => widget.appointment?.physioSpecialty ?? widget.specialty ?? 'Sports & Orthopedic Physiotherapy';
  String get _time => widget.appointment?.startTime ?? widget.time ?? 'Today, 05:00 PM';
  String get _date => widget.appointment?.appointmentDate ?? widget.date ?? '19 Aug 2026';
  String get _duration => widget.appointment?.duration ?? widget.duration ?? '30 min';
  String get _status => widget.appointment?.status.toUpperCase() ?? widget.status ?? 'SCHEDULED';

  Future<void> _handleCancel() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Appointment'),
        content: const Text('Are you sure you want to cancel this appointment session?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Keep')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: PatientTheme.errorRed),
            child: const Text('Cancel Appointment'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final apptId = widget.appointment?.id;
      if (apptId != null && apptId.isNotEmpty) {
        setState(() => _isCancelling = true);
        try {
          await AppointmentService().cancelAppointment(apptId);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Appointment cancelled successfully.')),
          );
          Navigator.of(context).pop(true);
        } catch (e) {
          if (!mounted) return;
          setState(() => _isCancelling = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to cancel: $e')),
          );
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appointment cancelled.')),
        );
        Navigator.of(context).pop(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isConfirmed = _status == 'CONFIRMED' || _status == 'SCHEDULED';

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
                          _doctorName,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: PatientTheme.textDark),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _specialty,
                          style: const TextStyle(fontSize: 12, color: PatientTheme.textSecondary),
                        ),
                        const SizedBox(height: 6),
                        StatusBadge(
                          label: _status,
                          isCompleted: _status == 'COMPLETED',
                          isInProgress: _status == 'CONFIRMED' || _status == 'SCHEDULED',
                          isPending: _status == 'PENDING',
                        ),
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
                  _buildDetailRow(Icons.event_available_rounded, 'Date', _date),
                  const Divider(height: 20, color: PatientTheme.border),
                  _buildDetailRow(Icons.access_time_rounded, 'Time', _time),
                  const Divider(height: 20, color: PatientTheme.border),
                  _buildDetailRow(Icons.timer_outlined, 'Duration', _duration),
                  const Divider(height: 20, color: PatientTheme.border),
                  _buildDetailRow(Icons.location_on_outlined, 'Clinic', 'RehabZ Clinic, Bandra West, Mumbai'),
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
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PatientBookAppointmentScreen()),
                );
              },
            ),
            const SizedBox(height: 12),

            if (isConfirmed)
              Center(
                child: _isCancelling
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: PatientTheme.errorRed, strokeWidth: 2))
                    : TextButton(
                        onPressed: _handleCancel,
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
