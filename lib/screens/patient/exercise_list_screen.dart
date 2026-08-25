import 'package:flutter/material.dart';
import '../../constants/patient_theme.dart';
import '../../models/exercise_model.dart';
import '../../services/exercise_service.dart';
import 'exercise_detail_screen.dart';
import 'patient_components.dart';

/// Screen 8 — Today's Plan / Exercise List Screen (matching UI)
class ExerciseListScreen extends StatefulWidget {
  const ExerciseListScreen({super.key});

  @override
  State<ExerciseListScreen> createState() => _ExerciseListScreenState();
}

class _ExerciseListScreenState extends State<ExerciseListScreen> {
  final ExerciseService _exerciseService = ExerciseService();
  int _selectedTabIndex = 0; // 0: All, 1: Upcoming, 2: Completed
  bool _isLoading = true;
  List<PatientExerciseAssignmentModel> _exercises = [];

  @override
  void initState() {
    super.initState();
    _loadTodayPlan();
  }

  Future<void> _loadTodayPlan() async {
    setState(() => _isLoading = true);
    try {
      final plan = await _exerciseService.getTodayPlan();
      if (!mounted) return;
      setState(() {
        _exercises = plan.exercises;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  List<PatientExerciseAssignmentModel> get _filteredExercises {
    if (_selectedTabIndex == 1) {
      return _exercises.where((e) => !e.isCompletedToday).toList();
    } else if (_selectedTabIndex == 2) {
      return _exercises.where((e) => e.isCompletedToday).toList();
    }
    return _exercises;
  }

  void _openExercise(PatientExerciseAssignmentModel ex) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ExerciseDetailScreen(
          assignmentId: ex.id,
          exerciseName: ex.exerciseTitle,
          targetArea: ex.bodyPart,
          sets: '${ex.sets}',
          reps: '${ex.reps}',
          duration: ex.duration,
          isInitiallyCompleted: ex.isCompletedToday,
          instructions: ex.instructions,
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        ex.isCompletedToday = result;
      });
      _loadTodayPlan();
    }
  }

  void _startNextExercise() {
    final nextPending = _exercises.firstWhere(
      (e) => !e.isCompletedToday,
      orElse: () => _exercises.isNotEmpty
          ? _exercises.first
          : PatientExerciseAssignmentModel(
              id: '',
              patientId: '',
              physiotherapistId: '',
              exerciseId: '',
              exerciseTitle: 'Exercise',
              startDate: '',
            ),
    );

    if (nextPending.id.isNotEmpty) {
      _openExercise(nextPending);
    }
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = _exercises.where((e) => e.isCompletedToday).length;
    final totalCount = _exercises.length;

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
          'Today\'s Plan',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: PatientTheme.textDark),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: PatientTheme.primaryTeal))
          : RefreshIndicator(
              color: PatientTheme.primaryTeal,
              onRefresh: _loadTodayPlan,
              child: Column(
                children: [
                  // Header Summary Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Today\'s Exercises',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: PatientTheme.textDark,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Complete your exercises for today',
                                  style: TextStyle(fontSize: 12, color: PatientTheme.textSecondary),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: PatientTheme.primaryTealLight,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '$completedCount / $totalCount Done',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: PatientTheme.primaryTeal,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Filter Tabs (All, Upcoming, Completed)
                        Container(
                          height: 38,
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: PatientTheme.inputBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              _buildTabItem(0, 'All (${_exercises.length})'),
                              _buildTabItem(1, 'Upcoming (${totalCount - completedCount})'),
                              _buildTabItem(2, 'Completed ($completedCount)'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Exercise List or Empty State
                  Expanded(
                    child: _filteredExercises.isEmpty
                        ? ListView(
                            children: const [
                              SizedBox(height: 80),
                              Center(
                                child: Text(
                                  'No exercises scheduled in this section.',
                                  style: TextStyle(color: PatientTheme.textSecondary, fontSize: 14),
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                            itemCount: _filteredExercises.length,
                            itemBuilder: (context, index) {
                              final ex = _filteredExercises[index];
                              final isDone = ex.isCompletedToday;

                              return PatientCard(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(14),
                                onTap: () => _openExercise(ex),
                                child: Row(
                                  children: [
                                    // Thumbnail Icon Box
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: isDone ? PatientTheme.successGreenBg : PatientTheme.primaryTealLight,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.fitness_center_rounded,
                                        color: isDone ? PatientTheme.successGreen : PatientTheme.primaryTeal,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 14),

                                    // Details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            ex.exerciseTitle,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: PatientTheme.textDark,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            '${ex.sets} sets • ${ex.reps} reps • ${ex.duration}',
                                            style: const TextStyle(
                                              fontSize: 11.5,
                                              color: PatientTheme.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Status Badge
                                    StatusBadge(
                                      label: isDone ? 'Completed' : 'Pending',
                                      isCompleted: isDone,
                                      isPending: !isDone,
                                    ),
                                    const SizedBox(width: 6),
                                    const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: PatientTheme.textMuted),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
      bottomSheet: _exercises.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              color: Colors.white,
              child: PrimaryTealButton(
                label: 'Start Next Exercise',
                icon: Icons.play_arrow_rounded,
                onPressed: _startNextExercise,
              ),
            ),
    );
  }

  Widget _buildTabItem(int index, String label) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? PatientTheme.primaryTeal : PatientTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
