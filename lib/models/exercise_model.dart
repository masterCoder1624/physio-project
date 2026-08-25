class ExerciseCategoryModel {
  const ExerciseCategoryModel({
    required this.id,
    required this.name,
    this.description,
    this.iconUrl,
  });

  final String id;
  final String name;
  final String? description;
  final String? iconUrl;

  factory ExerciseCategoryModel.fromJson(Map<String, dynamic> json) {
    return ExerciseCategoryModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      iconUrl: json['icon_url'] as String?,
    );
  }
}

class ExerciseModel {
  const ExerciseModel({
    required this.id,
    this.categoryId = '',
    this.categoryName = 'Rehabilitation',
    required this.title,
    required this.description,
    required this.bodyPart,
    required this.difficulty,
    this.equipmentNeeded,
    this.videoUrl,
    this.thumbnailUrl,
    required this.instructions,
    this.sets = 3,
    this.reps = 12,
    this.durationSeconds = 600,
    this.defaultRestSeconds = 30,
    this.isActive = true,
  });

  final String id;
  final String categoryId;
  final String categoryName;
  final String title;
  final String description;
  final String bodyPart;
  final String difficulty;
  final String? equipmentNeeded;
  final String? videoUrl;
  final String? thumbnailUrl;
  final String instructions;
  final int sets;
  final int reps;
  final int durationSeconds;
  final int defaultRestSeconds;
  final bool isActive;

  String get durationFormatted => '${durationSeconds ~/ 60} min';

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id'] as String? ?? '',
      categoryId: json['category_id'] as String? ?? '',
      categoryName: json['category_name'] as String? ?? 'Rehabilitation',
      title: json['title'] as String? ?? json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      bodyPart: json['body_part'] as String? ?? json['target'] as String? ?? 'General',
      difficulty: json['difficulty'] as String? ?? 'Beginner',
      equipmentNeeded: json['equipment_needed'] as String?,
      videoUrl: json['video_url'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      instructions: json['instructions'] as String? ?? '',
      sets: json['sets'] as int? ?? json['default_sets'] as int? ?? 3,
      reps: json['reps'] as int? ?? json['default_reps'] as int? ?? 12,
      durationSeconds: json['duration_seconds'] as int? ?? 600,
      defaultRestSeconds: json['default_rest_seconds'] as int? ?? 30,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'category_name': categoryName,
      'title': title,
      'description': description,
      'body_part': bodyPart,
      'difficulty': difficulty,
      'equipment_needed': equipmentNeeded,
      'video_url': videoUrl,
      'thumbnail_url': thumbnailUrl,
      'instructions': instructions,
      'sets': sets,
      'reps': reps,
      'duration_seconds': durationSeconds,
      'default_rest_seconds': defaultRestSeconds,
      'is_active': isActive,
    };
  }
}

class PatientExerciseAssignmentModel {
  PatientExerciseAssignmentModel({
    required this.id,
    required this.patientId,
    required this.physiotherapistId,
    required this.exerciseId,
    required this.exerciseTitle,
    this.bodyPart = 'General',
    this.difficulty = 'Beginner',
    this.sets = 3,
    this.reps = 12,
    this.duration = '10 min',
    this.frequency = 'Daily',
    this.instructions,
    required this.startDate,
    this.endDate,
    this.sequenceOrder = 1,
    this.isActive = true,
    this.lastCompletedDate,
    this.isCompletedToday = false,
  });

  final String id;
  final String patientId;
  final String physiotherapistId;
  final String exerciseId;
  final String exerciseTitle;
  final String bodyPart;
  final String difficulty;
  final int sets;
  final int reps;
  final String duration;
  final String frequency;
  final String? instructions;
  final String startDate;
  final String? endDate;
  final int sequenceOrder;
  final bool isActive;
  final String? lastCompletedDate;
  bool isCompletedToday;

