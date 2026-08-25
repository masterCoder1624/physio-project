import 'package:flutter/material.dart';
import '../../constants/patient_theme.dart';
import '../../models/exercise_model.dart';
import '../../services/exercise_service.dart';
import 'patient_components.dart';
import 'program_detail_screen.dart';

/// Screen 10 — My Treatment Programs Screen (matching design)
class PatientProgramsScreen extends StatefulWidget {
  const PatientProgramsScreen({super.key});

  @override
  State<PatientProgramsScreen> createState() => _PatientProgramsScreenState();
}

class _PatientProgramsScreenState extends State<PatientProgramsScreen> {
  final ExerciseService _exerciseService = ExerciseService();
  bool _isLoading = true;
  List<PatientProgramModel> _programs = [];

  @override
  void initState() {
    super.initState();
    _loadPrograms();
  }

  Future<void> _loadPrograms() async {
    setState(() => _isLoading = true);
    try {
      final list = await _exerciseService.getMyPrograms();
      if (!mounted) return;
      setState(() {
        _programs = list;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
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
          'My Program',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: PatientTheme.textDark),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: PatientTheme.primaryTeal))
          : RefreshIndicator(
              color: PatientTheme.primaryTeal,
              onRefresh: _loadPrograms,
              child: _programs.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 80),
                        Center(
                          child: Text(
                            'No active treatment programs prescribed yet.',
                            style: TextStyle(color: PatientTheme.textSecondary, fontSize: 14),
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: _programs.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return const Padding(
                            padding: EdgeInsets.only(bottom: 16),
                            child: Text(
                              'Your active treatment programs',
                              style: TextStyle(fontSize: 13, color: PatientTheme.textSecondary),
                            ),
                          );
                        }

                        final prog = _programs[index - 1];
                        final pct = prog.progressPercentage / 100.0;

                        return PatientCard(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          prog.title,
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w800,
                                            color: PatientTheme.textDark,
                                            height: 1.25,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          prog.startDate != null && prog.startDate!.isNotEmpty
                                              ? 'Started on ${prog.startDate}'
                                              : 'Active clinical protocol',
                                          style: const TextStyle(fontSize: 11.5, color: PatientTheme.textSecondary),
                                        ),
                                      ],
                                    ),
                                  ),
                                  StatusBadge(
                                    label: prog.isActive ? 'Active' : 'Completed',
                                    isInProgress: prog.isActive,
                                    isCompleted: !prog.isActive,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Progress Bar Row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Progress', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: PatientTheme.textDark)),
                                  Text(
                                    '${prog.progressPercentage}%',
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: PatientTheme.primaryTeal),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: pct.clamp(0.0, 1.0),
                                  minHeight: 8,
                                  backgroundColor: PatientTheme.borderLight,
                                  valueColor: const AlwaysStoppedAnimation<Color>(PatientTheme.primaryTeal),
                                ),
                              ),
                              const SizedBox(height: 18),

                              // Phases Checklist
                              if (prog.phases.isNotEmpty) ...[
                                const Text(
                                  'Phases',
                                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: PatientTheme.textDark),
                                ),
                                const SizedBox(height: 10),
                                for (final phase in prog.phases)
                                  _buildPhaseRow(
                                    phase.name,
                                    phase.status,
                                    phase.isCompleted,
                                    phase.isInProgress,
                                    phase.isPending,
                                  ),
                                const SizedBox(height: 18),
                              ],

                              // View Details Button
                              SecondaryOutlineButton(
                                label: 'View Program Details',
                                icon: Icons.info_outline_rounded,
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ProgramDetailScreen(
                                        programId: prog.id,
                                        programName: prog.title,
                                        currentPhase: prog.phases.isNotEmpty ? prog.phases.first.name : 'Phase 1',
                                        progressPct: pct,
                                        program: prog,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
    );
  }

  Widget _buildPhaseRow(String name, String status, bool done, bool inProg, bool pending) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: done ? PatientTheme.successGreen : (inProg ? PatientTheme.primaryTeal : PatientTheme.warningOrange),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                name,
                style: const TextStyle(fontSize: 12.5, color: PatientTheme.textDark, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          StatusBadge(
            label: status.toUpperCase(),
            isCompleted: done,
            isInProgress: inProg,
            isPending: pending,
          ),
        ],
      ),
    );
  }
}
