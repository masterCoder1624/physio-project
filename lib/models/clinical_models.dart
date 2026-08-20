import 'dart:typed_data';

/// Clinical Assessment containing baseline & periodic physical evaluation metrics
class AssessmentModel {
  const AssessmentModel({
    required this.id,
    required this.date,
    required this.chiefComplaint,
    required this.painLevel, // 0 to 10 scale
    required this.painType, // Sharp, Dull, Throbbing, Burning, Aching
    required this.activeRomFlexion, // Degrees e.g. 115°
    required this.activeRomExtension, // Degrees e.g. 0°
    required this.passiveRom,
    required this.muscleStrengthMMT, // 1 to 5 MMT Scale e.g. "4/5 (Good)"
    required this.functionalLimitations,
    this.postureGaitNotes,
    this.specialTests,
    this.clinicalGoal,
  });

  final String id;
  final String date;
  final String chiefComplaint;
  final int painLevel;
  final String painType;
  final String activeRomFlexion;
  final String activeRomExtension;
  final String passiveRom;
  final String muscleStrengthMMT;
  final String functionalLimitations;
  final String? postureGaitNotes;
  final String? specialTests;
  final String? clinicalGoal;

  factory AssessmentModel.fromJson(Map<String, dynamic> json) {
    return AssessmentModel(
      id: json['id'] as String? ?? 'ASS_${DateTime.now().millisecondsSinceEpoch}',
      date: json['date'] as String? ?? DateTime.now().toIso8601String().substring(0, 10),
      chiefComplaint: json['chief_complaint'] as String? ?? 'Pain and limited mobility',
      painLevel: json['pain_level'] as int? ?? 5,
      painType: json['pain_type'] as String? ?? 'Aching',
      activeRomFlexion: json['active_rom_flexion'] as String? ?? '110°',
      activeRomExtension: json['active_rom_extension'] as String? ?? '0°',
      passiveRom: json['passive_rom'] as String? ?? '115°',
      muscleStrengthMMT: json['muscle_strength_mmt'] as String? ?? '4/5',
      functionalLimitations: json['functional_limitations'] as String? ?? 'Difficulty climbing stairs and kneeling',
      postureGaitNotes: json['posture_gait_notes'] as String?,
      specialTests: json['special_tests'] as String?,
      clinicalGoal: json['clinical_goal'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'chief_complaint': chiefComplaint,
      'pain_level': painLevel,
      'pain_type': painType,
      'active_rom_flexion': activeRomFlexion,
      'active_rom_extension': activeRomExtension,
      'passive_rom': passiveRom,
      'muscle_strength_mmt': muscleStrengthMMT,
      'functional_limitations': functionalLimitations,
      'posture_gait_notes': postureGaitNotes,
      'special_tests': specialTests,
      'clinical_goal': clinicalGoal,
    };
  }

  AssessmentModel copyWith({
    String? id,
    String? date,
    String? chiefComplaint,
    int? painLevel,
    String? painType,
    String? activeRomFlexion,
    String? activeRomExtension,
    String? passiveRom,
    String? muscleStrengthMMT,
    String? functionalLimitations,
    String? postureGaitNotes,
    String? specialTests,
    String? clinicalGoal,
  }) {
    return AssessmentModel(
      id: id ?? this.id,
      date: date ?? this.date,
      chiefComplaint: chiefComplaint ?? this.chiefComplaint,
      painLevel: painLevel ?? this.painLevel,
      painType: painType ?? this.painType,
      activeRomFlexion: activeRomFlexion ?? this.activeRomFlexion,
      activeRomExtension: activeRomExtension ?? this.activeRomExtension,
      passiveRom: passiveRom ?? this.passiveRom,
      muscleStrengthMMT: muscleStrengthMMT ?? this.muscleStrengthMMT,
      functionalLimitations: functionalLimitations ?? this.functionalLimitations,
      postureGaitNotes: postureGaitNotes ?? this.postureGaitNotes,
      specialTests: specialTests ?? this.specialTests,
      clinicalGoal: clinicalGoal ?? this.clinicalGoal,
    );
  }
}

/// Assigned exercise with specific dosage, sets, reps and completion state
class AssignedExercise {
  const AssignedExercise({
    required this.id,
    required this.exerciseId,
    required this.title,
    required this.bodyPart,
    required this.difficulty,
    required this.instructions,
    this.sets = 3,
    this.reps = 10,
    this.holdSeconds = 5,
    this.frequencyPerDay = 2,
    this.isCompleted = false,
    this.videoUrl,
    this.assignedDate,
  });

