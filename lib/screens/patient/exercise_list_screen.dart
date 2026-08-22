import 'package:flutter/material.dart';
import '../../constants/patient_theme.dart';
import 'exercise_detail_screen.dart';
import 'patient_components.dart';

/// Screen 8 — Today's Plan / Exercise List Screen (matching media_1787385006975.jpg)
class ExerciseListScreen extends StatefulWidget {
  const ExerciseListScreen({super.key});

  @override
  State<ExerciseListScreen> createState() => _ExerciseListScreenState();
}

class _ExerciseListScreenState extends State<ExerciseListScreen> {
  int _selectedTabIndex = 0; // 0: Today, 1: Upcoming, 2: Completed

  final List<Map<String, dynamic>> _exercises = [
    {
      'name': 'Bridge Exercise',
      'target': 'Glutes • Lower Body',
      'sets': '3',
      'reps': '12',
      'duration': '10 min',
      'isCompleted': true,
      'icon': Icons.accessibility_new_rounded,
    },
    {
      'name': 'Wall Squat',
      'target': 'Quadriceps • Knee Stability',
      'sets': '3',
      'reps': '15',
      'duration': '15 min',
      'isCompleted': true,
      'icon': Icons.fitness_center_rounded,
    },
    {
      'name': 'Leg Raise',
      'target': 'Hip Flexors • Core',
      'sets': '3',
      'reps': '12',
      'duration': '10 min',
      'isCompleted': false,
      'icon': Icons.airline_seat_legroom_extra_rounded,
    },
    {
      'name': 'Hamstring Stretch',
      'target': 'Hamstrings • Flexibility',
      'sets': '3',
      'reps': '30 sec',
      'duration': '5 min',
      'isCompleted': false,
      'icon': Icons.self_improvement_rounded,
    },
    {
      'name': 'Calf Raises',
      'target': 'Calves • Ankle Stability',
      'sets': '3',
      'reps': '15',
      'duration': '8 min',
      'isCompleted': false,
      'icon': Icons.directions_walk_rounded,
    },
    {
      'name': 'Ankle Circles',
      'target': 'Ankle Mobility',
      'sets': '2',
      'reps': '20',
      'duration': '5 min',
      'isCompleted': true,
      'icon': Icons.rotate_right_rounded,
    },
  ];

  List<Map<String, dynamic>> get _filteredExercises {
    if (_selectedTabIndex == 1) {
      return _exercises.where((e) => !(e['isCompleted'] as bool)).toList();
    } else if (_selectedTabIndex == 2) {
      return _exercises.where((e) => e['isCompleted'] as bool).toList();
    }
    return _exercises;
  }

  void _openExercise(int index) async {
    final ex = _filteredExercises[index];
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ExerciseDetailScreen(
          exerciseName: ex['name'] as String,
          targetArea: ex['target'] as String,
          sets: ex['sets'] as String,
          reps: ex['reps'] as String,
          duration: ex['duration'] as String,
          isInitiallyCompleted: ex['isCompleted'] as bool,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        ex['isCompleted'] = result;
      });
    }
  }

  void _startNextExercise() {
    final nextPending = _exercises.firstWhere(
      (e) => !(e['isCompleted'] as bool),
      orElse: () => _exercises.first,
    );
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ExerciseDetailScreen(
          exerciseName: nextPending['name'] as String,
          targetArea: nextPending['target'] as String,
          sets: nextPending['sets'] as String,
          reps: nextPending['reps'] as String,
          duration: nextPending['duration'] as String,
          isInitiallyCompleted: nextPending['isCompleted'] as bool,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = _exercises.where((e) => e['isCompleted'] as bool).length;
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
      body: Column(
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

                // Filter Tabs (Today, Upcoming, Completed)
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

          // Exercise List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: _filteredExercises.length,
              itemBuilder: (context, index) {
                final ex = _filteredExercises[index];
                final isDone = ex['isCompleted'] as bool;

                return PatientCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  onTap: () => _openExercise(index),
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
                          ex['icon'] as IconData,
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
                              ex['name'] as String,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: PatientTheme.textDark,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${ex['sets']} sets • ${ex['reps']} reps • ${ex['duration']}',
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
      bottomSheet: Container(
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
