class WeeklyActivityItemModel {
  final String day;
  final String date;
  final double completionRate;
  final bool isToday;

  WeeklyActivityItemModel({
    required this.day,
    required this.date,
    this.completionRate = 0.0,
    this.isToday = false,
  });

  factory WeeklyActivityItemModel.fromJson(Map<String, dynamic> json) {
    return WeeklyActivityItemModel(
      day: json['day']?.toString() ?? 'M',
      date: json['date']?.toString() ?? '',
      completionRate: (json['completion_rate'] as num?)?.toDouble() ?? 0.0,
      isToday: json['is_today'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'day': day,
        'date': date,
        'completion_rate': completionRate,
        'is_today': isToday,
      };
}

class ExerciseComplianceModel {
  final int totalAssigned;
  final int totalCompleted;
  final int completionPercentage;
  final int weeklyAdherencePercentage;
  final List<WeeklyActivityItemModel> weeklyActivity;

  ExerciseComplianceModel({
    this.totalAssigned = 0,
    this.totalCompleted = 0,
    this.completionPercentage = 0,
    this.weeklyAdherencePercentage = 0,
    this.weeklyActivity = const [],
  });

  factory ExerciseComplianceModel.fromJson(Map<String, dynamic> json) {
    return ExerciseComplianceModel(
      totalAssigned: json['total_assigned'] as int? ?? 0,
      totalCompleted: json['total_completed'] as int? ?? 0,
      completionPercentage: json['completion_percentage'] as int? ?? 0,
      weeklyAdherencePercentage: json['weekly_adherence_percentage'] as int? ?? 0,
      weeklyActivity: (json['weekly_activity'] as List?)
              ?.map((e) => WeeklyActivityItemModel.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'total_assigned': totalAssigned,
        'total_completed': totalCompleted,
        'completion_percentage': completionPercentage,
        'weekly_adherence_percentage': weeklyAdherencePercentage,
        'weekly_activity': weeklyActivity.map((e) => e.toJson()).toList(),
      };
}

class SessionProgressModel {
  final int completedSessions;
  final int totalSessions;
  final int upcomingSessions;

  SessionProgressModel({
    this.completedSessions = 0,
    this.totalSessions = 0,
    this.upcomingSessions = 0,
  });

  factory SessionProgressModel.fromJson(Map<String, dynamic> json) {
    return SessionProgressModel(
      completedSessions: json['completed_sessions'] as int? ?? 0,
      totalSessions: json['total_sessions'] as int? ?? 0,
      upcomingSessions: json['upcoming_sessions'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'completed_sessions': completedSessions,
        'total_sessions': totalSessions,
        'upcoming_sessions': upcomingSessions,
      };
}

class TreatmentProgramProgressModel {
  final String? programId;
  final String? title;
  final String? currentPhase;
  final int overallProgress;

  TreatmentProgramProgressModel({
    this.programId,
    this.title,
    this.currentPhase,
    this.overallProgress = 0,
  });

  factory TreatmentProgramProgressModel.fromJson(Map<String, dynamic> json) {
    return TreatmentProgramProgressModel(
      programId: json['program_id']?.toString(),
      title: json['title']?.toString(),
      currentPhase: json['current_phase']?.toString(),
      overallProgress: json['overall_progress'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'program_id': programId,
        'title': title,
        'current_phase': currentPhase,
        'overall_progress': overallProgress,
      };
}

class ProgressTimePointModel {
  final String date;
  final String label;
  final double value;

  ProgressTimePointModel({
    required this.date,
    required this.label,
    this.value = 0.0,
  });

  factory ProgressTimePointModel.fromJson(Map<String, dynamic> json) {
    return ProgressTimePointModel(
      date: json['date']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date,
        'label': label,
        'value': value,
      };
}

class PainTrendPointModel {
  final String date;
  final int painLevel;
  final String source;

  PainTrendPointModel({
    required this.date,
    this.painLevel = 0,
    this.source = 'assessment',
  });

  factory PainTrendPointModel.fromJson(Map<String, dynamic> json) {
    return PainTrendPointModel(
      date: json['date']?.toString() ?? '',
      painLevel: json['pain_level'] as int? ?? 0,
      source: json['source']?.toString() ?? 'assessment',
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date,
        'pain_level': painLevel,
        'source': source,
      };
}

class ROMTrendPointModel {
  final String date;
  final String flexion;
  final String extension;
  final String passive;

  ROMTrendPointModel({
    required this.date,
    this.flexion = 'N/A',
    this.extension = 'N/A',
    this.passive = 'N/A',
  });

  factory ROMTrendPointModel.fromJson(Map<String, dynamic> json) {
    return ROMTrendPointModel(
      date: json['date']?.toString() ?? '',
      flexion: json['flexion']?.toString() ?? 'N/A',
      extension: json['extension']?.toString() ?? 'N/A',
      passive: json['passive']?.toString() ?? 'N/A',
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date,
        'flexion': flexion,
        'extension': extension,
        'passive': passive,
      };
}

class PatientProgressModel {
  final String patientId;
  final String period;
  final int overallPercentage;
  final String progressSubtitle;
  final int completedCount;
  final int inProgressCount;
  final int pendingCount;
  final int adherencePercentage;
  final ExerciseComplianceModel exerciseCompliance;
  final SessionProgressModel sessionProgress;
  final TreatmentProgramProgressModel? treatmentProgram;
  final List<ProgressTimePointModel> progressOverTime;
  final List<String> dateLabels;
  final List<PainTrendPointModel> painTrend;
  final List<ROMTrendPointModel> romTrend;
  final bool hasData;

  PatientProgressModel({
    required this.patientId,
    this.period = 'this_month',
    this.overallPercentage = 0,
    this.progressSubtitle = 'Getting Started',
    this.completedCount = 0,
    this.inProgressCount = 0,
    this.pendingCount = 0,
    this.adherencePercentage = 0,
    ExerciseComplianceModel? exerciseCompliance,
    SessionProgressModel? sessionProgress,
    this.treatmentProgram,
    this.progressOverTime = const [],
    this.dateLabels = const [],
    this.painTrend = const [],
    this.romTrend = const [],
    this.hasData = false,
  })  : exerciseCompliance = exerciseCompliance ?? ExerciseComplianceModel(),
        sessionProgress = sessionProgress ?? SessionProgressModel();

  factory PatientProgressModel.fromJson(Map<String, dynamic> json) {
    return PatientProgressModel(
      patientId: json['patient_id']?.toString() ?? '',
      period: json['period']?.toString() ?? 'this_month',
      overallPercentage: json['overall_percentage'] as int? ?? 0,
      progressSubtitle: json['progress_subtitle']?.toString() ?? 'Getting Started',
      completedCount: json['completed_count'] as int? ?? 0,
      inProgressCount: json['in_progress_count'] as int? ?? 0,
      pendingCount: json['pending_count'] as int? ?? 0,
      adherencePercentage: json['adherence_percentage'] as int? ?? 0,
      exerciseCompliance: json['exercise_compliance'] != null
          ? ExerciseComplianceModel.fromJson(Map<String, dynamic>.from(json['exercise_compliance'] as Map))
          : ExerciseComplianceModel(),
      sessionProgress: json['session_progress'] != null
          ? SessionProgressModel.fromJson(Map<String, dynamic>.from(json['session_progress'] as Map))
          : SessionProgressModel(),
      treatmentProgram: json['treatment_program'] != null
          ? TreatmentProgramProgressModel.fromJson(Map<String, dynamic>.from(json['treatment_program'] as Map))
          : null,
      progressOverTime: (json['progress_over_time'] as List?)
              ?.map((e) => ProgressTimePointModel.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
      dateLabels: (json['date_labels'] as List?)?.map((e) => e.toString()).toList() ?? [],
      painTrend: (json['pain_trend'] as List?)
              ?.map((e) => PainTrendPointModel.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
      romTrend: (json['rom_trend'] as List?)
              ?.map((e) => ROMTrendPointModel.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
      hasData: json['has_data'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'patient_id': patientId,
        'period': period,
        'overall_percentage': overallPercentage,
        'progress_subtitle': progressSubtitle,
        'completed_count': completedCount,
        'in_progress_count': inProgressCount,
        'pending_count': pendingCount,
        'adherence_percentage': adherencePercentage,
        'exercise_compliance': exerciseCompliance.toJson(),
        'session_progress': sessionProgress.toJson(),
        'treatment_program': treatmentProgram?.toJson(),
        'progress_over_time': progressOverTime.map((e) => e.toJson()).toList(),
        'date_labels': dateLabels,
        'pain_trend': painTrend.map((e) => e.toJson()).toList(),
        'rom_trend': romTrend.map((e) => e.toJson()).toList(),
        'has_data': hasData,
      };

  factory PatientProgressModel.empty([String patientId = '']) => PatientProgressModel(
        patientId: patientId,
        period: 'this_month',
        overallPercentage: 0,
        progressSubtitle: 'Not Started',
        completedCount: 0,
        inProgressCount: 0,
        pendingCount: 0,
        adherencePercentage: 0,
        hasData: false,
      );
}