  factory PatientExerciseAssignmentModel.fromJson(Map<String, dynamic> json) {
    return PatientExerciseAssignmentModel(
      id: json['id'] as String? ?? '',
      patientId: json['patient_id'] as String? ?? '',
      physiotherapistId: json['physiotherapist_id'] as String? ?? '',
      exerciseId: json['exercise_id'] as String? ?? '',
      exerciseTitle: json['exercise_title'] as String? ?? json['title'] as String? ?? 'Exercise',
      bodyPart: json['body_part'] as String? ?? 'General',
      difficulty: json['difficulty'] as String? ?? 'Beginner',
      sets: json['sets'] as int? ?? 3,
      reps: json['reps'] as int? ?? 12,
      duration: json['duration'] as String? ?? '10 min',
      frequency: json['frequency'] as String? ?? 'Daily',
      instructions: json['instructions'] as String?,
      startDate: json['start_date'] as String? ?? '',
      endDate: json['end_date'] as String?,
      sequenceOrder: json['sequence_order'] as int? ?? 1,
      isActive: json['is_active'] as bool? ?? true,
      lastCompletedDate: json['last_completed_date'] as String?,
      isCompletedToday: json['is_completed_today'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'physiotherapist_id': physiotherapistId,
      'exercise_id': exerciseId,
      'exercise_title': exerciseTitle,
      'body_part': bodyPart,
      'difficulty': difficulty,
      'sets': sets,
      'reps': reps,
      'duration': duration,
      'frequency': frequency,
      'instructions': instructions,
      'start_date': startDate,
      'end_date': endDate,
      'sequence_order': sequenceOrder,
      'is_active': isActive,
      'last_completed_date': lastCompletedDate,
      'is_completed_today': isCompletedToday,
    };
  }
}

class TodayPlanModel {
  const TodayPlanModel({
    required this.date,
    required this.patientId,
    required this.totalExercises,
    required this.completedExercises,
    required this.progressPercentage,
    required this.exercises,
  });

  final String date;
  final String patientId;
  final int totalExercises;
  final int completedExercises;
  final int progressPercentage;
  final List<PatientExerciseAssignmentModel> exercises;

  factory TodayPlanModel.fromJson(Map<String, dynamic> json) {
    final list = (json['exercises'] as List<dynamic>? ?? [])
        .map((e) => PatientExerciseAssignmentModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return TodayPlanModel(
      date: json['date'] as String? ?? '',
      patientId: json['patient_id'] as String? ?? '',
      totalExercises: json['total_exercises'] as int? ?? list.length,
      completedExercises: json['completed_exercises'] as int? ?? 0,
      progressPercentage: json['progress_percentage'] as int? ?? 0,
      exercises: list,
    );
  }
}

class ProgramPhaseModel {
  const ProgramPhaseModel({
    required this.name,
    this.description = '',
    this.order = 1,
    this.startDate,
    this.endDate,
    this.status = 'in_progress',
    this.exercises = const [],
  });

  final String name;
  final String description;
  final int order;
  final String? startDate;
  final String? endDate;
  final String status;
  final List<dynamic> exercises;

  bool get isCompleted => status.toLowerCase() == 'completed';
  bool get isInProgress => status.toLowerCase() == 'in_progress' || status.toLowerCase() == 'active';
  bool get isPending => status.toLowerCase() == 'pending';

  factory ProgramPhaseModel.fromJson(Map<String, dynamic> json) {
    return ProgramPhaseModel(
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      order: json['order'] as int? ?? 1,
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
      status: json['status'] as String? ?? 'in_progress',
      exercises: json['exercises'] as List<dynamic>? ?? [],
    );
  }
}

class PatientProgramModel {
  const PatientProgramModel({
    required this.id,
    required this.title,
    this.description = '',
    this.condition = 'General Rehabilitation',
    this.patientId,
    this.physiotherapistId,
    this.startDate,
    this.endDate,
    this.status = 'active',
    this.progressPercentage = 0,
    this.phases = const [],
    this.isTemplate = false,
  });

  final String id;
  final String title;
  final String description;
  final String condition;
  final String? patientId;
  final String? physiotherapistId;
  final String? startDate;
  final String? endDate;
  final String status;
  final int progressPercentage;
  final List<ProgramPhaseModel> phases;
  final bool isTemplate;

  bool get isActive => status.toLowerCase() == 'active';

  factory PatientProgramModel.fromJson(Map<String, dynamic> json) {
    final rawPhases = json['phases'] as List<dynamic>? ?? [];
    return PatientProgramModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Rehabilitation Program',
      description: json['description'] as String? ?? '',
      condition: json['condition'] as String? ?? 'General Rehabilitation',
      patientId: json['patient_id'] as String?,
      physiotherapistId: json['physiotherapist_id'] as String?,
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
      status: json['status'] as String? ?? 'active',
      progressPercentage: json['progress_percentage'] as int? ?? 0,
      phases: rawPhases.map((p) => ProgramPhaseModel.fromJson(p as Map<String, dynamic>)).toList(),
      isTemplate: json['is_template'] as bool? ?? false,
    );
  }
}
