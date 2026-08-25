import 'package:flutter/material.dart';
import '../../constants/patient_theme.dart';
import '../../models/exercise_model.dart';
import '../../services/exercise_service.dart';
import 'exercise_detail_screen.dart';
import 'exercise_list_screen.dart';
import 'patient_components.dart';

/// Screen 11 — Program Details Screen (matching design)
class ProgramDetailScreen extends StatefulWidget {
  const ProgramDetailScreen({
    super.key,
    this.programId,
    this.programName = 'Knee Rehabilitation Program',
    this.currentPhase = 'Phase 2 of 3',
    this.progressPct = 0.78,
    this.program,
  });

  final String? programId;
  final String programName;
  final String currentPhase;
  final double progressPct;
  final PatientProgramModel? program;

  @override
  State<ProgramDetailScreen> createState() => _ProgramDetailScreenState();
}

class _ProgramDetailScreenState extends State<ProgramDetailScreen> {
  final ExerciseService _exerciseService = ExerciseService();
  PatientProgramModel? _program;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _program = widget.program;
    if (_program == null && widget.programId != null && widget.programId!.isNotEmpty) {
      _loadProgram();
    }
  }

  Future<void> _loadProgram() async {
    setState(() => _isLoading = true);
    try {
      final prog = await _exerciseService.getProgramById(widget.programId!);
      if (!mounted) return;
      setState(() {
        _program = prog;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _program?.title ?? widget.programName;
    final phases = _program?.phases ?? [];
    final activePhase = phases.firstWhere(
      (p) => p.isInProgress,
      orElse: () => phases.isNotEmpty
          ? phases.first
          : const ProgramPhaseModel(
              name: 'Phase 1: Initial Care',
              description: 'Focus on therapeutic stabilization and controlled movement excursion.',
            ),
    );

    return Scaffold(
      backgroundColor: PatientTheme.pageBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: PatientTheme.textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: PatientTheme.textDark),
            ),
            Text(
              activePhase.name,
              style: const TextStyle(fontSize: 11, color: PatientTheme.primaryTeal, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: PatientTheme.primaryTeal))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // About This Phase Card
                  PatientCard(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'About this phase',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: PatientTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          activePhase.description.isNotEmpty
                              ? activePhase.description
                              : 'Focus on improving joint stability, mobility, and soft tissue flexibility with low-impact controlled repetitions.',
                          style: const TextStyle(fontSize: 13, color: PatientTheme.textSecondary, height: 1.4),
                        ),
                        const SizedBox(height: 18),

                        // Info Grid (Duration, Frequency, Condition)
                        Row(
                          children: [
                            Expanded(child: _buildInfoTile('Duration', '2 Weeks', Icons.date_range_rounded)),
                            const SizedBox(width: 8),
                            Expanded(child: _buildInfoTile('Frequency', 'Daily', Icons.repeat_rounded)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildInfoTile(
                                'Condition',
                                _program?.condition ?? 'Rehabilitation',
                                Icons.event_available_rounded,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Phase Progression Timeline
                  if (phases.isNotEmpty)
                    PatientCard(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Program Phases',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: PatientTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 16),
                          for (int i = 0; i < phases.length; i++)
                            _buildPhaseStep(
                              phase: phases[i].name,
                              status: phases[i].status.toUpperCase(),
                              isCompleted: phases[i].isCompleted,
                              isInProgress: phases[i].isInProgress,
                              isPending: phases[i].isPending,
                              isLast: i == phases.length - 1,
                            ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),

                  // Exercises in this phase
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Exercises in this program',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: PatientTheme.textDark,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ExerciseListScreen()),
                        ),
                        child: const Text(
                          'See All',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: PatientTheme.primaryTeal,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  SizedBox(
                    height: 130,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildExerciseThumbCard(context, 'Bridge Exercise', '3 sets • 12 reps', Icons.accessibility_new_rounded, true),
                        _buildExerciseThumbCard(context, 'Wall Squat', '3 sets • 15 reps', Icons.fitness_center_rounded, true),
                        _buildExerciseThumbCard(context, 'Leg Raise', '3 sets • 12 reps', Icons.airline_seat_legroom_extra_rounded, false),
                        _buildExerciseThumbCard(context, 'Hamstring Stretch', '3 sets • 30 sec', Icons.self_improvement_rounded, false),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // CTA Button
                  PrimaryTealButton(
                    label: 'View All Exercises',
                    icon: Icons.format_list_bulleted_rounded,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ExerciseListScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoTile(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: PatientTheme.inputBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: PatientTheme.primaryTeal),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: PatientTheme.textDark),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(fontSize: 9.5, color: PatientTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseStep({
    required String phase,
    required String status,
    bool isCompleted = false,
    bool isInProgress = false,
    bool isPending = false,
    bool isLast = false,
  }) {
    Color dotColor = PatientTheme.textMuted;
    if (isCompleted) dotColor = PatientTheme.successGreen;
    if (isInProgress) dotColor = PatientTheme.primaryTeal;
    if (isPending) dotColor = PatientTheme.warningOrange;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 38,
                color: PatientTheme.border,
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                phase,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: PatientTheme.textDark,
                ),
              ),
              const SizedBox(height: 2),
              StatusBadge(
                label: status,
                isCompleted: isCompleted,
                isInProgress: isInProgress,
                isPending: isPending,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseThumbCard(BuildContext context, String name, String subtitle, IconData icon, bool done) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ExerciseDetailScreen(
              exerciseName: name,
              isInitiallyCompleted: done,
            ),
          ),
        );
      },
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: PatientTheme.border),
          boxShadow: PatientTheme.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: done ? PatientTheme.successGreenBg : PatientTheme.primaryTealLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 20,
                color: done ? PatientTheme.successGreen : PatientTheme.primaryTeal,
              ),
            ),
            const Spacer(),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: PatientTheme.textDark),
            ),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 9.5, color: PatientTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
