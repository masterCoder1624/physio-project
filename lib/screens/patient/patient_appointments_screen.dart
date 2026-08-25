import 'package:flutter/material.dart';
import '../../constants/patient_theme.dart';
import '../../models/appointment_model.dart';
import '../../services/appointment_service.dart';
import 'appointment_detail_screen.dart';
import 'patient_book_appointment_screen.dart';
import 'patient_components.dart';

/// Screen 15 — Appointments Screen (connected with backend)
class PatientAppointmentsScreen extends StatefulWidget {
  const PatientAppointmentsScreen({super.key});

  @override
  State<PatientAppointmentsScreen> createState() => _PatientAppointmentsScreenState();
}

class _PatientAppointmentsScreenState extends State<PatientAppointmentsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  List<AppointmentModel> _allAppointments = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchAppointments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchAppointments() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final list = await AppointmentService().getAppointments();
      if (!mounted) return;
      setState(() {
        _allAppointments = list;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  List<AppointmentModel> get _upcomingAppointments {
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return _allAppointments.where((a) {
      if (a.isCancelled || a.isCompleted) return false;
      return a.appointmentDate.compareTo(todayStr) >= 0;
    }).toList();
  }

  List<AppointmentModel> get _pastAppointments {
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return _allAppointments.where((a) {
      if (a.isCancelled || a.isCompleted) return true;
      return a.appointmentDate.compareTo(todayStr) < 0;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PatientTheme.pageBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: PatientTheme.textDark),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'My Appointments',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: PatientTheme.textDark),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: PatientTheme.primaryTeal,
          unselectedLabelColor: PatientTheme.textSecondary,
          indicatorColor: PatientTheme.primaryTeal,
          indicatorWeight: 2.5,
          labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Past'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: PatientTheme.primaryTeal))
          : RefreshIndicator(
              color: PatientTheme.primaryTeal,
              onRefresh: _fetchAppointments,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildUpcomingTab(_upcomingAppointments),
                  _buildPastTab(_pastAppointments),
                ],
              ),
            ),
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        color: Colors.white,
        child: PrimaryTealButton(
          label: 'Book New Appointment',
          icon: Icons.add_rounded,
          onPressed: () async {
            final booked = await Navigator.of(context).push<bool>(
              MaterialPageRoute(builder: (_) => const PatientBookAppointmentScreen()),
            );
            if (booked == true) {
              _fetchAppointments();
            }
          },
        ),
      ),
    );
  }

  Widget _buildUpcomingTab(List<AppointmentModel> appointments) {
    if (appointments.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 40, 20, 90),
        children: const [
          Center(
            child: Column(
              children: [
                Icon(Icons.event_available_outlined, size: 50, color: PatientTheme.textMuted),
                SizedBox(height: 12),
                Text(
                  'No upcoming appointments',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: PatientTheme.textDark),
                ),
                SizedBox(height: 4),
                Text(
                  'Tap "Book New Appointment" below to schedule a session.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: PatientTheme.textSecondary),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 90),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final item = appointments[index];
        final dayStr = _extractDay(item.appointmentDate);
        final monthStr = _extractMonth(item.appointmentDate);
        final isPrimaryCard = index == 0;

        return PatientCard(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          onTap: () => _openDetail(item),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date Stamp Box
                  Container(
                    width: 54,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isPrimaryCard ? PatientTheme.primaryTealLight : PatientTheme.borderLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          dayStr,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: isPrimaryCard ? PatientTheme.primaryTeal : PatientTheme.textDark,
                          ),
                        ),
                        Text(
                          monthStr,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isPrimaryCard ? PatientTheme.primaryTeal : PatientTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Doctor info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${item.appointmentDate} • ${item.startTime}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: PatientTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.physioName ?? 'Dr. Vashu User',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: PatientTheme.textDark),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.physioSpecialty ?? 'Sports & Orthopedic Physiotherapy',
                          style: const TextStyle(fontSize: 11, color: PatientTheme.textSecondary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '⏱ ${item.duration} • ${item.appointmentType}',
                          style: const TextStyle(fontSize: 11, color: PatientTheme.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(height: 1, color: PatientTheme.border),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: SecondaryOutlineButton(
                      label: 'Reschedule',
                      height: 36,
                      onPressed: () async {
                        final booked = await Navigator.of(context).push<bool>(
                          MaterialPageRoute(builder: (_) => const PatientBookAppointmentScreen()),
                        );
                        if (booked == true) _fetchAppointments();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 36,
                      child: ElevatedButton(
                        onPressed: () => _openDetail(item),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: PatientTheme.primaryTeal,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('View Details', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPastTab(List<AppointmentModel> appointments) {
    if (appointments.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(40),
        children: const [
          Center(
            child: Text(
              'No past appointments found.',
              style: TextStyle(fontSize: 13, color: PatientTheme.textSecondary),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final item = appointments[index];
        final dayStr = _extractDay(item.appointmentDate);
        final monthStr = _extractMonth(item.appointmentDate);

        return PatientCard(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: PatientTheme.borderLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text(dayStr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(monthStr, style: const TextStyle(fontSize: 9.5, color: PatientTheme.textSecondary)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.patientCondition ?? 'Session Consultation', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                    const SizedBox(height: 2),
                    Text('${item.physioName ?? "Dr. Vashu User"} • ${item.status.toUpperCase()}', style: const TextStyle(fontSize: 11.5, color: PatientTheme.textSecondary)),
                  ],
                ),
              ),
              StatusBadge(
                label: item.status.toUpperCase(),
                isCompleted: item.isCompleted,
                isPending: item.isPending,
              ),
            ],
          ),
        );
      },
    );
  }

  void _openDetail(AppointmentModel appointment) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AppointmentDetailScreen(
          appointment: appointment,
          time: appointment.startTime,
          date: appointment.appointmentDate,
        ),
      ),
    );
  }

  String _extractDay(String dateStr) {
    if (dateStr.contains('-')) {
      final parts = dateStr.split('-');
      if (parts.length >= 3) return parts[2];
    }
    return '01';
  }

  String _extractMonth(String dateStr) {
    const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    if (dateStr.contains('-')) {
      final parts = dateStr.split('-');
      if (parts.length >= 2) {
        final m = int.tryParse(parts[1]) ?? 1;
        if (m >= 1 && m <= 12) return months[m - 1];
      }
    }
    return 'AUG';
  }
}
