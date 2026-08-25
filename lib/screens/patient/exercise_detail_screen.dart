import 'package:flutter/material.dart';
import '../../constants/patient_theme.dart';
import '../../services/exercise_service.dart';
import 'patient_components.dart';

/// Screen 9 — Exercise Details Screen (matching design)
class ExerciseDetailScreen extends StatefulWidget {
  const ExerciseDetailScreen({
    super.key,
    this.assignmentId,
    this.exerciseName = 'Bridge Exercise',
    this.targetArea = 'Glutes • Lower Body',
    this.sets = '3',
    this.reps = '12',
    this.duration = '10:00',
    this.isInitiallyCompleted = false,
    this.instructions,
  });

  final String? assignmentId;
  final String exerciseName;
  final String targetArea;
  final String sets;
  final String reps;
  final String duration;
  final bool isInitiallyCompleted;
  final String? instructions;

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  final ExerciseService _exerciseService = ExerciseService();
  late bool _isCompleted;
  bool _isPlayingVideo = false;

  @override
  void initState() {
    super.initState();
    _isCompleted = widget.isInitiallyCompleted;
  }

  Future<void> _toggleCompleted() async {
    final nextState = !_isCompleted;
    setState(() => _isCompleted = nextState);

    if (nextState && widget.assignmentId != null && widget.assignmentId!.isNotEmpty) {
      try {
        await _exerciseService.completeExercise(
          assignmentId: widget.assignmentId!,
          completedSets: int.tryParse(widget.sets) ?? 3,
          completedReps: int.tryParse(widget.reps) ?? 12,
        );
      } catch (_) {}
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isCompleted ? 'Exercise marked as completed! 🎉' : 'Exercise marked as pending'),
        backgroundColor: _isCompleted ? PatientTheme.successGreen : PatientTheme.textDark,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final defaultInstructions = [
      'Lie down on the mat with knees bent and feet flat on the floor.',
      'Keep your arms straight at your sides with palms down.',
      'Lift hips upward until knees, hips, and shoulders form a straight line.',
      'Squeeze glutes tight at the top for 3 to 5 seconds.',
      'Slowly lower back down to starting position with control.',
    ];

    return Scaffold(
      backgroundColor: PatientTheme.pageBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: PatientTheme.textDark),
          onPressed: () => Navigator.of(context).pop(_isCompleted),
        ),
        title: Text(
          widget.exerciseName,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: PatientTheme.textDark),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video / Image Preview Area with Play Button
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(20),
                boxShadow: PatientTheme.cardShadow,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Vector Exercise Silhouette Background
                  Center(
                    child: Icon(
                      Icons.accessibility_new_rounded,
                      size: 96,
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                  ),
                  if (_isPlayingVideo)
                    const Center(
                      child: Text(
                        'Playing Guided Demonstration...',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: () => setState(() => _isPlayingVideo = true),
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: PatientTheme.primaryTeal,
                          shape: BoxShape.circle,
                          boxShadow: PatientTheme.tealButtonShadow,
                        ),
                        child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 34),
                      ),
                    ),
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        widget.duration,
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Title & Muscle Target
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.exerciseName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: PatientTheme.textDark,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.targetArea,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: PatientTheme.primaryTeal,
                        ),
                      ),
                    ],
                  ),
                ),
                StatusBadge(
                  label: _isCompleted ? 'Completed' : 'Pending',
                  isCompleted: _isCompleted,
                  isPending: !_isCompleted,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Description / Instructions
            Text(
              widget.instructions ??
                  'Lie on your back with knees bent. Lift your hips up while squeezing your glutes. Hold and slowly lower down.',
              style: const TextStyle(fontSize: 13, color: PatientTheme.textSecondary, height: 1.45),
            ),
            const SizedBox(height: 20),

            // 3 Stat Metric Cards (Sets, Reps, Duration)
            Row(
              children: [
                Expanded(child: _buildMetricCard('Sets', widget.sets, Icons.repeat_rounded)),
                const SizedBox(width: 12),
                Expanded(child: _buildMetricCard('Reps', widget.reps, Icons.format_list_numbered_rounded)),
                const SizedBox(width: 12),
                Expanded(child: _buildMetricCard('Duration', widget.duration, Icons.timer_outlined)),
              ],
            ),
            const SizedBox(height: 24),

            // Instructions Card
            PatientCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Step-by-Step Instructions',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: PatientTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 14),
                  for (int i = 0; i < defaultInstructions.length; i++)
                    _buildStepRow(i + 1, defaultInstructions[i]),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Safety Warning Box
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: PatientTheme.warningOrangeBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: PatientTheme.warningOrange.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(Icons.info_outline_rounded, color: PatientTheme.warningOrange, size: 18),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Stop immediately if you experience sharp pain. Maintain smooth, controlled breathing throughout the repetition.',
                      style: TextStyle(fontSize: 11.5, color: Color(0xFF92400E), height: 1.35),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // CTA Button
            PrimaryTealButton(
              label: _isCompleted ? 'Completed ✓ (Tap to reset)' : 'Mark as Completed',
              icon: _isCompleted ? Icons.check_circle_rounded : Icons.check_rounded,
              onPressed: _toggleCompleted,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PatientTheme.border),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: PatientTheme.primaryTeal),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: PatientTheme.textDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(fontSize: 11, color: PatientTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildStepRow(int number, String instruction) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: PatientTheme.primaryTealLight,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$number',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: PatientTheme.primaryTeal,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              instruction,
              style: const TextStyle(fontSize: 12.5, color: PatientTheme.textDark, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}
