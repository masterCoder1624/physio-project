import '../core/network/api_client.dart';
import '../models/exercise_model.dart';

class ExerciseService {
  factory ExerciseService({ApiClient? apiClient}) {
    if (apiClient != null) {
      _instance._apiClient = apiClient;
    }
    return _instance;
  }

  ExerciseService._internal();

  static final ExerciseService _instance = ExerciseService._internal();
  ApiClient _apiClient = ApiClient();

  /// 1. Master Exercise Library
  Future<List<ExerciseModel>> getExercises({
    String? categoryName,
    String? bodyPart,
    String? difficulty,
    String? search,
  }) async {
    final params = <String, String>{};
    if (categoryName != null && categoryName.isNotEmpty && categoryName != 'All') {
      params['category_name'] = categoryName;
    }
    if (bodyPart != null && bodyPart.isNotEmpty && bodyPart != 'All') {
      params['body_part'] = bodyPart;
    }
    if (difficulty != null && difficulty.isNotEmpty && difficulty != 'All') {
      params['difficulty'] = difficulty;
    }
    if (search != null && search.isNotEmpty) {
      params['search'] = search;
    }

    final response = await _apiClient.get<List<ExerciseModel>>(
      '/exercises',
      queryParameters: params.isNotEmpty ? params : null,
      fromJson: (json) {
        if (json is List) {
          return json
              .map((item) => ExerciseModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        return [];
      },
    );

    if (response.success && response.data != null) {
      return response.data!;
    }
    return [];
  }

  /// 2. Exercise Categories
  Future<List<ExerciseCategoryModel>> getCategories() async {
    final response = await _apiClient.get<List<ExerciseCategoryModel>>(
      '/exercises/categories',
      fromJson: (json) {
        if (json is List) {
          return json
              .map((item) => ExerciseCategoryModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        return [];
      },
    );

    if (response.success && response.data != null) {
      return response.data!;
    }
    return [];
  }

  /// 3. Exercise Details
  Future<ExerciseModel?> getExerciseById(String id) async {
    final response = await _apiClient.get<ExerciseModel>(
      '/exercises/$id',
      fromJson: (json) => ExerciseModel.fromJson(json as Map<String, dynamic>),
    );

    if (response.success && response.data != null) {
      return response.data!;
    }
    return null;
  }

  /// 4. Patient Exercise Prescription (Physio assigns to Patient)
  Future<PatientExerciseAssignmentModel?> assignExercise({
    required String patientId,
    required String exerciseId,
    int sets = 3,
    int reps = 12,
    String duration = '10 min',
    String frequency = 'Daily',
    String? instructions,
  }) async {
    final payload = {
      'exercise_id': exerciseId,
      'sets': sets,
      'reps': reps,
      'duration': duration,
      'frequency': frequency,
      'instructions': instructions,
    };

    final response = await _apiClient.post<PatientExerciseAssignmentModel>(
      '/patients/$patientId/exercises',
      body: payload,
      fromJson: (json) => PatientExerciseAssignmentModel.fromJson(json as Map<String, dynamic>),
    );

    if (response.success && response.data != null) {
      return response.data!;
    }
    return null;
  }

  /// 5. Home Exercise Program — Today's Plan (Patient Perspective)
  Future<TodayPlanModel> getTodayPlan() async {
    final response = await _apiClient.get<TodayPlanModel>(
      '/patients/me/today-plan',
      fromJson: (json) {
        if (json is Map<String, dynamic>) {
          return TodayPlanModel.fromJson(json);
        }
        return const TodayPlanModel(
          date: '',
          patientId: '',
          totalExercises: 0,
          completedExercises: 0,
          progressPercentage: 0,
          exercises: [],
        );
      },
    );

    if (response.success && response.data != null) {
      return response.data!;
    }
    return const TodayPlanModel(
      date: '',
      patientId: '',
      totalExercises: 0,
      completedExercises: 0,
      progressPercentage: 0,
      exercises: [],
    );
  }

  /// 6. Mark Exercise as Completed
  Future<bool> completeExercise({
    required String assignmentId,
    int completedSets = 3,
    int completedReps = 12,
    int painScore = 0,
    String? notes,
  }) async {
    final payload = {
      'completed_sets': completedSets,
      'completed_reps': completedReps,
      'pain_score': painScore,
      'notes': notes,
    };

    final response = await _apiClient.post<Map<String, dynamic>>(
      '/patients/me/exercises/$assignmentId/complete',
      body: payload,
      fromJson: (json) => json as Map<String, dynamic>,
    );

    return response.success;
  }

  /// 7. Patient's Treatment Programs
  Future<List<PatientProgramModel>> getMyPrograms() async {
    final response = await _apiClient.get<List<PatientProgramModel>>(
      '/patients/me/programs',
      fromJson: (json) {
        if (json is List) {
          return json
              .map((item) => PatientProgramModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        return [];
      },
    );

    if (response.success && response.data != null) {
      return response.data!;
    }
    return [];
  }

  /// 8. Single Program Detail
  Future<PatientProgramModel?> getProgramById(String programId) async {
    final response = await _apiClient.get<PatientProgramModel>(
      '/programs/$programId',
      fromJson: (json) => PatientProgramModel.fromJson(json as Map<String, dynamic>),
    );

    if (response.success && response.data != null) {
      return response.data!;
    }
    return null;
  }
}
