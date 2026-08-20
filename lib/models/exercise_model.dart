class ExerciseModel {
  const ExerciseModel({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.description,
    required this.bodyPart,
    required this.difficulty,
    this.equipmentNeeded,
    this.videoUrl,
    this.thumbnailUrl,
    required this.instructions,
    this.sets = 3,
    this.reps = 10,
  });

  final String id;
  final String categoryId;
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

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id'] as String? ?? '',
      categoryId: json['category_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      bodyPart: json['body_part'] as String? ?? '',
      difficulty: json['difficulty'] as String? ?? 'Beginner',
      equipmentNeeded: json['equipment_needed'] as String?,
      videoUrl: json['video_url'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      instructions: json['instructions'] as String? ?? '',
      sets: json['sets'] as int? ?? 3,
      reps: json['reps'] as int? ?? 10,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
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
    };
  }

  ExerciseModel copyWith({
    String? id,
    String? categoryId,
    String? title,
    String? description,
    String? bodyPart,
    String? difficulty,
    String? equipmentNeeded,
    String? videoUrl,
    String? thumbnailUrl,
    String? instructions,
    int? sets,
    int? reps,
  }) {
    return ExerciseModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
      description: description ?? this.description,
      bodyPart: bodyPart ?? this.bodyPart,
      difficulty: difficulty ?? this.difficulty,
      equipmentNeeded: equipmentNeeded ?? this.equipmentNeeded,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      instructions: instructions ?? this.instructions,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
    );
  }
}
