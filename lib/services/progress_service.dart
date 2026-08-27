import 'dart:developer' as dev;
import '../core/network/api_client.dart';
import '../models/progress_model.dart';

class ProgressService {
  static final ProgressService _instance = ProgressService._internal();
  factory ProgressService() => _instance;
  ProgressService._internal();

  final ApiClient _apiClient = ApiClient();

  PatientProgressModel? _cachedProgress;
  PatientProgressModel? get cachedProgress => _cachedProgress;

  Future<PatientProgressModel> getMyProgress({String period = 'this_month'}) async {
    try {
      final periodParam = period.toLowerCase().replaceAll(' ', '_');
      final response = await _apiClient.get<PatientProgressModel>(
        '/patients/me/progress?period=$periodParam',
        fromJson: (json) {
          if (json is Map<String, dynamic>) {
            return PatientProgressModel.fromJson(json);
          }
          return PatientProgressModel.empty();
        },
      );

      if (response.success && response.data != null) {
        _cachedProgress = response.data;
        return response.data!;
      }
    } catch (e) {
      dev.log('ProgressService.getMyProgress error: $e');
    }

    return _cachedProgress ?? PatientProgressModel.empty();
  }

  Future<PatientProgressModel> getPatientProgress(String patientId, {String period = 'this_month'}) async {
    try {
      final periodParam = period.toLowerCase().replaceAll(' ', '_');
      final response = await _apiClient.get<PatientProgressModel>(
        '/patients/$patientId/progress?period=$periodParam',
        fromJson: (json) {
          if (json is Map<String, dynamic>) {
            return PatientProgressModel.fromJson(json);
          }
          return PatientProgressModel.empty(patientId);
        },
      );

      if (response.success && response.data != null) {
        return response.data!;
      }
    } catch (e) {
      dev.log('ProgressService.getPatientProgress error for $patientId: $e');
    }

    return PatientProgressModel.empty(patientId);
  }
}
