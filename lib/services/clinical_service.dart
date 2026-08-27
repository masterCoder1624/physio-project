import 'package:flutter/foundation.dart';
import '../core/network/api_client.dart';
import '../models/clinical_models.dart';

/// Service managing Clinical Assessments and SOAP Notes via FastAPI Backend
class ClinicalService {
  static final ClinicalService _instance = ClinicalService._internal();
  factory ClinicalService() => _instance;
  ClinicalService._internal();

  final ApiClient _apiClient = ApiClient();

  // =========================================================================
  // Clinical Assessments
  // =========================================================================

  /// Fetch all clinical assessments for a patient
  Future<List<AssessmentModel>> getAssessments(String patientId) async {
    try {
      final response = await _apiClient.get<List<AssessmentModel>>(
        '/patients/$patientId/assessments',
        fromJson: (json) {
          if (json is List) {
            return json
                .map((item) => AssessmentModel.fromJson(item as Map<String, dynamic>))
                .toList();
          }
          return [];
        },
      );

      if (response.success && response.data != null) {
        return response.data!;
      }
    } catch (e) {
      debugPrint('Error loading assessments for patient $patientId: $e');
    }
    return [];
  }

  /// Fetch the latest baseline or periodic clinical assessment
  Future<AssessmentModel?> getLatestAssessment(String patientId) async {
    try {
      final response = await _apiClient.get<AssessmentModel?>(
        '/patients/$patientId/assessments/latest',
        fromJson: (json) {
          if (json is Map<String, dynamic>) {
            return AssessmentModel.fromJson(json);
          }
          return null;
        },
      );

      if (response.success && response.data != null) {
        return response.data;
      }
    } catch (e) {
      debugPrint('Error loading latest assessment for patient $patientId: $e');
    }
    return null;
  }

  /// Create a new clinical assessment
  Future<AssessmentModel?> createAssessment(String patientId, AssessmentModel assessment) async {
    try {
      final response = await _apiClient.post<AssessmentModel>(
        '/patients/$patientId/assessments',
        body: assessment.toJson(),
        fromJson: (json) => AssessmentModel.fromJson(json as Map<String, dynamic>),
      );

      if (response.success && response.data != null) {
        return response.data;
      }
    } catch (e) {
      debugPrint('Error creating assessment for patient $patientId: $e');
      rethrow;
    }
    return null;
  }

  /// Update an existing clinical assessment
  Future<AssessmentModel?> updateAssessment(
    String patientId,
    String assessmentId,
    AssessmentModel assessment,
  ) async {
    try {
      final response = await _apiClient.patch<AssessmentModel>(
        '/patients/$patientId/assessments/$assessmentId',
        body: assessment.toJson(),
        fromJson: (json) => AssessmentModel.fromJson(json as Map<String, dynamic>),
      );

      if (response.success && response.data != null) {
        return response.data;
      }
    } catch (e) {
      debugPrint('Error updating assessment $assessmentId: $e');
      rethrow;
    }
    return null;
  }

  // =========================================================================
  // Clinical SOAP Session Notes
  // =========================================================================

  /// Fetch all SOAP clinical notes for a patient
  Future<List<SessionNoteModel>> getNotes(String patientId) async {
    try {
      final response = await _apiClient.get<List<SessionNoteModel>>(
        '/patients/$patientId/notes',
        fromJson: (json) {
          if (json is List) {
            return json
                .map((item) => SessionNoteModel.fromJson(item as Map<String, dynamic>))
                .toList();
          }
          return [];
        },
      );

      if (response.success && response.data != null) {
        return response.data!;
      }
    } catch (e) {
      debugPrint('Error loading clinical notes for patient $patientId: $e');
    }
    return [];
  }

  /// Create a new clinical SOAP session note
  Future<SessionNoteModel?> createNote(String patientId, SessionNoteModel note) async {
    try {
      final response = await _apiClient.post<SessionNoteModel>(
        '/patients/$patientId/notes',
        body: note.toJson(),
        fromJson: (json) => SessionNoteModel.fromJson(json as Map<String, dynamic>),
      );

      if (response.success && response.data != null) {
        return response.data;
      }
    } catch (e) {
      debugPrint('Error creating clinical note for patient $patientId: $e');
      rethrow;
    }
    return null;
  }

  /// Update an existing clinical SOAP session note
  Future<SessionNoteModel?> updateNote(
    String patientId,
    String noteId,
    SessionNoteModel note,
  ) async {
    try {
      final response = await _apiClient.patch<SessionNoteModel>(
        '/patients/$patientId/notes/$noteId',
        body: note.toJson(),
        fromJson: (json) => SessionNoteModel.fromJson(json as Map<String, dynamic>),
      );

      if (response.success && response.data != null) {
        return response.data;
      }
    } catch (e) {
      debugPrint('Error updating clinical note $noteId: $e');
      rethrow;
    }
    return null;
  }
}