  final String id;
  final String exerciseId;
  final String title;
  final String bodyPart;
  final String difficulty;
  final String instructions;
  final int sets;
  final int reps;
  final int holdSeconds;
  final int frequencyPerDay;
  final bool isCompleted;
  final String? videoUrl;
  final String? assignedDate;

  factory AssignedExercise.fromJson(Map<String, dynamic> json) {
    return AssignedExercise(
      id: json['id'] as String? ?? 'ASG_${DateTime.now().millisecondsSinceEpoch}',
      exerciseId: json['exercise_id'] as String? ?? '',
      title: json['title'] as String? ?? 'Prescribed Exercise',
      bodyPart: json['body_part'] as String? ?? 'General',
      difficulty: json['difficulty'] as String? ?? 'Beginner',
      instructions: json['instructions'] as String? ?? '',
      sets: json['sets'] as int? ?? 3,
      reps: json['reps'] as int? ?? 10,
      holdSeconds: json['hold_seconds'] as int? ?? 5,
      frequencyPerDay: json['frequency_per_day'] as int? ?? 2,
      isCompleted: json['is_completed'] as bool? ?? false,
      videoUrl: json['video_url'] as String?,
      assignedDate: json['assigned_date'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exercise_id': exerciseId,
      'title': title,
      'body_part': bodyPart,
      'difficulty': difficulty,
      'instructions': instructions,
      'sets': sets,
      'reps': reps,
      'hold_seconds': holdSeconds,
      'frequency_per_day': frequencyPerDay,
      'is_completed': isCompleted,
      'video_url': videoUrl,
      'assigned_date': assignedDate,
    };
  }

  AssignedExercise copyWith({
    String? id,
    String? exerciseId,
    String? title,
    String? bodyPart,
    String? difficulty,
    String? instructions,
    int? sets,
    int? reps,
    int? holdSeconds,
    int? frequencyPerDay,
    bool? isCompleted,
    String? videoUrl,
    String? assignedDate,
  }) {
    return AssignedExercise(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      title: title ?? this.title,
      bodyPart: bodyPart ?? this.bodyPart,
      difficulty: difficulty ?? this.difficulty,
      instructions: instructions ?? this.instructions,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      holdSeconds: holdSeconds ?? this.holdSeconds,
      frequencyPerDay: frequencyPerDay ?? this.frequencyPerDay,
      isCompleted: isCompleted ?? this.isCompleted,
      videoUrl: videoUrl ?? this.videoUrl,
      assignedDate: assignedDate ?? this.assignedDate,
    );
  }
}

/// Treatment Program connecting rehabilitation goals, duration, sessions, and HEP
class TreatmentProgramModel {
  const TreatmentProgramModel({
    required this.id,
    required this.title,
    required this.diagnosis,
    required this.primaryGoal,
    required this.durationWeeks,
    required this.totalSessionsTarget,
    this.completedSessionsCount = 0,
    required this.startDate,
    this.status = 'ACTIVE', // ACTIVE, COMPLETED, PAUSED
    this.assignedExercises = const [],
    this.clinicalProtocolNotes,
  });

  final String id;
  final String title;
  final String diagnosis;
  final String primaryGoal;
  final int durationWeeks;
  final int totalSessionsTarget;
  final int completedSessionsCount;
  final String startDate;
  final String status;
  final List<AssignedExercise> assignedExercises;
  final String? clinicalProtocolNotes;

  double get progressPercentage {
    if (totalSessionsTarget <= 0) return 0.0;
    final pct = completedSessionsCount / totalSessionsTarget;
    return pct > 1.0 ? 1.0 : pct;
  }

