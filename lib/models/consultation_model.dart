class ConsultationModel {
  const ConsultationModel({
    required this.id,
    required this.patientId,
    required this.physioId,
    required this.appointmentDate,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.notes,
  });

  final String id;
  final String patientId;
  final String physioId;
  final String appointmentDate;
  final String startTime;
  final String endTime;
  final String status;
  final String? notes;

  factory ConsultationModel.fromJson(Map<String, dynamic> json) {
    return ConsultationModel(
      id: json['id'] as String? ?? '',
      patientId: json['patient_id'] as String? ?? '',
      physioId: json['physiotherapist_id'] as String? ?? '',
      appointmentDate: json['appointment_date'] as String? ?? '',
      startTime: json['start_time'] as String? ?? '',
      endTime: json['end_time'] as String? ?? '',
      status: json['status'] as String? ?? 'scheduled',
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'physiotherapist_id': physioId,
      'appointment_date': appointmentDate,
      'start_time': startTime,
      'end_time': endTime,
      'status': status,
      'notes': notes,
    };
  }

  ConsultationModel copyWith({
    String? id,
    String? patientId,
    String? physioId,
    String? appointmentDate,
    String? startTime,
    String? endTime,
    String? status,
    String? notes,
  }) {
    return ConsultationModel(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      physioId: physioId ?? this.physioId,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }
}
