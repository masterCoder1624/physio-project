import 'package:flutter/material.dart';
import '../../models/exercise_model.dart';

const Color _primaryBlue = Color(0xFF0066CC);
const Color _textPrimary = Color(0xFF2C3E50);
const Color _textSecondary = Color(0xFF7F8C8D);
const Color _pageBackground = Color(0xFFF8FAFB);
const Color _cardBackground = Color(0xFFFFFFFF);
const Color _border = Color(0xFFE1E8ED);

class ExerciseListScreen extends StatefulWidget {
  const ExerciseListScreen({super.key});

  @override
  State<ExerciseListScreen> createState() => _ExerciseListScreenState();
}

class _ExerciseListScreenState extends State<ExerciseListScreen> {
  final List<ExerciseModel> _exercises = const [
    ExerciseModel(
      id: 'ex-1',
      categoryId: 'cat-knee',
      title: 'Quadriceps Setting',
      description: 'Isometrics for quadriceps strengthening',
      bodyPart: 'Knee',
      difficulty: 'Beginner',
      instructions: 'Press knee downwards into towel roll. Hold for 5 seconds.',
      sets: 3,
      reps: 10,
    ),
    ExerciseModel(
      id: 'ex-2',
      categoryId: 'cat-knee',
      title: 'Straight Leg Raise (SLR)',
      description: 'Hip flexor and quadriceps strength builder',
      bodyPart: 'Knee & Hip',
      difficulty: 'Intermediate',
      instructions: 'Keep leg straight and lift 45 degrees off the bed. Lower slowly.',
      sets: 3,
      reps: 12,
    ),
    ExerciseModel(
      id: 'ex-3',
      categoryId: 'cat-ankle',
      title: 'Ankle Pumps',
      description: 'Circulation and calf mobility exercise',
      bodyPart: 'Ankle',
      difficulty: 'Beginner',
      instructions: 'Point toes down and flex back towards knees.',
      sets: 4,
      reps: 15,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBackground,
      appBar: AppBar(
        title: const Text('Prescribed Exercises'),
        backgroundColor: _primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _exercises.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final ex = _exercises[index];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      ex.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _textPrimary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _primaryBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        ex.difficulty,
                        style: const TextStyle(
                          fontSize: 12,
                          color: _primaryBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  ex.description,
                  style: const TextStyle(color: _textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Chip(
                      label: Text('${ex.sets} Sets'),
                      backgroundColor: _pageBackground,
                    ),
                    const SizedBox(width: 8),
                    Chip(
                      label: Text('${ex.reps} Reps'),
                      backgroundColor: _pageBackground,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Instructions: ${ex.instructions}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: _textSecondary,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
