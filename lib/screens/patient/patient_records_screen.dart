import 'package:flutter/material.dart';
import '../../constants/patient_theme.dart';
import 'patient_components.dart';
import 'patient_documents_screen.dart';

/// Screen 13 — Medical Records Screen (matching media_1787385006975.jpg)
class PatientRecordsScreen extends StatefulWidget {
  const PatientRecordsScreen({super.key});

  @override
  State<PatientRecordsScreen> createState() => _PatientRecordsScreenState();
}

class _PatientRecordsScreenState extends State<PatientRecordsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
          'My Records',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: PatientTheme.textDark),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: PatientTheme.primaryTeal,
          unselectedLabelColor: PatientTheme.textSecondary,
          indicatorColor: PatientTheme.primaryTeal,
          indicatorWeight: 2.5,
          labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Prescriptions'),
            Tab(text: 'Reports'),
            Tab(text: 'Notes'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildPrescriptionsTab(),
          _buildReportsTab(),
          _buildNotesTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Diagnosis Card (matching screenshot)
        PatientCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Diagnosis',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: PatientTheme.primaryTeal),
                  ),
                  Text(
                    'Diagnosed on 08 Aug 2026',
                    style: TextStyle(fontSize: 11, color: PatientTheme.textMuted),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Patellofemoral Pain Syndrome',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: PatientTheme.textDark,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Right anterior knee joint inflammation with mild quadriceps muscle imbalance.',
                style: TextStyle(fontSize: 12.5, color: PatientTheme.textSecondary, height: 1.35),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Physiotherapist Notes Card
        PatientCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Physiotherapist Notes',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: PatientTheme.textDark),
                  ),
                  Text('08 Aug 2026', style: TextStyle(fontSize: 11, color: PatientTheme.textMuted)),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: PatientTheme.primaryTealLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Focus on strengthening exercises and avoid deep knee bending. Ice knee for 15 mins after heavy sessions. Consistency is key to full recovery.',
                  style: TextStyle(fontSize: 12.5, color: PatientTheme.textDark, height: 1.4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Treatment History Timeline
        PatientCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Treatment History',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: PatientTheme.textDark),
              ),
              const SizedBox(height: 14),
              _buildHistoryRow('Knee pain initial assessment', '08 Aug 2026', Icons.check_circle_rounded),
              _buildHistoryRow('Knee mobility improvement test', '15 Aug 2026', Icons.check_circle_rounded),
              _buildHistoryRow('Strength training protocol started', '20 Aug 2026', Icons.radio_button_checked_rounded, isLast: true),
              const SizedBox(height: 16),

              SecondaryOutlineButton(
                label: 'View All Records',
                icon: Icons.folder_open_rounded,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PatientDocumentsScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryRow(String title, String date, IconData icon, {bool isLast = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: PatientTheme.primaryTeal),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: PatientTheme.textDark),
            ),
          ),
          Text(
            date,
            style: const TextStyle(fontSize: 11, color: PatientTheme.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildPrescriptionsTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        PatientCard(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: PatientTheme.primaryTealLight, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.medication_rounded, color: PatientTheme.primaryTeal),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Prescription - August 2026', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: PatientTheme.textDark)),
                    SizedBox(height: 2),
                    Text('Dr. Vashu User • 4 Prescribed exercises', style: TextStyle(fontSize: 12, color: PatientTheme.textSecondary)),
                  ],
                ),
              ),
              const Icon(Icons.file_download_outlined, color: PatientTheme.primaryTeal),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReportsTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        PatientCard(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: PatientTheme.infoBlueBg, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.image_search_rounded, color: PatientTheme.infoBlue),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Right Knee MRI Report', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: PatientTheme.textDark)),
                    SizedBox(height: 2),
                    Text('Apex Diagnostic Center • 10 Aug 2026', style: TextStyle(fontSize: 12, color: PatientTheme.textSecondary)),
                  ],
                ),
              ),
              const Icon(Icons.file_download_outlined, color: PatientTheme.primaryTeal),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotesTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        PatientCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Session 3 Clinical Observation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              SizedBox(height: 4),
              Text('18 Aug 2026 • Dr. Vashu User', style: TextStyle(fontSize: 11, color: PatientTheme.textMuted)),
              SizedBox(height: 10),
              Text(
                'Patient reports 40% reduction in morning joint stiffness. Knee flexion increased from 105° to 125°. Continue Phase 2 mobility exercises.',
                style: TextStyle(fontSize: 12.5, color: PatientTheme.textDark, height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
