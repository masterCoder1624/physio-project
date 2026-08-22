import 'package:flutter/material.dart';
import '../../constants/patient_theme.dart';
import 'exercise_detail_screen.dart';
import 'exercise_list_screen.dart';
import 'patient_components.dart';

/// Screen 11 — Program Details Screen (matching media_1787385006975.jpg)
class ProgramDetailScreen extends StatelessWidget {
  const ProgramDetailScreen({
    super.key,
    this.programName = 'Knee Rehabilitation Program',
    this.currentPhase = 'Phase 2 of 3',
    this.progressPct = 0.78,
  });

  final String programName;
  final String currentPhase;
  final double progressPct;

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
        title: Column(
          children: [
            Text(
              programName,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: PatientTheme.textDark),
            ),
            Text(
              currentPhase,
              style: const TextStyle(fontSize: 11, color: PatientTheme.primaryTeal, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
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
                  const Text(
                    'Focus on improving knee flexion, patellar mobility, and soft tissue flexibility with low-impact controlled repetitions.',
                    style: TextStyle(fontSize: 13, color: PatientTheme.textSecondary, height: 1.4),
                  ),
                  const SizedBox(height: 18),

                  // Info Grid (Duration, Frequency, Next Review)
                  Row(
                    children: [
                      Expanded(child: _buildInfoTile('Duration', '2 Weeks', Icons.date_range_rounded)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildInfoTile('Frequency', '5 Days / Wk', Icons.repeat_rounded)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildInfoTile('Next Review', '24 Aug 2026', Icons.event_available_rounded)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Phase Progression Timeline
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
                  _buildPhaseStep(
                    phase: 'Phase 1: Pain Relief & Cryotherapy',
                    status: 'Completed',
                    isCompleted: true,
                  ),
                  _buildPhaseStep(
                    phase: 'Phase 2: Mobility & Joint Range',
                    status: 'In Progress',
                    isInProgress: true,
                  ),
                  _buildPhaseStep(
                    phase: 'Phase 3: Strengthening & Loading',
                    status: 'Pending',
                    isPending: true,
                    isLast: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Exercises in this phase (Horizontal scroll matching screenshot)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Exercises in this phase (6)',
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