  factory TreatmentProgramModel.fromJson(Map<String, dynamic> json) {
    var exercisesList = <AssignedExercise>[];
    if (json['assigned_exercises'] != null && json['assigned_exercises'] is List) {
      exercisesList = (json['assigned_exercises'] as List)
          .map((e) => AssignedExercise.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return TreatmentProgramModel(
      id: json['id'] as String? ?? 'PRG_${DateTime.now().millisecondsSinceEpoch}',
      title: json['title'] as String? ?? 'Rehabilitation Plan',
      diagnosis: json['diagnosis'] as String? ?? '',
      primaryGoal: json['primary_goal'] as String? ?? 'Restore mobility and strength',
      durationWeeks: json['duration_weeks'] as int? ?? 6,
      totalSessionsTarget: json['total_sessions_target'] as int? ?? 12,
      completedSessionsCount: json['completed_sessions_count'] as int? ?? 0,
      startDate: json['start_date'] as String? ?? DateTime.now().toIso8601String().substring(0, 10),
      status: json['status'] as String? ?? 'ACTIVE',
      assignedExercises: exercisesList,
      clinicalProtocolNotes: json['clinical_protocol_notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'diagnosis': diagnosis,
      'primary_goal': primaryGoal,
      'duration_weeks': durationWeeks,
      'total_sessions_target': totalSessionsTarget,
      'completed_sessions_count': completedSessionsCount,
      'start_date': startDate,
      'status': status,
      'assigned_exercises': assignedExercises.map((e) => e.toJson()).toList(),
      'clinical_protocol_notes': clinicalProtocolNotes,
    };
  }

  TreatmentProgramModel copyWith({
    String? id,
    String? title,
    String? diagnosis,
    String? primaryGoal,
    int? durationWeeks,
    int? totalSessionsTarget,
    int? completedSessionsCount,
    String? startDate,
    String? status,
    List<AssignedExercise>? assignedExercises,
    String? clinicalProtocolNotes,
  }) {
    return TreatmentProgramModel(
      id: id ?? this.id,
      title: title ?? this.title,
      diagnosis: diagnosis ?? this.diagnosis,
      primaryGoal: primaryGoal ?? this.primaryGoal,
      durationWeeks: durationWeeks ?? this.durationWeeks,
      totalSessionsTarget: totalSessionsTarget ?? this.totalSessionsTarget,
      completedSessionsCount: completedSessionsCount ?? this.completedSessionsCount,
      startDate: startDate ?? this.startDate,
      status: status ?? this.status,
      assignedExercises: assignedExercises ?? this.assignedExercises,
      clinicalProtocolNotes: clinicalProtocolNotes ?? this.clinicalProtocolNotes,
    );
  }
}

/// Clinical SOAP Treatment Session Note with previous session context
class SessionNoteModel {
  const SessionNoteModel({
    required this.id,
    required this.sessionNumber,
    required this.date,
    required this.painLevel, // 0 to 10
    required this.subjectiveNotes, // Patient reports, symptoms, functional feedback
    required this.objectiveFindings, // ROM, tenderness, swelling, gait check
    required this.treatmentRendered, // Modalities, manual therapy, supervised exercises
    required this.planForNextSession, // Progression, home exercise revisions
    this.therapistName = 'Dr. Alex',
  });

  final String id;
  final int sessionNumber;
  final String date;
  final int painLevel;
  final String subjectiveNotes;
  final String objectiveFindings;
  final String treatmentRendered;
  final String planForNextSession;
  final String therapistName;

  factory SessionNoteModel.fromJson(Map<String, dynamic> json) {
    return SessionNoteModel(
      id: json['id'] as String? ?? 'NOTE_${DateTime.now().millisecondsSinceEpoch}',
      sessionNumber: json['session_number'] as int? ?? 1,
      date: json['date'] as String? ?? DateTime.now().toIso8601String().substring(0, 10),
      painLevel: json['pain_level'] as int? ?? 3,
      subjectiveNotes: json['subjective_notes'] as String? ?? '',
      objectiveFindings: json['objective_findings'] as String? ?? '',
      treatmentRendered: json['treatment_rendered'] as String? ?? '',
      planForNextSession: json['plan_for_next_session'] as String? ?? '',
      therapistName: json['therapist_name'] as String? ?? 'Dr. Alex',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'session_number': sessionNumber,
      'date': date,
      'pain_level': painLevel,
      'subjective_notes': subjectiveNotes,
      'objective_findings': objectiveFindings,
      'treatment_rendered': treatmentRendered,
      'plan_for_next_session': planForNextSession,
      'therapist_name': therapistName,
    };
  }
}

/// Bill Vault Record storing generated invoices and payment receipts in the patient profile
class BillRecordModel {
  const BillRecordModel({
    required this.id,
    required this.fileNo,
    required this.receiptNo,
    required this.dateStr,
    required this.description,
    required this.amount,
    required this.paidAmount,
    required this.remainingAmount,
    this.paymentMode = 'Offline Payment',
    this.status = 'COMPLETED',
    this.pdfBytes,
  });

  final String id;
  final String fileNo;
  final String receiptNo;
  final String dateStr;
  final String description;
  final double amount;
  final double paidAmount;
  final double remainingAmount;
  final String paymentMode;
  final String status;
  final Uint8List? pdfBytes;

  bool get isFullyPaid => remainingAmount <= 0.01;

  factory BillRecordModel.fromJson(Map<String, dynamic> json) {
    return BillRecordModel(
      id: json['id'] as String? ?? 'BILL_${DateTime.now().millisecondsSinceEpoch}',
      fileNo: json['file_no'] as String? ?? 'FILE0001',
      receiptNo: json['receipt_no'] as String? ?? 'REC0001',
      dateStr: json['date_str'] as String? ?? DateTime.now().toIso8601String().substring(0, 10),
      description: json['description'] as String? ?? 'Treatment Session',
      amount: (json['amount'] as num? ?? 1000).toDouble(),
      paidAmount: (json['paid_amount'] as num? ?? 1000).toDouble(),
      remainingAmount: (json['remaining_amount'] as num? ?? 0).toDouble(),
      paymentMode: json['payment_mode'] as String? ?? 'Offline Payment',
      status: json['status'] as String? ?? 'COMPLETED',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'file_no': fileNo,
      'receipt_no': receiptNo,
      'date_str': dateStr,
      'description': description,
      'amount': amount,
      'paid_amount': paidAmount,
      'remaining_amount': remainingAmount,
      'payment_mode': paymentMode,
      'status': status,
    };
  }

  BillRecordModel copyWith({
    String? id,
    String? fileNo,
    String? receiptNo,
    String? dateStr,
    String? description,
    double? amount,
    double? paidAmount,
    double? remainingAmount,
    String? paymentMode,
    String? status,
    Uint8List? pdfBytes,
  }) {
    return BillRecordModel(
      id: id ?? this.id,
      fileNo: fileNo ?? this.fileNo,
      receiptNo: receiptNo ?? this.receiptNo,
      dateStr: dateStr ?? this.dateStr,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      paidAmount: paidAmount ?? this.paidAmount,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      paymentMode: paymentMode ?? this.paymentMode,
      status: status ?? this.status,
      pdfBytes: pdfBytes ?? this.pdfBytes,
    );
  }
}

/// Clinical Document Record (X-Rays, MRI scans, Discharge summaries, Lab Reports)
class PatientDocumentModel {
  const PatientDocumentModel({
    required this.id,
    required this.title,
    required this.category, // Imaging, Lab Report, Discharge Summary, Referral
    required this.uploadDate,
    required this.fileSize,
    this.fileExtension = 'PDF',
    this.notes,
  });

  final String id;
  final String title;
  final String category;
  final String uploadDate;
  final String fileSize;
  final String fileExtension;
  final String? notes;

  factory PatientDocumentModel.fromJson(Map<String, dynamic> json) {
    return PatientDocumentModel(
      id: json['id'] as String? ?? 'DOC_${DateTime.now().millisecondsSinceEpoch}',
      title: json['title'] as String? ?? 'Clinical Document',
      category: json['category'] as String? ?? 'Imaging',
      uploadDate: json['upload_date'] as String? ?? DateTime.now().toIso8601String().substring(0, 10),
      fileSize: json['file_size'] as String? ?? '1.2 MB',
      fileExtension: json['file_extension'] as String? ?? 'PDF',
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'upload_date': uploadDate,
      'file_size': fileSize,
      'file_extension': fileExtension,
      'notes': notes,
    };
  }
}
