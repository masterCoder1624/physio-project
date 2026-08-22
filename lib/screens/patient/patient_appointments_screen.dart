import 'package:flutter/material.dart';
import '../../constants/patient_theme.dart';
import 'appointment_detail_screen.dart';
import 'patient_book_appointment_screen.dart';
import 'patient_components.dart';

/// Screen 15 — Appointments Screen (matching media_1787385006975.jpg)
class PatientAppointmentsScreen extends StatefulWidget {
  const PatientAppointmentsScreen({super.key});

  @override
  State<PatientAppointmentsScreen> createState() => _PatientAppointmentsScreenState();
}

class _PatientAppointmentsScreenState extends State<PatientAppointmentsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUpcomingTab(),
          _buildPastTab(),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        color: Colors.white,
        child: PrimaryTealButton(
          label: 'Book New Appointment',
          icon: Icons.add_rounded,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PatientBookAppointmentScreen()),
            );
          },
        ),
      ),
    );
  }

  Widget _buildUpcomingTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 90),
      children: [
        // Today's Appointment (matching screenshot)
        PatientCard(
          padding: const EdgeInsets.all(16),
          onTap: () => _openDetail('Today, 05:00 PM', '19 Aug 2026'),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date Stamp Box (19 AUG)
                  Container(
                    width: 54,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: PatientTheme.primaryTealLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: const [
                        Text(
                          '19',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: PatientTheme.primaryTeal,
                          ),
                        ),
                        Text(
                          'AUG',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: PatientTheme.primaryTeal,
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
                      children: const [
                        Text(
                          'Today, 05:00 PM',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: PatientTheme.textDark,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Dr. Vashu User',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: PatientTheme.textDark),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Sports & Orthopedic Physiotherapy',
                          style: TextStyle(fontSize: 11, color: PatientTheme.textSecondary),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '⏱ 30 min',
                          style: TextStyle(fontSize: 11, color: PatientTheme.textMuted),
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
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const PatientBookAppointmentScreen()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 36,
                      child: ElevatedButton(
                        onPressed: () => _openDetail('Today, 05:00 PM', '19 Aug 2026'),
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
        ),
        const SizedBox(height: 14),

        // Upcoming Appointment 2 (26 AUG)
        PatientCard(
          padding: const EdgeInsets.all(16),
          onTap: () => _openDetail('Friday, 04:00 PM', '26 Aug 2026'),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 54,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: PatientTheme.borderLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: const [
                    Text(
                      '26',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: PatientTheme.textDark,
                      ),
                    ),
                    Text(
                      'AUG',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: PatientTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Friday, 04:00 PM',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: PatientTheme.textDark,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Dr. Vashu User',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: PatientTheme.textDark),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Sports & Orthopedic Physiotherapy',
                      style: TextStyle(fontSize: 11, color: PatientTheme.textSecondary),
                    ),
                    SizedBox(height: 6),
                    StatusBadge(label: 'Scheduled', isScheduled: true),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPastTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        PatientCard(
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
                  children: const [
                    Text('08', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('AUG', style: TextStyle(fontSize: 9.5, color: PatientTheme.textSecondary)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Initial Knee Assessment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                    SizedBox(height: 2),
                    Text('Dr. Vashu User • Completed', style: TextStyle(fontSize: 11.5, color: PatientTheme.textSecondary)),
                  ],
                ),
              ),
              const StatusBadge(label: 'Completed', isCompleted: true),
            ],
          ),
        ),
      ],
    );
  }

  void _openDetail(String time, String date) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AppointmentDetailScreen(
          time: time,
          date: date,
        ),
      ),
    );
  }
}
