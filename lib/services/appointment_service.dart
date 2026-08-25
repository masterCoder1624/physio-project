import '../core/network/api_client.dart';
import '../models/appointment_model.dart';

class AppointmentService {
  factory AppointmentService({ApiClient? apiClient}) {
    if (apiClient != null) {
      _instance._apiClient = apiClient;
    }
    return _instance;
  }

  AppointmentService._internal();

  static final AppointmentService _instance = AppointmentService._internal();
  ApiClient _apiClient = ApiClient();

  Future<List<AppointmentModel>> getAppointments({
    String? date,
    String? physioId,
    String? patientId,
    String? status,
  }) async {
    final queryParams = <String, String>{};
    if (date != null && date.isNotEmpty) queryParams['date'] = date;
    if (physioId != null && physioId.isNotEmpty) queryParams['physio_id'] = physioId;
    if (patientId != null && patientId.isNotEmpty) queryParams['patient_id'] = patientId;
    if (status != null && status.isNotEmpty && status.toLowerCase() != 'all') queryParams['status'] = status;

    final response = await _apiClient.get<List<AppointmentModel>>(
      '/appointments',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
      fromJson: (json) {
        if (json is List) {
          return json
              .map((item) => AppointmentModel.fromJson(item as Map<String, dynamic>))
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

  Future<AppointmentModel?> getAppointmentById(String id) async {
    final response = await _apiClient.get<AppointmentModel>(
      '/appointments/$id',
      fromJson: (json) => AppointmentModel.fromJson(json as Map<String, dynamic>),
    );

    if (response.success && response.data != null) {
      return response.data!;
    }
    return null;
  }

  Future<AppointmentModel> createAppointment({
    required String appointmentDate,
    required String startTime,
    String? endTime,
    String? patientId,
    String? physiotherapistId,
    String? patientName,
    String? patientCondition,
    String? patientPhone,
    String? physioName,
    String? physioSpecialty,
    String appointmentType = 'In-person',
    String duration = '45 min',
    String? notes,
  }) async {
    final response = await _apiClient.post<AppointmentModel>(
      '/appointments',
      body: {
        'appointment_date': appointmentDate,
        'start_time': startTime,
        'end_time': ?endTime,
        'patient_id': ?patientId,
        'physiotherapist_id': ?physiotherapistId,
        'patient_name': ?patientName,
        'patient_condition': ?patientCondition,
        'patient_phone': ?patientPhone,
        'physio_name': ?physioName,
        'physio_specialty': ?physioSpecialty,
        'appointment_type': appointmentType,
        'duration': duration,
        'notes': ?notes,
      },
      fromJson: (json) => AppointmentModel.fromJson(json as Map<String, dynamic>),
    );

    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.message);
    }
  }

  Future<AppointmentModel> cancelAppointment(String id, {String reason = 'Cancelled by user'}) async {
    final encodedReason = Uri.encodeComponent(reason);
    final response = await _apiClient.post<AppointmentModel>(
      '/appointments/$id/cancel?reason=$encodedReason',
      fromJson: (json) => AppointmentModel.fromJson(json as Map<String, dynamic>),
    );

    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.message);
    }
  }

  Future<List<SlotItemModel>> getAvailableSlots(String date, {String? physioId}) async {
    final queryParams = <String, String>{'date': date};
    if (physioId != null && physioId.isNotEmpty) queryParams['physio_id'] = physioId;

    final response = await _apiClient.get<List<SlotItemModel>>(
      '/appointments/available-slots',
      queryParameters: queryParams,
      fromJson: (json) {
        if (json is Map && json['slots'] is List) {
          return (json['slots'] as List)
              .map((item) => SlotItemModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        return [];
      },
    );

    if (response.success && response.data != null && response.data!.isNotEmpty) {
      return response.data!;
    }

    // Default fallback slots if server is spinning up or offline
    const defaultTimes = [
      '09:00 AM',
      '10:00 AM',
      '11:30 AM',
      '01:00 PM',
      '04:00 PM',
      '04:30 PM',
      '05:00 PM',
      '06:00 PM',
      '07:30 PM',
      '08:00 PM',
    ];
    return defaultTimes.map((t) => SlotItemModel(time: t, available: true)).toList();
  }
}
