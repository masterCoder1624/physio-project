import 'package:flutter/material.dart';
import '../../constants/patient_theme.dart';
import '../../core/storage/local_storage_service.dart';
import '../../models/clinical_models.dart';
import '../../services/clinical_service.dart';
import 'patient_components.dart';

/// Screen 13 — Medical Records Screen
class PatientRecordsScreen extends StatefulWidget {
  const PatientRecordsScreen({super.key, this.patientId});

  final String? patientId;

  @override
  State<PatientRecordsScreen> createState() => _PatientRecordsScreenState();
}

class _PatientRecordsScreenState extends State<PatientRecordsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  AssessmentModel? _latestAssessment;
  List<SessionNoteModel> _notes = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _fetchRecords();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchRecords() async {
    setState(() => _isLoading = true);
    try {
      String? pId = widget.patientId;
      if (pId == null || pId.isEmpty) {
        pId = await LocalStorageService.getUserId();
      }

      if (pId != null && pId.isNotEmpty) {
        final assessment = await ClinicalService().getLatestAssessment(pId);
        final notes = await ClinicalService().getNotes(pId);
        if (!mounted) return;
        setState(() {
          _latestAssessment = assessment;
          _notes = notes;
          _isLoading = false;
        });
        return;
      }
    } catch (_) {}

    if (!mounted) return;
    setState(() => _isLoading = false);
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: PatientTheme.primaryTeal))
          : TabBarView(
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
    final assessment = _latestAssessment;

    return RefreshIndicator(
      onRefresh: _fetchRecords,
      color: PatientTheme.primaryTeal,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Diagnosis Card
          PatientCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Diagnosis / Condition',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: PatientTheme.primaryTeal),
                    ),
                    Text(
                      assessment != null ? 'Assessed on ${assessment.date}' : 'Clinical Record',
                      style: const TextStyle(fontSize: 11, color: PatientTheme.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  assessment?.chiefComplaint ?? 'General Rehabilitation',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: PatientTheme.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  assessment != null
                      ? 'Pain Level: ${assessment.painLevel}/10 • Flexion: ${assessment.activeRomFlexion} • Strength: ${assessment.muscleStrengthMMT}'
                      : 'Initial assessment will be performed by your assigned physiotherapist.',
                  style: const TextStyle(fontSize: 12.5, color: PatientTheme.textSecondary, height: 1.35),
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
                  children: [
                    const Text(
                      'Clinical Goals & Instructions',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: PatientTheme.textDark),
                    ),
                    Text(
                      assessment?.date ?? '',
                      style: const TextStyle(fontSize: 11, color: PatientTheme.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: PatientTheme.primaryTealLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    assessment?.clinicalGoal ??
                        'Follow your assigned daily home exercise program. Contact your physiotherapist for any sharp pain.',
                    style: const TextStyle(fontSize: 12.5, color: PatientTheme.textDark, height: 1.4),
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
                  'Recent Session Activity',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: PatientTheme.textDark),
                ),
                const SizedBox(height: 14),
                if (_notes.isEmpty)
                  const Text(
                    'No session notes recorded yet.',
                    style: TextStyle(fontSize: 12, color: PatientTheme.textMuted),
                  )
                else
                  ..._notes.take(3).map((n) => _buildHistoryRow(
                        'Session #${n.sessionNumber}: ${n.objectiveFindings.isNotEmpty ? n.objectiveFindings : n.treatmentRendered}',
                        n.date,
                        Icons.check_circle_rounded,
                      )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryRow(String title, String date, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: PatientTheme.primaryTeal),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: PatientTheme.textDark),
            ),
          ),
          const SizedBox(width: 8),
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
                    Text('Active Home Exercise Plan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: PatientTheme.textDark)),
                    SizedBox(height: 2),
                    Text('Prescribed by your physiotherapist', style: TextStyle(fontSize: 12, color: PatientTheme.textSecondary)),
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
                    Text('Diagnostic Reports Vault', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: PatientTheme.textDark)),
                    SizedBox(height: 2),
                    Text('Uploaded medical imaging and labs', style: TextStyle(fontSize: 12, color: PatientTheme.textSecondary)),
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
    if (_notes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: PatientTheme.primaryTealLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.note_alt_outlined, color: PatientTheme.primaryTeal, size: 28),
              ),
              const SizedBox(height: 14),
              const Text(
                'No Clinical Notes Yet',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: PatientTheme.textDark),
              ),
              const SizedBox(height: 6),
              const Text(
                'Notes recorded during your physiotherapy sessions will appear here.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: PatientTheme.textMuted, height: 1.4),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchRecords,
      color: PatientTheme.primaryTeal,
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _notes.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final note = _notes[index];
          return PatientCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Session #${note.sessionNumber} Clinical Note',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: PatientTheme.textDark),
                    ),
                    Text(
                      'Pain: ${note.painLevel}/10',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: PatientTheme.primaryTeal),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${note.date} • ${note.therapistName}',
                  style: const TextStyle(fontSize: 11, color: PatientTheme.textMuted),
                ),
                const SizedBox(height: 10),
                if (note.objectiveFindings.isNotEmpty)
                  Text(
                    note.objectiveFindings,
                    style: const TextStyle(fontSize: 12.5, color: PatientTheme.textDark, height: 1.4),
                  ),
                if (note.planForNextSession.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Plan: ${note.planForNextSession}',
                    style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: PatientTheme.textSecondary),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
