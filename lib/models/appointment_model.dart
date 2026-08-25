import 'package:flutter/material.dart';

class AppointmentModel {
  const AppointmentModel({
    required this.id,
    required this.patientId,
    required this.physiotherapistId,
    this.clinicId,
    this.patientName,
    this.patientCondition,
    this.patientPhone,
    this.physioName,
    this.physioSpecialty,
    required this.appointmentDate,
    required this.startTime,
    this.endTime,
    this.duration = '45 min',
    this.appointmentType = 'In-person',
    this.status = 'scheduled',
    this.notes,
    this.cancellationReason,
    this.createdAt,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] as String? ?? '',
      patientId: json['patient_id'] as String? ?? '',
      physiotherapistId: json['physiotherapist_id'] as String? ?? '',
      clinicId: json['clinic_id'] as String?,
      patientName: json['patient_name'] as String?,
      patientCondition: json['patient_condition'] as String?,
      patientPhone: json['patient_phone'] as String?,
      physioName: json['physio_name'] as String?,
      physioSpecialty: json['physio_specialty'] as String?,
      appointmentDate: json['appointment_date'] as String? ?? '',
      startTime: json['start_time'] as String? ?? '',
      endTime: json['end_time'] as String?,
      duration: json['duration'] as String? ?? '45 min',
      appointmentType: json['appointment_type'] as String? ?? 'In-person',
      status: (json['status'] as String? ?? 'scheduled').toLowerCase(),
      notes: json['notes'] as String?,
      cancellationReason: json['cancellation_reason'] as String?,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
    );
  }

  final String id;
  final String patientId;
  final String physiotherapistId;
  final String? clinicId;
  final String? patientName;
  final String? patientCondition;
  final String? patientPhone;
  final String? physioName;
  final String? physioSpecialty;
  final String appointmentDate;
  final String startTime;
  final String? endTime;
  final String duration;
  final String appointmentType;
  final String status;
  final String? notes;
  final String? cancellationReason;
  final DateTime? createdAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'physiotherapist_id': physiotherapistId,
      'clinic_id': clinicId,
      'patient_name': patientName,
      'patient_condition': patientCondition,
      'patient_phone': patientPhone,
      'physio_name': physioName,
      'physio_specialty': physioSpecialty,
      'appointment_date': appointmentDate,
      'start_time': startTime,
      'end_time': endTime,
      'duration': duration,
      'appointment_type': appointmentType,
      'status': status,
      'notes': notes,
      'cancellation_reason': cancellationReason,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  String get initials {
    final name = patientName ?? 'Patient';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'PT';
    if (parts.length == 1) return parts.first.substring(0, parts.first.length > 1 ? 2 : 1).toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  bool get isConfirmed => status == 'confirmed' || status == 'scheduled';
  bool get isPending => status == 'pending';
  bool get isCancelled => status == 'cancelled';
  bool get isCompleted => status == 'completed';

  Color get statusColor {
    if (isConfirmed || isCompleted) return const Color(0xFF16A34A);
    if (isPending) return const Color(0xFFF59E0B);
    if (isCancelled) return const Color(0xFFEF4444);
    return const Color(0xFF08A9BE);
  }

  Color get statusBgColor {
    if (isConfirmed || isCompleted) return const Color(0xFFEAF8EF);
    if (isPending) return const Color(0xFFFFF4E2);
    if (isCancelled) return const Color(0xFFFFECEC);
    return const Color(0xFFE8F8FA);
  }
}

class SlotItemModel {
  const SlotItemModel({
    required this.time,
    this.available = true,
    this.appointmentId,
  });

  factory SlotItemModel.fromJson(Map<String, dynamic> json) {
    return SlotItemModel(
      time: json['time'] as String? ?? '',
      available: json['available'] as bool? ?? true,
      appointmentId: json['appointment_id'] as String?,
    );
  }

  final String time;
  final bool available;
  final String? appointmentId;
}
