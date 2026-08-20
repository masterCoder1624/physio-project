import 'package:flutter/material.dart';
import '../../models/clinical_models.dart';
import '../../models/exercise_model.dart';
import '../../services/patient_service.dart';

const Color _kPageBg = Color(0xFF0F1F17);
const Color _kCardBg = Color(0xFF183326);
const Color _kBorderColor = Color(0xFF254B37);
const Color _kPrimary = Color(0xFF10B981);
const Color _kTextDark = Color(0xFFF8FAFC);
const Color _kTextSecondary = Color(0xFFA7F3D0);
const Color _kTextMuted = Color(0xFF6EE7B7);

class ExerciseLibraryScreen extends StatefulWidget {
  const ExerciseLibraryScreen({super.key, this.patientId, this.patientName});

  final String? patientId;
  final String? patientName;

  @override
  State<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends State<ExerciseLibraryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  List<ExerciseModel> _filteredExercises = [];

  final List<String> _categories = [
    'All',
    'Knee',
    'Spine & Back',
    'Shoulder',
    'Neck / Cervical',
    'Ankle & Foot',
  ];

  @override
  void initState() {
    super.initState();
    _filteredExercises = List.from(PatientService.masterExerciseLibrary);
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _filteredExercises = PatientService.masterExerciseLibrary.where((ex) {
        final matchesCat = _selectedCategory == 'All' ||
            ex.bodyPart.toLowerCase().contains(_selectedCategory.toLowerCase()) ||
            ex.categoryId.toLowerCase().contains(_selectedCategory.toLowerCase());
        final matchesQuery = query.isEmpty ||
            ex.title.toLowerCase().contains(query) ||
            ex.description.toLowerCase().contains(query) ||
            ex.bodyPart.toLowerCase().contains(query);
        return matchesCat && matchesQuery;
      }).toList();
    });
  }

  void _openAssignDialog(ExerciseModel exercise) {
    int sets = exercise.sets;
    int reps = exercise.reps;
    int holdSeconds = 5;
    int freqPerDay = 2;
    final instructionsCtrl = TextEditingController(text: exercise.instructions);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _kCardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Assign ${exercise.title}',
                            style: const TextStyle(
                              color: _kTextDark,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close, color: _kTextSecondary),
                        ),
                      ],
                    ),
                    if (widget.patientName != null)
                      Text(
                        'Assigning to: ${widget.patientName}',
                        style: const TextStyle(color: _kPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    const SizedBox(height: 16),
                    const Text('Dosage & Parameters', style: TextStyle(color: _kTextDark, fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDosageCounter(
                            label: 'Sets',
                            value: sets,
                            onDec: () => setModalState(() => sets = sets > 1 ? sets - 1 : 1),
                            onInc: () => setModalState(() => sets++),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDosageCounter(
                            label: 'Reps',
                            value: reps,
                            onDec: () => setModalState(() => reps = reps > 1 ? reps - 1 : 1),
                            onInc: () => setModalState(() => reps++),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDosageCounter(
                            label: 'Hold (sec)',
                            value: holdSeconds,
                            onDec: () => setModalState(() => holdSeconds = holdSeconds > 0 ? holdSeconds - 1 : 0),
                            onInc: () => setModalState(() => holdSeconds++),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDosageCounter(
                            label: 'Times / Day',
                            value: freqPerDay,
                            onDec: () => setModalState(() => freqPerDay = freqPerDay > 1 ? freqPerDay - 1 : 1),
                            onInc: () => setModalState(() => freqPerDay++),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Patient Instructions', style: TextStyle(color: _kTextDark, fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: instructionsCtrl,
                      maxLines: 3,
                      style: const TextStyle(color: _kTextDark, fontSize: 13),
                      decoration: InputDecoration(
                        fillColor: const Color(0xFF0F1F17),
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: _kBorderColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () async {
                          final nav = Navigator.of(context);
                          final messenger = ScaffoldMessenger.of(context);
                          if (widget.patientId != null) {
                            final assigned = AssignedExercise(
                              id: 'ASG_${DateTime.now().millisecondsSinceEpoch}',
                              exerciseId: exercise.id,
                              title: exercise.title,
                              bodyPart: exercise.bodyPart,
                              difficulty: exercise.difficulty,
                              instructions: instructionsCtrl.text.trim(),
                              sets: sets,
                              reps: reps,
                              holdSeconds: holdSeconds,
                              frequencyPerDay: freqPerDay,
                              assignedDate: DateTime.now().toIso8601String().substring(0, 10),
                            );
                            await PatientService().assignExerciseToPatient(widget.patientId!, assigned);
                          }
                          if (!mounted) return;
                          nav.pop();
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text('Assigned "${exercise.title}" successfully!'),
                              backgroundColor: _kPrimary,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _kPrimary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Confirm Prescription', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDosageCounter({
    required String label,
    required int value,
    required VoidCallback onDec,
    required VoidCallback onInc,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1F17),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: _kTextSecondary, fontSize: 11)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: onDec,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: _kCardBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.remove, size: 16, color: _kTextDark),
                ),
              ),
              Text(
                '$value',
                style: const TextStyle(color: _kTextDark, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              InkWell(
                onTap: onInc,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: _kCardBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.add, size: 16, color: _kTextDark),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kPageBg,
      appBar: AppBar(
        title: const Text('Clinical Exercise Library'),
        backgroundColor: _kCardBg,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Box
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Container(
              decoration: BoxDecoration(
                color: _kCardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _kBorderColor),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: _kTextDark, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Search exercises, body parts, or conditions...',
                  hintStyle: TextStyle(color: _kTextMuted, fontSize: 13),
                  prefixIcon: Icon(Icons.search, color: _kTextMuted),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),

          // Categories Filter Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() {
                        _selectedCategory = cat;
                        _applyFilters();
                      });
                    },
                    selectedColor: _kPrimary,
                    backgroundColor: _kCardBg,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : _kTextSecondary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: isSelected ? _kPrimary : _kBorderColor),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Exercise List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredExercises.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final ex = _filteredExercises[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _kCardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _kBorderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              ex.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _kTextDark,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF064E3B),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              ex.difficulty,
                              style: const TextStyle(
                                color: _kPrimary,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        ex.description,
                        style: const TextStyle(color: _kTextSecondary, fontSize: 13),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF132A1F),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text('Body Part: ${ex.bodyPart}', style: const TextStyle(color: _kTextMuted, fontSize: 11)),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF132A1F),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text('${ex.sets} Sets × ${ex.reps} Reps', style: const TextStyle(color: _kTextMuted, fontSize: 11)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Prescription: ${ex.instructions}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8), fontStyle: FontStyle.italic),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () => _openAssignDialog(ex),
                            icon: const Icon(Icons.add_task, size: 16),
                            label: const Text('Prescribe'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _kPrimary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
